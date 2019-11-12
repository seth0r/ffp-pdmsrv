NAME=ffp-pdmsrv
VOLUMES=-v ${CURDIR}/data:/data
PORTS=-p 8942:8942/udp
CONFIG=config.env

build:
	docker build -t ${NAME} docker
.PHONY: build

config:
	test -s ${CONFIG} || ( echo -e "\nconfig.env does not exist or is empty. Exiting...\n" ; exit 1 )
.PHONY: config

run: build config
	mkdir -p ${CURDIR}/data
	docker run -d --privileged --env-file=${CONFIG}	${VOLUMES} ${PORTS} ${RUNARGS} ${NAME}
.PHONY: run

runlog: run log
.PHONY: runlog

log:
	docker attach --sig-proxy=false "`docker ps | grep ${NAME} | cut -d' ' -f1`"
.PHONY: log

shelld:
	docker exec -it "`docker ps | grep ${NAME} | cut -d' ' -f1`" bash
.PHONY: shelld

shellq:
	docker exec -it "`docker ps | grep ${NAME} | cut -d' ' -f1`" ssh 172.22.255.42
.PHONY: shellq

shutdown:
	-docker exec -it "`docker ps | grep ${NAME} | cut -d' ' -f1`" ssh 172.22.255.42 shutdown -h now
.PHONY: shutdown

stop: shutdown
	-docker stop "`docker ps | grep ${NAME} | cut -d' ' -f1`"
.PHONY: stop

clean: stop
	rm -rf ${CURDIR}/data/tmp
	rm -rf ${CURDIR}/data/*.tmp
	rm -rf ${CURDIR}/data/*.img
	rm -rf ${CURDIR}/data/qemu.*
.PHONY: clean

cleanall: clean
	rm -rf ${CURDIR}/data
.PHONY: cleanall

inside:
	${MAKE} -C inside
.PHONY: inside
