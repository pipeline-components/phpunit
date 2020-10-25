FROM composer:1.10.15 as build

COPY app/ /app/
RUN composer install --no-interaction --no-scripts --no-progress
WORKDIR /app/

FROM pipelinecomponents/base-entrypoint:0.2.0 as entrypoint

FROM php:7.4.6-alpine3.10

COPY --from=entrypoint /entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
ENV DEFAULTCMD phpunit

ENV PATH "$PATH:/app/vendor/bin/"
RUN apk add --no-cache 	curl=7.66.0-r0 \
    && apk add --virtual build-dependencies --no-cache build-base=0.5-r1 autoconf=2.69-r2 \
    && docker-php-source extract \
    && pecl install xdebug-2.9.0 \
    && docker-php-ext-enable xdebug \
    && docker-php-source delete \
    && apk del build-dependencies \
    && pecl clear-cache \
    && rm -rf /tmp/pear

COPY --from=build /app/ /app/
COPY php.ini /usr/local/etc/php/php.ini

WORKDIR /code/
# Build arguments
ARG BUILD_DATE
ARG BUILD_REF

# Labels
LABEL \
    maintainer="Robbert Müller <spam.me@grols.ch>" \
    org.label-schema.description="PHPUnit in a container for gitlab-ci" \
    org.label-schema.build-date=${BUILD_DATE} \
    org.label-schema.name="PHPUnit" \
    org.label-schema.schema-version="1.0" \
    org.label-schema.url="https://pipeline-components.gitlab.io/" \
    org.label-schema.usage="https://gitlab.com/pipeline-components/phpunit/blob/master/README.md" \
    org.label-schema.vcs-ref=${BUILD_REF} \
    org.label-schema.vcs-url="https://gitlab.com/pipeline-components/phpunit/" \
    org.label-schema.vendor="Pipeline Components"
