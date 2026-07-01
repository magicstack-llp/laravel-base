# Laravel Base Docker Image

A minimal base image for Laravel applications supporting multiple PHP versions (`8.2`, `8.3`, `8.4`, `8.5`) on Alpine Linux, with common PHP extensions and Node.js tooling preinstalled. Published as a multi-architecture image (`linux/amd64`, `linux/arm64`).

## Image & Tags

-   Docker Hub: `satputekuldip/laravel-base`
-   GitHub Container Registry (GHCR): `ghcr.io/magicstack-llp/laravel-base`

### Tagging Scheme

For each PHP version `X.Y` (where `X.Y` is `8.2`, `8.3`, `8.4`, or `8.5`):
-   **Default tags:** `X.Y`, `X.Y-fpm-alpine`, `phpX.Y` (e.g. `8.3`, `8.3-fpm-alpine`, `php8.3`)
-   **Release-specific tags:** Built when a Git tag `vA.B.C` is pushed:
    -   `A.B.C-phpX.Y`, `A.B-phpX.Y`, `A-phpX.Y`
-   **Default PHP version (8.2) bare tags:**
    -   `A.B.C`, `A.B`, `A`, `latest`

## What's included

Base images: `php:8.2-fpm-alpine` to `php:8.5-fpm-alpine` configured dynamically.

System packages:

-   `nodejs`, `npm` (with latest npm globally)
-   `git`, `curl`, `zip`, `unzip`
-   Development libs: `libpng-dev`, `libzip-dev`, `oniguruma-dev`, `postgresql-dev`, `sqlite-dev`, `icu-dev`, `libexif-dev`

PHP extensions:

-   `pdo`, `pdo_mysql`, `pdo_pgsql`, `pdo_sqlite`
-   `zip`, `gd`, `intl`, `opcache`, `bcmath`, `exif`

This makes the image suitable as a base for most Laravel apps using MySQL, PostgreSQL, or SQLite.

## Supported platforms

-   `linux/amd64`
-   `linux/arm64`

## Usage

### Pull the image

```bash
# Latest
docker pull satputekuldip/laravel-base:latest

# Specific version
docker pull satputekuldip/laravel-base:1.0.0
```

### Use as a base image

In your application Dockerfile:

```dockerfile
FROM satputekuldip/laravel-base:latest

# Copy application code
WORKDIR /var/www/html
COPY . .

# Install composer dependencies, etc.
# RUN composer install --no-dev --optimize-autoloader

# Expose PHP-FPM port (optional)
EXPOSE 9000
```

### Docker Compose example

This repo includes a simple compose file that builds the image locally and tags it:

```yaml
services:
    app:
        build:
            context: .
            dockerfile: Dockerfile
            platforms:
                - linux/arm64
                - linux/amd64
        image: satputekuldip/laravel-base:latest
```

To build with Compose:

```bash
docker compose build
```

## CI/CD & Publishing

A GitHub Actions workflow builds and pushes the image on tag pushes (`vX.Y.Z`) and optional manual dispatch. It:

-   Builds multi-arch images using `docker buildx`
-   Pushes to Docker Hub (`satputekuldip/laravel-base`)
-   Also pushes to GitHub Container Registry (`ghcr.io/<owner>/<repo>`) if configured

Update the workflow and secrets in `.github/workflows/deploy.yml` if you need to change registry credentials or image names.
