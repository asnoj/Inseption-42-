*This project has been created as part of the 42 curriculum by jcrochet.*

# Inception - 42 Project

## Description

The **Inception** project at 42 aims to broaden system administration and DevOps skills by setting up a complete, multi-container infrastructure using **Docker Compose** on a minimal **Debian Bookworm** system.

The stack consists of three mandatory, isolated services running in separate containers:
1. **NGINX**: Acts as the single entry point to the infrastructure, exposing port `443` with TLS v1.2 and TLS v1.3 encryption using a self-signed SSL certificate.
2. **WordPress + PHP-FPM**: Handles web application logic and listens on port `9000`. Automated initial configuration is managed via `wp-cli`.
3. **MariaDB**: The relational database management system listening on port `3306`, storing persistent WordPress data.

### Main Design Choices & Technical Comparisons

#### 1. Virtual Machines vs Docker Containers
* **Virtual Machines (VMs)** hypervise complete hardware and run an entire guest operating system with its own kernel. This creates high overhead in terms of CPU, RAM, and boot time.
* **Docker Containers** share the host operating system kernel and isolate processes using Linux namespaces and control groups (`cgroups`). Containers are lightweight, start in seconds, and consume significantly fewer system resources.

#### 2. Secrets vs Environment Variables
* **Environment Variables (`.env`)**: Embedded in the container's environment space. They are accessible by any process inside the container and can be inspected via `docker inspect`, making them unsuitable for sensitive data.
* **Docker Secrets**: Securely mounts sensitive data (passwords, API keys) into a temporary in-memory filesystem (`tmpfs`) at `/run/secrets/<secret_name>` inside the container. Secrets do not persist on container disk images and are protected against inspection leaks.

#### 3. Docker Network vs Host Network
* **Host Network (`network_mode: host`)**: Removes network isolation between the container and the host. The container directly uses the host's network interfaces, creating potential port conflicts and security vulnerabilities.
* **Docker Network (`bridge`)**: Creates an isolated virtual network bridge. Containers communicate securely using container names as internal DNS hostnames (e.g., `mariadb:3306`), exposing only designated ports (e.g., `443` for NGINX) to the outside world.

#### 4. Docker Volumes vs Bind Mounts
* **Docker Volumes**: Managed directly by Docker in its storage directory (`/var/lib/docker/volumes/`). Fully isolated from host directory structures.
* **Bind Mounts**: Maps an explicit, absolute directory on the host machine (e.g., `/home/jcrochet/data/wp`) directly to a mount point inside the container. In this project, named volumes with `local` driver and `bind` options are used to enforce persistence under the specified `/home/jcrochet/data/` path.

---

## Instructions

### Prerequisites
* Linux environment (Debian 12 / Arch Linux / 42 cluster host).
* Docker (`docker-ce`) and Docker Compose (`docker compose`).
* `make` utility.

### Build and Launch
1. Ensure your local domain mapping exists in `/etc/hosts`:
   ```bash
   127.0.0.1 jcrochet.42.fr
   ```
2. Build and start the infrastructure in detached mode:
   ```bash
   make
   ```
3. Access the web application in your browser:
   * URL: `https://jcrochet.42.fr` (or `https://jcrochet.42.fr:8443` if tunneling).

### Management Commands
* **Stop containers**: `make stop`
* **Restart containers**: `make start`
* **Tear down stack**: `make down`
* **Complete purge**: `make fclean`
* **Rebuild everything**: `make re`

---

## Resources

* [Official Docker Documentation](https://docs.docker.com/)
* [Docker Compose Specification](https://docs.docker.com/compose/)
* [NGINX Beginner's Guide](https://nginx.org/en/docs/beginners_guide.html)
* [MariaDB Knowledge Base](https://mariadb.com/kb/en/)
* [WP-CLI Command Reference](https://developer.wordpress.org/cli/commands/)

### AI Usage Description
During the development of this project, **Gemini 3 Flash** was utilized as a pedagogical mentor and technical writing assistant for:
* Diagnosing Docker container startup failures and MariaDB socket creation issues (`/run/mysqld`).
* Verifying Shell script syntax (`docker-entrypoint.sh`) and ensuring proper process execution (`exec "$@"` under PID 1).
* Drafting clear, standardized Markdown documentation files (`README.md`, `USER_DOC.md`, `DEV_DOC.md`) according to the project requirements.
