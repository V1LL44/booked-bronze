FROM php:8.2-cli

WORKDIR /app

# Extensiones necesarias para Booked (MySQL)
RUN docker-php-ext-install mysqli pdo pdo_mysql

COPY . /app

# Directorios que Booked necesita con escritura durante instalacion
RUN mkdir -p /app/tpl_c /app/uploads /app/config \
  && chmod -R 777 /app/tpl_c /app/uploads /app/config

# Render inyecta PORT; fallback local 10000
CMD ["sh", "-c", "php -S 0.0.0.0:${PORT:-10000} -t /app"]
