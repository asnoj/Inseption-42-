#!/bin/sh
set -e

# 1. Lecture des secrets
MYSQL_PASSWORD=$(cat /run/secrets/db_password)
WP_ADMIN_PASSWORD=$(cat /run/secrets/wp_admin_password)
WP_USER_PASSWORD=$(cat /run/secrets/wp_user_password)

cd /var/www/wordpress

# 2. Attente de MariaDB
echo "Vérification de la connexion à MariaDB..."
while ! mariadb-admin ping -h mariadb -u"$MYSQL_USER" -p"$MYSQL_PASSWORD" --silent; do
    sleep 2
done

# 3. Téléchargement et installation de WordPress (si pas encore installé)
if [ ! -f "wp-config.php" ]; then
    echo "Téléchargement de WordPress..."
    wp core download --allow-root

    echo "Création du fichier wp-config.php..."
    wp config create \
        --dbname="$MYSQL_DATABASE" \
        --dbuser="$MYSQL_USER" \
        --dbpass="$MYSQL_PASSWORD" \
        --dbhost="mariadb:3306" \
        --allow-root

    echo "Installation du cœur de WordPress..."
    wp core install \
        --url="https://$DOMAIN_NAME" \
        --title="Inception 42" \
        --admin_user="$WP_ADMIN_USER" \
        --admin_password="$WP_ADMIN_PASSWORD" \
        --admin_email="$WP_ADMIN_EMAIL" \
        --skip-email \
        --allow-root

    echo "Création de l'utilisateur secondaire..."
    wp user create \
        "$WP_USER" "$WP_USER_EMAIL" \
        --role=author \
        --user_pass="$WP_USER_PASSWORD" \
        --allow-root
fi

# 4. Lancement de PHP-FPM au premier plan (PID 1)
exec "$@"
