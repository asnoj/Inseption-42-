# User Documentation - Inception Stack

Welcome to the **Inception** service stack documentation. This guide explains how to run, manage, and interact with the hosted web services.

---

## 1. Services Provided

The infrastructure hosts a secure WordPress publishing platform composed of three interconnected services:

| Service | Technology | Internal Port | Description |
| :--- | :--- | :--- | :--- |
| **Gateway / Web Server** | NGINX | `443` (HTTPS) | Secure reverse proxy using TLS 1.2/1.3. Handles incoming SSL connections and routes PHP requests to WordPress. |
| **Application Engine** | WordPress + PHP-FPM | `9000` (FastCGI) | Processes dynamic PHP requests and manages content rendering. |
| **Database Server** | MariaDB | `3306` (MySQL) | Stores application tables, posts, user data, and system configurations. |

---

## 2. Starting and Stopping the Project

All operational tasks are simplified using the provided `Makefile` located at the project root.

* **Start the stack**:
  ```bash
  make
  ```
* **Stop the running containers**:
  ```bash
  make stop
  ```
* **Resume stopped containers**:
  ```bash
  make start
  ```
* **Tear down containers and network**:
  ```bash
  make down
  ```
* **Purge containers, images, and data volumes**:
  ```bash
  make fclean
  ```

---

## 3. Accessing the Website and Admin Panel

### Website URL
Open your browser and navigate to:
* **Public Site**: `https://jcrochet.42.fr` (or `https://jcrochet.42.fr:8443` when using an SSH tunnel on 42 cluster workstations).

*Note: You must accept the security warning regarding the self-signed SSL certificate on your first visit.*

### WordPress Administration Panel
* **Admin Login URL**: `https://jcrochet.42.fr/wp-admin`
* **Default Admin Username**: Defined in `srcs/.env` under `WP_ADMIN_USER` (e.g., `jcrochet_admin`).

---

## 4. Credentials and Secrets Management

All confidential credentials (database root password, database user password, WordPress admin password, WordPress user password) are **never** hardcoded into scripts or dockerfiles.

* **Location of Secrets**:
  Credentials reside in plain text files inside the `secrets/` directory at the project root:
  * `secrets/db_root_password.txt`
  * `secrets/db_password.txt`
  * `secrets/wp_admin_password.txt`
  * `secrets/wp_user_password.txt`

* **Non-sensitive Environment Variables**:
  General configuration parameters (database name, user handles, domain name) are stored in `srcs/.env`.

---

## 5. Checking Service Health

To verify that all services are operational:

1. **Check container status**:
   ```bash
   docker compose -f srcs/docker-compose.yml ps
   ```
   *All three services (`mariadb`, `wordpress`, `nginx`) should report `Up` or `running`.*

2. **Check container logs**:
   * MariaDB logs: `docker logs mariadb`
   * WordPress logs: `docker logs wordpress`
   * NGINX logs: `docker logs nginx`

3. **HTTP Health Check**:
   ```bash
   curl -I -k https://jcrochet.42.fr
   ```
   *Expected output includes `HTTP/1.1 200 OK` or `HTTP/2 200`.*

---

## 6. Accessing the Website on 42 Cluster Workstations (Without Sudo)

On 42 cluster workstations, modifying `/etc/hosts` or binding host ports below 1024 directly is restricted due to lack of `root` / `sudo` privileges. Follow these procedures to test and view the site from a cluster host.

### A. Terminal HTTP Test (`curl`)
To test domain resolution and HTTP status directly from the cluster host terminal without modifying `/etc/hosts`:

```bash
curl -k --resolve jcrochet.42.fr:443:127.0.0.1 https://jcrochet.42.fr
```

### B. Visual Browser Access (Google Chrome & SSH Tunnel)

1. **Establish an SSH Port Forwarding Tunnel**:
   Forward local port `8443` on the cluster host to port `443` inside the Virtual Machine:
   ```bash
   ssh -p 2222 -L 8443:127.0.0.1:443 jcrochet@127.0.0.1
   ```
   *(Keep this terminal session active).*

2. **Launch Chrome with Host Mapping and SSL Overrides**:
   In a second terminal on the cluster host, execute:
   ```bash
   google-chrome --host-rules="MAP jcrochet.42.fr 127.0.0.1" --ignore-certificate-errors > /dev/null 2>&1 &
   ```

3. **Update WordPress URL for Port 8443 (If CSS breaks):**
   Inside the VM terminal, run:
   ```text
    docker exec -it wordpress wp option update siteurl '[https://jcrochet.42.fr:8443](https://jcrochet.42.fr:8443)' --path=/var/www/wordpress --allow-root
    docker exec -it wordpress wp option update home '[https://jcrochet.42.fr:8443](https://jcrochet.42.fr:8443)' --path=/var/www/wordpress --allow-root
   ```

4. **Navigate to the Site**:
   In the newly opened Chrome browser window, enter the URL:
   ```text
   https://jcrochet.42.fr:8443
   ```
