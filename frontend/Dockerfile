# Nginx sin root (usuario 101, escucha en el 8080) sirviendo una página estática
FROM nginxinc/nginx-unprivileged:1.28-alpine
COPY --chown=101:101 index.html /usr/share/nginx/html/index.html
# La imagen base ya usa este usuario; declararlo deja claro (también a los escáneres) que no es root
USER 101
