FROM nginx:1.25-alpine
WORKDIR /usr/share/nginx/html

# Install curl for HEALTHCHECK
RUN apk add --no-cache curl

# Replace default static assets and Nginx config (reverse proxies /api to the backend)
RUN rm -rf ./*
COPY src/index.html .
COPY nginx/default.conf /etc/nginx/conf.d/default.conf

# Run as non-root: move the PID file to a writable path and fix ownership
RUN sed -i 's#^pid .*#pid /tmp/nginx.pid;#; /^user /d' /etc/nginx/nginx.conf && \
    chown -R nginx:nginx /usr/share/nginx/html /var/cache/nginx /var/log/nginx

USER nginx

EXPOSE 8080

HEALTHCHECK --interval=10s --timeout=3s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:8080/ || exit 1
