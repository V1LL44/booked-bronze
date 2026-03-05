FROM php:8.2-cli

WORKDIR /app

# Extensiones necesarias para Booked (MySQL)
RUN docker-php-ext-install mysqli pdo pdo_mysql

COPY . /app

# Render inyecta PORT; fallback local 10000
CMD ["sh", "-c", "php -S 0.0.0.0:${PORT:-10000} -t /app"]
