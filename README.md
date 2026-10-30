# Tienda en contenedores

Proyecto final de la Fase 1 del Roadmap DevOps 2027: una aplicación de tres capas
(frontend, API y PostgreSQL con caché en Redis) con imágenes optimizadas y
seguras, orquestada con Docker Compose.

```
navegador → proxy (nginx sin root, 127.0.0.1:8080) ─┬→ frontend (nginx sin root)
                                                     └→ api (FastAPI, sin root) ─┬→ db (PostgreSQL 17, volumen)
                                                                                 └→ cache (Redis, sin disco)
```

## Arrancar en desarrollo

Funciona igual en Windows (Docker Desktop o WSL), macOS y Linux:

```bash
cp .env.example .env            # cambia DB_PASSWORD
docker compose up -d --build    # aplica compose.override.yaml: recarga en caliente de la API
docker compose ps               # espera a que api y db estén healthy
./scripts/verify.sh
```

Abre http://localhost:8080. La API también responde directamente en
http://localhost:8000/docs (solo en desarrollo).

## Producción (el servidor de la Fase 0)

1. Publica las imágenes en GHCR (en tu máquina o, desde la Fase 2, en el CI):

   ```bash
   docker buildx build --platform linux/amd64,linux/arm64 --build-arg VERSION=1.0.0 \
     -t ghcr.io/TU-USUARIO/tienda-api:1.0.0 --push ./api
   docker buildx build --platform linux/amd64,linux/arm64 \
     -t ghcr.io/TU-USUARIO/tienda-frontend:1.0.0 --push ./frontend
   ```

2. En el servidor, descomenta en `.env` las variables de producción
   (`GHCR_USER`, `TAG`, `COMPOSE_FILE`) y ejecuta:

   ```bash
   docker compose pull
   docker compose up -d
   ./scripts/verify.sh --parada
   ```

3. En el Nginx del host (Fase 0), cambia `proxy_pass` de `/` a `http://127.0.0.1:8080`.

Actualizar: cambia `TAG` en `.env` y repite `pull` y `up -d`. Volver atrás: el tag anterior.

## Backups

```bash
./scripts/backup-db.sh                 # dump comprimido en backups/, conserva 7 días
gunzip -c backups/app-FECHA.sql.gz | docker compose exec -T db psql -U app -d app
```

Prográmalo con un timer de systemd en el servidor, como en la Fase 0.

## Decisiones

- Solo el proxy publica un puerto, y solo en 127.0.0.1.
- La red `backend` es `internal`: la base de datos y Redis no tienen salida a internet.
- Ningún servicio propio corre como root; en producción, además, con el sistema de
  archivos en solo lectura, sin capabilities y con `no-new-privileges`.
- Logs con el driver `local` y rotación, para que no llenen el disco.

## En AWS (Fase 3)

La carpeta [`aws/`](aws/README.md) tiene los scripts de primer día y de costes, las
políticas IAM y la task definition de ECS. El workflow `Deploy AWS` despliega la API en
ECS Fargate (ARM64) y el frontend en S3 + CloudFront con OIDC, sin claves de acceso.
La API acepta `DATABASE_URL` o las piezas `DB_HOST`, `DB_USER`, `DB_PASSWORD`… que
inyecta ECS desde el secreto gestionado por RDS.

## En Kubernetes (Fase 5)

[`chart/tienda`](chart/tienda) es el chart de Helm de la tienda (Gateway API, HPA, PDB,
NetworkPolicies, Pod Security `restricted`). `kind/crear-lab.sh` monta un clúster local para
probarlo y `eks/main.tf` es la capa EKS del repositorio de infraestructura. El workflow
`Kubernetes` valida el chart en cada PR. Detalles en [KUBERNETES.md](KUBERNETES.md).

## Observable (Fase 7)

[`observabilidad/`](observabilidad/README.md) añade a la pila de Compose OpenTelemetry (sin tocar
el código de la API), el Collector, Prometheus con alertas de burn rate, Alertmanager, Loki, Tempo
y Grafana con el dashboard como código:

```bash
docker compose -f compose.yaml -f observabilidad/compose.yaml up -d --build   # Grafana: http://localhost:3000
```

## Segura (Fase 8)

Cada imagen se firma por digest con Sigstore (keyless, sin claves) y lleva su SBOM firmado; Kyverno
solo admite en el clúster las firmadas por el workflow `Imagen` en `main`. El workflow `Seguridad`
ejecuta Semgrep (resultados en la pestaña Security) y prueba las políticas. Detalles en
[`seguridad/`](seguridad/README.md) y el [modelo de amenazas](docs/modelo-amenazas.md).

## Plataforma (Fase 9)

La tienda en el catálogo de Backstage (`catalog-info.yaml`, con la OpenAPI de `api/openapi.yaml`), su
documentación como código (`mkdocs.yml` y `docs/`, para TechDocs) y la plataforma de autoservicio en
`plataforma/`: la API `BaseDatos` de Crossplane, que crea una RDS con los estándares de la casa, y el
alta automática de equipos con Kyverno. Cómo probarlo en kind, incluso contra un simulador de AWS:
[plataforma/README.md](plataforma/README.md).

## Qué aprendí

(Tamaño de cada imagen antes y después, resultado de Trivy, problemas que encontraste.)
