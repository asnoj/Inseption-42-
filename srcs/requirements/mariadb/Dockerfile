FROM debian:bookworm

# 1. Installation de MariaDB
RUN apt-get update && apt-get install -y \
    mariadb-server \
    mariadb-client \
    && rm -rf /var/lib/apt/lists/*

# 2. Copie d'un script d'initialisation (création BDD et utilisateurs)
COPY tools/docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

# 3. Port MySQL/MariaDB
EXPOSE 3306

# 4. Point d'entrée pour initialiser et démarrer MariaDB en PID 1
ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["mariadbd", "--user=mysql", "--bind-address=0.0.0.0"]
