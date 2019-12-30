# ####################################
# Name: Codis 集群环境
# FileVersion: 20191113
# ####################################


DK	:= docker
DC	:= docker-compose


# ####################################
# Config AREA
# ####################################
SVC_HOST := $(shell hostname -a)
SERVER_GROUPS := g1 g2 g3 g4


# ####################################
# Dashboard AREA
# ####################################
status: status-port
start: ginit start-servers start-proxy start-web
stop: stop-web stop-proxy stop-servers
test: test-core
ginit: init-dir

bash:
	docker exec -it codis-g1-s1 bash


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
	for x in $(shell sed -n "/# DATA-DIR-BEGIN/,/# DATA-DIR-END/p" .gitignore | grep -v "#"); do \
		echo "verify dir $$x"; \
		[ -d "$$x" ] || mkdir -p "$$x"; \
	done;


# ####################################
# Web AREA
# ####################################
start-web:
	docker-compose -f codis-web.yml up -d
stop-web:
	docker-compose -f codis-web.yml down


# ####################################
# Proxys AREA
# ####################################
start-proxy:
	docker-compose -f codis-proxy.yml up -d
stop-proxy:
	docker-compose -f codis-proxy.yml down


# ####################################
#　Server Group AREA
# ####################################
start-servers:
	for x in $(SERVER_GROUPS); do docker-compose -f codis-$$x.yml up -d; done;
stop-servers:
	for x in $(SERVER_GROUPS); do docker-compose -f codis-$$x.yml down; done;


# ####################################
# Debug AREA
# ####################################
start-g1-fg:
	docker-compose -f codis-g1.yml up
start-g1:
	docker-compose -f codis-g1.yml up -d
stop-g1:
	docker-compose -f codis-g1.yml down


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
