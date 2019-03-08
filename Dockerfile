FROM php:5.6-alpine3.8 as build

RUN curl -o /composer   https://getcomposer.org/download/1.4.3/composer.phar
COPY app/ /app/
WORKDIR /app/
RUN php /composer install --no-interaction --no-scripts --no-progress --optimize-autoloader 

FROM php:5.6-alpine3.8
ENV PATH "$PATH:/app/vendor/bin/"
RUN apk add --virtual build-dependencies --no-cache build-base=0.5-r1 autoconf=2.69-r2 \
    && docker-php-source extract \
    && pecl install xdebug-2.5.5 \
    && docker-php-ext-enable xdebug \
    && docker-php-source delete \
    && apk del build-dependencies \
    && pecl clear-cache \
    && rm -rf /tmp/pear

COPY --from=build /app/ /app/

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
