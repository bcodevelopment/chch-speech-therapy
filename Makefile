BASE_DIR := $(CURDIR)


help:
	@echo "There is no help"
	@echo "Base Directory is [$(BASE_DIR)]"

# ===================================================================
# Variables
NAME_PREFIX := my

# MySQL Variables
MYSQL_IMAGE_NAME := mysql
MYSQL_CONTAINER_NAME := $(NAME_PREFIX)-mysql
MY_ROOT_PASSWORD := plumbum

# NGINX Variables
NGINX_IMAGE_NAME := nginx
NGINX_CONTAINER_NAME := $(NAME_PREFIX)-nginx

# PHP Variables
PHP_IMAGE_NAME := php:5-fpm
PHP_CONTAINER_NAME := $(NAME_PREFIX)-php5-fpm

# Network Variables
ISOLATED_NETWORK_NAME := isolated_network


# ===================================================================
# Targets

# Create isolated network for docker images
network_create:
	docker network create --driver bridge $(ISOLATED_NETWORK_NAME)

# ==================================================================

# GIT targets
git-fetch:
	cd $(BASE_DIR)/content/startbootstrap-freelancer && git fetch

git-pull:
	cd $(BASE_DIR)/content/startbootstrap-freelancer && git pull

dist:
	rsync -av --recursive --exclude=".*" $(BASE_DIR)/content/* $(BASE_DIR)/html
	rsync -av --recursive --exclude=".*" $(BASE_DIR)/frameworks/bootstrap/dist/* $(BASE_DIR)/html
	
# MYSQL Targets
run_mysql:
	docker run \
		--net=$(ISOLATED_NETWORK_NAME) \
		--name=$(MYSQL_CONTAINER_NAME) \
		--detach \
		--env=MYSQL_ROOT_PASSWORD=$(MY_ROOT_PASSWORD) \
		$(MYSQL_IMAGE_NAME)

start_mysql:
	docker start $(MYSQL_CONTAINER_NAME)

stop_mysql:
	docker stop $(MYSQL_CONTAINER_NAME)

rm_mysql:
	docker rm $(MYSQL_CONTAINER_NAME)

logs_mysql:
	docker logs $(MYSQL_CONTAINER_NAME)   	

# ==================================================================
# NGINX Targets


run-nginx: dist
	docker run \
		-p 80:80 \
		--net=$(ISOLATED_NETWORK_NAME) \
		--name=$(NGINX_CONTAINER_NAME) \
		--detach \
		--volume $(BASE_DIR)/my-nginx:/etc/nginx/conf.d:ro \
		--volume $(BASE_DIR)/my-nginx/tmp:/tmp \
		--volume $(BASE_DIR)/html:/var/www/html \
		$(NGINX_IMAGE_NAME)

start-nginx:
	docker start $(NGINX_CONTAINER_NAME)

stop-nginx:
	docker stop $(NGINX_CONTAINER_NAME)

rm-nginx:
	docker rm $(NGINX_CONTAINER_NAME)

restart-nginx: stop-nginx rm-nginx run-nginx
	echo "restart nginx"

logs-nginx:
	docker logs $(NGINX_CONTAINER_NAME)

# ==================================================================
# PHP5-FPM targets
# this docker container runs the php daemon

run_php:
	docker run \
		--net=$(ISOLATED_NETWORK_NAME) \
		--name=$(PHP_CONTAINER_NAME) \
		--volume $(BASE_DIR)/html:/var/www/html \
		-w /var/www/html \
		--detach \
		$(PHP_IMAGE_NAME)

logs_php:
	docker logs $(PHP_CONTAINER_NAME)

start_php:
	docker start $(PHP_CONTAINER_NAME)

stop_php:
	docker stop $(PHP_CONTAINER_NAME)

rm_php:
	docker rm $(PHP_CONTAINER_NAME)

# Combination Targets
logs: logs_nginx logs_mysql logs_php
	echo "all logs printed"

stop: stop_php stop_mysql stop-nginx
	echo "all containers stopped"

start: start_mysql start_php start-nginx
	@docker ps

rm: rm-nginx rm_php rm_mysql
	@echo "all containers removed"

run: run_mysql run_php run-nginx
	@echo " all containers running"