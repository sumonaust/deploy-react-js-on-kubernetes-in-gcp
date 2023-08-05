FROM alpine:latest

ARG CONFIG_PATH

# Installing PACKAGES
RUN apk --no-cache add \
                   nginx \
                   php81 \
                   php81-common \
                   php81-cli \
                   php81-fpm \
                   php81-dom \
                   php81-gd \
                   php81-mbstring \
                   php81-xml \
                   php81-intl \
                   php81-curl \
                   php81-gmp \
                   php81-xml \
                   php81-bcmath \
                   php81-pcntl \
                   php81-posix \
                   php81-zip \
                   php81-redis \
                   php81-phar \
                   php81-openssl \
                   php81-ctype \
                   php81-json \
                   php81-opcache \
                   php81-session \
                   php81-zlib \
                   php81-tokenizer \
                   php81-fileinfo \
                   wget \
                   unzip \
                   gcc \
                   bzip2 \
                   git \
                   openssl \
                   curl \
                   vim \
                   supervisor \
                   npm \
                   nodejs \
                   python3 \
                   python3-dev

RUN npm install -g yarn node-gyp

# Make directories
RUN mkdir -p /var/www/html

# Configs
COPY config/supervisord.conf /etc/supervisord.conf
COPY config/nginx.conf /etc/nginx/nginx.conf
COPY config/fpm-pool.conf /etc/php81/php-fpm.d/www.conf
COPY config/php.ini /etc/php81/conf.d/custom.ini

# Entrypoint
COPY --chown=nginx config/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Set Permissions
RUN chown -R nginx /var/www/html && \
    chown -R nginx /run && \
    chown -R nginx /var/lib/nginx && \
    chown -R nginx /var/lib/nginx

# Switch to use non-root user \
USER nginx

# Build the app
COPY --chown=nginx dashboard /var/www/dashboard
COPY --chown=nginx ${CONFIG_PATH}/.env /var/www/dashboard
RUN npm --prefix /var/www/dashboard install
RUN npm --prefix /var/www/dashboard run build
RUN mv /var/www/dashboard/build/* /var/www/html

EXPOSE 8080
EXPOSE 8443

CMD ["nginx", "-g", "daemon off;"]