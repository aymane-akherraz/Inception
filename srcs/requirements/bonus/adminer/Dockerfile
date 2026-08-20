FROM debian:bookworm

RUN apt update && \
    apt install php-fpm php-mysql wget -y && \
    rm -rf /var/lib/apt/lists/*

RUN mkdir -p /var/www/html && \
    wget -O /var/www/html/index.php \
    https://www.adminer.org/latest-mysql.php

COPY conf/config.conf /etc/php/8.2/fpm/pool.d/www.conf

EXPOSE 9000

ENTRYPOINT ["php-fpm8.2", "-F"]
