NAME=ffp-pdmsrv
VOLUMES=-v ${CURDIR}/inside:/data
PORTS=-p 8942:8942/udp
CONFIG=config.env

build:
	docker build -t ${NAME} docker

config:
	test -s ${CONFIG} || ( echo -e "\nconfig.env does not exist or is empty. Exiting...\n" ; exit 1 )

run: build config
	mkdir -p ${CURDIR}/inside
	docker attach --sig-proxy=false `docker run -d --privileged --env-file=${CONFIG}	${VOLUMES} ${PORTS} ${NAME}`

shell:
	docker exec -it `docker ps | grep ${NAME} | cut -d' ' -f1` bash

stop:
	-docker stop `docker ps | grep ${NAME} | cut -d' ' -f1`

log:
	docker attach --sig-proxy=false `docker ps | grep ${NAME} | cut -d' ' -f1`

clean: stop
	-mv ${CURDIR}/inside/netinst.iso ${CURDIR}/netinst.iso
	-rm -rf ${CURDIR}/inside
	mkdir -p ${CURDIR}/inside
	-mv ${CURDIR}/netinst.iso ${CURDIR}/inside/netinst.iso

cleanall: stop
	-rm -rf ${CURDIR}/inside
