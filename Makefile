# ####################################
# Name: Codis 集群环境
# FileVersion: 20191113
# ####################################


# ####################################
# Config AREA
# ####################################
SVC_HOST := $(shell hostname -a)
SERVER_GROUPS := g1 g2 g3 g4

include ./.env
-include ../../yh-prod.env

SERVER_RSS := $(SERVER_GROUPS) proxy web
YAML_FILE_GROUPS := $(foreach x,$(SERVER_RSS),-f codis-$(x).yml)

DK	:= docker
DC	:= docker-compose $(YAML_FILE_GROUPS)
DK_EXEC := docker exec -it

DATA_SUF = $(shell date +"%Y.%m.%d.%H.%M.%S")

PROJ_NAME := $(shell basename $(CURDIR))

CMD := bash


# ####################################
# Dashboard AREA
# ####################################
status: status-port
start: up
stop: down
up: init-dir
	$(DC) up -d
down:
	$(DC) down
config:
	$(DC) config
start-fg: init-dir
	$(DC) up

sh:
	docker exec -it codis-g1-s1 $(CMD)
bash: sh

test: test-core


# ####################################
# Status/Info AREA
# ####################################
status-port:
	sudo netstat -lntop | grep docker | sort -n -k4
	docker ps -a | grep codis


# ####################################
# Init AREA
# 	init-dir: 
# ####################################
init-dir:
	# 创建数据目录(-dLf), 也可以直接-e来判存
	$(DC) config | grep ":rw$$" | grep -o " /[^:]*" | grep "/[^.]*$$" | grep -o "[^ ]*" | while read x; do \
		echo "verify dir/link $$x"; \
		[ -d "$$x" -o -L "$$x" -o -f "$$x" ] || mkdir -p "$$x"; \
		echo $$x; \
	done;


# ####################################
# Test AREA
# ####################################
test-core:


# ####################################
# Utils AREA
# ####################################
clean:
	rm -rvf *.bak *.log
	$(DK) ps -a | grep Exited | awk '{print $$1}' | xargs $(DK) rm
