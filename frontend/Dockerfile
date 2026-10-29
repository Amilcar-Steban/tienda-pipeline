# Nginx sin root (usuario 101, escucha en el 8080) sirviendo una página estática
FROM nginxinc/nginx-unprivileged:1.30-alpine
# Parches de seguridad del sistema base, por si la imagen de origen aún no se ha reconstruido
# (Trivy en el pipeline bloquea las vulnerabilidades críticas que ya tienen arreglo)
USER 0
# hadolint ignore=DL3017
RUN apk upgrade --no-cache
USER 101
COPY --chown=101:101 index.html /usr/share/nginx/html/index.html
