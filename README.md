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

Base images: `php:8.2-cli-alpine` to `php:8.5-cli-alpine` configured dynamically.

-   System packages: `bash`, `ca-certificates`, `tini`, `postgresql-client`, `mysql-client`
-   Application server: `roadrunner` (`rr` binary pre-installed in `/usr/local/bin/rr`)

Prebuilt PHP extensions & modules:

-   Core & DB: `pdo`, `pdo_mysql`, `pdo_pgsql`
-   Process & Async: `pcntl`, `posix`, `sockets`, `pecl-swoole`
-   Math & Utils: `bcmath`, `iconv`, `fileinfo`, `phar`
-   XML & DOM: `dom`, `tokenizer`, `xml`, `simplexml`, `xmlwriter`, `xmlreader`
-   Media & Compression: `gd`, `zip`, `intl`, `opcache`, `exif`
-   Cache & Connectors: `pecl-redis`, `pecl-rdkafka`, `pecl-mongodb`, `pecl-grpc`, `pecl-protobuf`

Builds use official Alpine precompiled APK packages to avoid heavy compilation overhead (especially under ARM/QEMU emulation). Symlinks are provided for `/usr/local/bin/php` and PHP-FPM binaries.

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
