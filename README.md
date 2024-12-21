# Production Ready Laravel Dockerfile

If you have any improvements please make a PR!

### .env
```
BACKEND_PORT=80
```

### docker-compose.yml
```
services:

  laravel:
    build:
      context: ./src
      dockerfile: Dockerfile
    container_name: production-laravel
    restart: unless-stopped
    ports:
      - "${BACKEND_PORT}:80"
    volumes:
      - ./src:/var/www/html:z
```