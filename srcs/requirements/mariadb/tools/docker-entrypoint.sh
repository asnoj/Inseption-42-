#!/bin/sh
set -e

# Création du dossier nécessaire pour le socket UNIX
mkdir -p /run/mysqld
chown -R mysql:mysql /run/mysqld /var/lib/mysql

# 1. Lecture des secrets depuis /run/secrets/
MYSQL_ROOT_PASSWORD=$(cat /run/secrets/db_root_password)
MYSQL_PASSWORD=$(cat /run/secrets/db_password)

# 2. Vérification si la base de données existe déjà dans le volume
if [ ! -d "/var/lib/mysql/$MYSQL_DATABASE" ]; then

    # Initialisation des dossiers de données système MySQL
    mariadb-install-db --user=mysql --datadir=/var/lib/mysql > /dev/null

    # Démarrage temporaire de MariaDB sans réseau pour exécuter le SQL d'initialisation
    mariadbd --user=mysql --bootstrap << EOF
USE mysql;
FLUSH PRIVILEGES;

-- Configuration du compte root
ALTER USER 'root'@'localhost' IDENTIFIED BY '$MYSQL_ROOT_PASSWORD';

-- Création de la base de données WordPress
CREATE DATABASE IF NOT EXISTS \`$MYSQL_DATABASE\`;

-- Création de l'utilisateur WordPress et attribution des droits
CREATE USER IF NOT EXISTS '$MYSQL_USER'@'%' IDENTIFIED BY '$MYSQL_PASSWORD';
GRANT ALL PRIVILEGES ON \`$MYSQL_DATABASE\`.* TO '$MYSQL_USER'@'%';

FLUSH PRIVILEGES;
EOF
fi

# 3. Lancement du processus principal au premier plan (PID 1)
exec "$@"
