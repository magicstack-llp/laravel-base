ARG PHP_VERSION=8.5
FROM php:${PHP_VERSION}-cli-alpine AS runtime

LABEL maintainer="Kuldip Satpute <stputekuldip@gmail.com>"

ARG PHP_VERSION=8.5

# Install core runtime utilities and prebuilt PHP packages for the specified version.
# Using prebuilt Alpine packages avoids slow compilation of heavy extensions (ARM/QEMU).
# Dynamically checks package availability before adding to support all PHP versions (8.2..8.5) seamlessly.
RUN set -eux; \
    PHP_NUM="$(echo "${PHP_VERSION}" | tr -d '.')"; \
    PKG_PREFIX="php${PHP_NUM}"; \
    EXTRA_REPOS=""; \
    NPM_PKG="npm"; \
    if [ "${PHP_NUM}" = "82" ]; then \
    EXTRA_REPOS="--repository=https://dl-cdn.alpinelinux.org/alpine/v3.20/main --repository=https://dl-cdn.alpinelinux.org/alpine/v3.20/community"; \
    NPM_PKG="npm<11"; \
    fi; \
    WANTED_PACKAGES=" \
    bash \
    ca-certificates \
    curl \
    tini \
    nodejs \
    postgresql-client \
    mysql-client \
    ${PKG_PREFIX} \
    ${PKG_PREFIX}-fpm \
    ${PKG_PREFIX}-curl \
    ${PKG_PREFIX}-mbstring \
    ${PKG_PREFIX}-mysqli \
    ${PKG_PREFIX}-pgsql \
    ${PKG_PREFIX}-pdo \
    ${PKG_PREFIX}-pdo_mysql \
    ${PKG_PREFIX}-pdo_pgsql \
    ${PKG_PREFIX}-pcntl \
    ${PKG_PREFIX}-bcmath \
    ${PKG_PREFIX}-posix \
    ${PKG_PREFIX}-dom \
    ${PKG_PREFIX}-tokenizer \
    ${PKG_PREFIX}-xml \
    ${PKG_PREFIX}-simplexml \
    ${PKG_PREFIX}-xmlwriter \
    ${PKG_PREFIX}-xmlreader \
    ${PKG_PREFIX}-fileinfo \
    ${PKG_PREFIX}-phar \
    ${PKG_PREFIX}-iconv \
    ${PKG_PREFIX}-gd \
    ${PKG_PREFIX}-zip \
    ${PKG_PREFIX}-intl \
    ${PKG_PREFIX}-opcache \
    ${PKG_PREFIX}-exif \
    ${PKG_PREFIX}-sockets \
    ${PKG_PREFIX}-sodium \
    ${PKG_PREFIX}-pecl-imagick \
    ${PKG_PREFIX}-pecl-redis \
    ${PKG_PREFIX}-pecl-swoole \
    ${PKG_PREFIX}-pecl-rdkafka \
    ${PKG_PREFIX}-pecl-mongodb \
    ${PKG_PREFIX}-pecl-grpc \
    ${PKG_PREFIX}-pecl-protobuf \
    "; \
    apk update ${EXTRA_REPOS} > /dev/null; \
    INSTALL_PACKAGES=""; \
    for pkg in ${WANTED_PACKAGES}; do \
    if [ -n "$(apk search ${EXTRA_REPOS} -e "${pkg}" 2>/dev/null)" ]; then \
    INSTALL_PACKAGES="${INSTALL_PACKAGES} ${pkg}"; \
    else \
    echo "[INFO] Skipping unavailable package: ${pkg}"; \
    fi; \
    done; \
    apk add --no-cache ${EXTRA_REPOS} ${INSTALL_PACKAGES} ${NPM_PKG}; \
    mkdir -p /usr/local/sbin; \
    ln -sf "/usr/bin/${PKG_PREFIX}" /usr/local/bin/php; \
    if [ -f "/usr/sbin/php-fpm${PHP_NUM}" ]; then \
    ln -sf "/usr/sbin/php-fpm${PHP_NUM}" /usr/local/sbin/php-fpm; \
    ln -sf "/usr/sbin/php-fpm${PHP_NUM}" /usr/local/bin/php-fpm; \
    fi

# Copy RoadRunner binary
COPY --from=ghcr.io/roadrunner-server/roadrunner:latest /usr/bin/rr /usr/local/bin/rr

ENTRYPOINT ["tini", "--"]
CMD ["php", "-v"]
