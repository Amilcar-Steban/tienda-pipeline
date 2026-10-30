"""Crea el esquema de la base de datos y termina.

Lo ejecuta el usuario dueño de las tablas (en Kubernetes, el Job de migraciones del chart), para que la
API pueda funcionar con ESQUEMA_AL_ARRANCAR=false y unas credenciales que solo leen y escriben datos.

    python -m app.migrar
"""

from app.main import migrar, pool

if __name__ == "__main__":
    pool.open(wait=True, timeout=60)
    try:
        migrar()
    finally:
        pool.close()
    print("esquema al día")
