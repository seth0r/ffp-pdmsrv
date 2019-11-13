inside: checkinside upgrade subs
.PHONY: inside

checkinside:
	test -f /root/.inside_qemu || ( echo -e "This target should only be executed inside the VM. Exiting...\n" ; exit 1 )
.PHONY: checkinside

upgrade:
	apt-get update
	apt-get upgrade
.PHONY: upgrade

SUBDIRS := $(wildcard */.)

subs: $(SUBDIRS)
$(SUBDIRS):
	$(MAKE) -C $@
.PHONY: subs $(SUBDIRS)

clean:
	for dir in $(SUBDIRS); do \
		$(MAKE) -C $$dir clean; \
	done
.PHONY: clean
