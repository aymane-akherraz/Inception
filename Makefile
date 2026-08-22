COMPOSE		= docker compose -f srcs/docker-compose.yml

all:
	$(COMPOSE) up -d --build

build:
	$(COMPOSE) build

up:
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
