NAME:=ffp-pdmsrv
VOLUMES:=-v ${CURDIR}/data:/data
PORTS:=-p 8942:8942/udp
CONFIG:=config.env

CID=`docker ps | grep ${NAME} | cut -d' ' -f1`

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

log: running
	docker attach --sig-proxy=false "${CID}"
.PHONY: log

shelld: running
	docker exec -it "${CID}" bash
.PHONY: shelld

shellq: running
	docker exec -it "${CID}" qssh.sh
.PHONY: shellq

running:
	test "${CID}" != "" || ( echo -e "Docker container is not running." ; exit 1 )
.PHONY: running

wait10:
	for i in `seq 10`; do \
		test "${CID}" != "" || break ; \
		sleep 1 ; \
	done
.PHONY: wait10

shutdown: running
	-docker exec -it "${CID}" qssh.sh shutdown -h now
.PHONY: shutdown

hardstop:
	-docker stop "${CID}"
.PHONY: hardstop

stop: shutdown wait10 hardstop
	echo "Stopped."
.PHONY: stop

clean: hardstop
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
