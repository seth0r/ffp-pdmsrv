REPO=https://github.com/wlanslovenija/tunneldigger.git

all: broker client
.PHONY: all

broker: rev_broker deps_run
.PHONY: broker

rev_broker: rev_repo deps_build
	cd repo/broker ; python setup.py install
	cp rev_repo rev_broker

deps_run:
	apt-get install -y \
		iptables iproute2 bridge-utils \
		libnfnetlink0 libnetfilter-conntrack3 \
		python-cffi python-netfilter 
	touch deps_run

deps_build:
	apt-get install -y \
		build-essential python python-setuptools python-dev \
		libnfnetlink-dev libnetfilter-conntrack-dev libffi-dev libevent-dev
	touch deps_build

repo:
	git clone "${REPO}" repo

gitpull: repo
	cd repo ; \
	git pull ; \
	if [ "`cat ../rev_repo 2>/dev/null`" != "`git rev-parse HEAD`" ]; then git rev-parse HEAD > ../rev_repo ; fi
.PHONY: gitpull

rev_repo: repo gitpull

clean:
	rm -rf repo
	rm -f rev_*
	rm -f deps_*
.PHONY: clean
