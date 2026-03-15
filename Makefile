COMPOSE = docker compose -f srcs/docker-compose.yml 

up:
	${COMPOSE} up

down:
	${COMPOSE} down

clean:
	${COMPOSE} down --rmi all

fclean:
	${COMPOSE} down -v --rmi all

re:
	make clean
	make up

setup:
	./scripts/setup-env.sh

.PHONY: re clean fclean down up setup