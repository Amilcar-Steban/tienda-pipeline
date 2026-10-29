# La tienda observable (Fase 7)

Telemetría completa de la tienda en tu portátil, sin tocar el código de la API:

```
api (OpenTelemetry automático) ──OTLP──► collector ─┬─ trazas ───► Tempo ──┐
                                                    ├─ métricas ─► Prometheus ─► Alertmanager ─► alertas
                                                    └─ logs ─────► Loki ───┴─► Grafana
carga ──► proxy ──► api                 (≈5 peticiones/s constantes, como usuarios reales)
```

## Arrancar

```bash
cp .env.example .env    # o define DB_PASSWORD en .env
docker compose -f compose.yaml -f observabilidad/compose.yaml up -d --build
```

| Qué | Dónde |
|---|---|
| Grafana (dashboard "Tienda · API") | http://localhost:3000 (anónimo, solo lectura; `admin`/`admin` para editar) |
| Prometheus (consultas, reglas, alertas) | http://localhost:9090 |
| Alertmanager | http://localhost:9093 |
| Avisos recibidos | `docker compose -f compose.yaml -f observabilidad/compose.yaml logs -f alertas` |

Para pararlo todo: el mismo comando con `down` (añade `-v` para borrar también los datos).

## Qué hay en cada archivo

| Archivo | Para qué |
|---|---|
| `api/Dockerfile` | La misma API con `opentelemetry-instrument`: FastAPI, psycopg y redis instrumentados solos |
| `api/logging.json` | Que los logs de uvicorn lleguen al handler de OpenTelemetry (y a Loki) |
| `collector/config.yaml` | Un pipeline por señal; borra datos personales antes de exportar |
| `prometheus/reglas/tienda.yml` | Reglas de grabación RED, SLO 99,9 % y alertas de burn rate multiventana |
| `alertmanager/alertmanager.yml` | Rutas por gravedad, inhibición y Watchdog |
| `grafana/` | Fuentes de datos con correlaciones y el dashboard, todo como código |
| `RUNBOOK.md` | Qué hacer cuando salta cada alerta |

## Provocar un incidente

```bash
C="docker compose -f compose.yaml -f observabilidad/compose.yaml"
$C stop db      # la API empieza a fallar
# ~2 min: ApiPresupuestoConsumoRapido en pending; ~3 min: firing y aviso en "alertas"
$C start db     # y mira cómo se recupera el panel
```

En Grafana: el panel de errores sube, el burn rate pasa de 14,4 y el de presupuesto se pone en rojo.
En Explore → Tempo, `{ resource.service.name = "tienda-api" && status = error }` muestra las
peticiones fallidas con la excepción (`psycopg.errors.…`) y su duración.

## Lo que enseña este laboratorio (y que no se ve en los tutoriales)

- **Los nombres no son los de los tutoriales**: OpenTelemetry no genera `http_requests_total`. El
  histograma `http.server.request.duration` llega a Prometheus como
  `http_server_request_duration_seconds_{bucket,count,sum}`, con `http_route` y
  `http_response_status_code`. Las peticiones son el `_count`.
- **La división vacía**: si nunca hubo un 5xx, `sum(rate(…{code=~"5.."}))` no devuelve nada y la
  proporción de errores sale vacía, no 0. Las reglas usan `or … * 0`.
- **Carga en lazo abierto**: si el generador espera cada respuesta, una API colgada frena la carga y
  las métricas muestran pocos errores justo cuando más usuarios fallan.
- **Mide cerca del usuario**: con la base caída, el proxy devuelve 504 a los 15 s mientras la API
  aún espera 30 s para registrar su 500. El SLI medido en la API llega tarde y se queda corto.
- **Los buckets mandan**: los del histograma por defecto llegan a 10 s; una petición de 30 s se ve
  como "p95 = 10 s".
- **Logs sin trace_id**: el error que escribe uvicorn ("Exception in ASGI application") se emite
  fuera del span de la petición y llega a Loki sin `trace_id`. Para correlacionar, la aplicación
  debe registrar sus errores dentro de la petición (un manejador de excepciones con `logging`).
