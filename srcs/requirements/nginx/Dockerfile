FROM debian:bookworm

# 1. Installation de NGINX et OpenSSL
RUN apt-get update && apt-get install -y \
    nginx \
    openssl \
    && rm -rf /var/lib/apt/lists/*

# 2. Génération du certificat SSL/TLS auto-signé
RUN openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout /etc/ssl/private/nginx-selfsigned.key \
    -out /etc/ssl/certs/nginx-selfsigned.crt \
    -subj "/C=FR/ST=IDF/L=Paris/O=42/OU=42/CN=jcrochet.42.fr/UID=jcrochet"

# 3. Copie du fichier de configuration NGINX personnalisé
COPY conf/nginx.conf /etc/nginx/conf.d/default.conf

# 4. Port HTTPS uniquement
EXPOSE 443

# 5. Démarrage de NGINX au premier plan (PID 1)
CMD ["nginx", "-g", "daemon off;"]

