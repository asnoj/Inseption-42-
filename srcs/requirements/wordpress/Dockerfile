FROM debian:bookworm

# 1. Installation de PHP-FPM, des extensions nécessaires et de cURL/mariadb-client
RUN apt-get update && apt-get install -y \
    php-fpm \
    php-mysqli \
    curl \
    mariadb-client \
    && rm -rf /var/lib/apt/lists/*

# 2. Téléchargement et installation de WP-CLI
RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    && chmod +x wp-cli.phar \
    && mv wp-cli.phar /usr/local/bin/wp

# 3. Modification de la config PHP-FPM pour écouter sur le port 9000 au lieu du socket UNIX
RUN sed -i 's/listen = \/run\/php\/php8.2-fpm.sock/listen = 9000/g' /etc/php/8.2/fpm/pool.d/www.conf

# 4. Copie du script d'initialisation
COPY tools/docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

EXPOSE 9000

ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["php-fpm8.2", "-F"]
