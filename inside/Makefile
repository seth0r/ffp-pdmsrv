
inside: checkinside
	apt update
	apt full-upgrade
	echo "Yeah!" > /root/x

checkinside:
	test -f /root/.inside__qemu || ( echo -e "This target should only be executed inside the VM. Exiting...\n" ; exit 1 )
