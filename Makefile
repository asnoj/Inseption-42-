NAME = inception
COMPOSE_FILE = srcs/docker-compose.yml

all: build up

build:
	@mkdir -p /home/jcrochet/data/db /home/jcrochet/data/wp
	docker compose -f $(COMPOSE_FILE) build

up:
	@mkdir -p /home/jcrochet/data/db /home/jcrochet/data/wp
	docker compose -f $(COMPOSE_FILE) up -d

down:
	docker compose -f $(COMPOSE_FILE) down

stop:
	docker compose -f $(COMPOSE_FILE) stop

start:
	docker compose -f $(COMPOSE_FILE) start

clean: down
	docker system prune -a --force

fclean: clean
	@sudo rm -rf /home/jcrochet/data
	@docker volume rm $$(docker volume ls -q) 2>/dev/null || true

re: fclean all

.PHONY: all build up down stop start clean fclean re
