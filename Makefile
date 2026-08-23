COMPOSE		= docker compose -f srcs/docker-compose.yml
DATA_DIR    = /home/aakherra/data

all:
	mkdir -p $(DATA_DIR)/mariadb
	mkdir -p $(DATA_DIR)/wordpress
	$(COMPOSE) up -d --build

build:
	$(COMPOSE) build

up:
	mkdir -p $(DATA_DIR)/mariadb
	mkdir -p $(DATA_DIR)/wordpress
	$(COMPOSE) up -d

down:
	$(COMPOSE) down

start:
	$(COMPOSE) start

stop:
	$(COMPOSE) stop

restart:
	$(COMPOSE) restart

ps:
	$(COMPOSE) ps

clean:
	$(COMPOSE) down

fclean:
	$(COMPOSE) down -v --rmi all

re:
	$(MAKE) fclean
	$(MAKE) all

.PHONY: all build up down start stop restart logs ps clean fclean re
