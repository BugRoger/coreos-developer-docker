COREOS_TRACK   ?= beta
COREOS_VERSION ?= 1409.1.0

.PHONY: all
all:
	curl -L https://${COREOS_TRACK}.release.core-os.net/amd64-usr/${COREOS_VERSION}/coreos_developer_container.bin.bz2 -o coreos_developer_container.bin.bz2
	bunzip2 -k coreos_developer_container.bin.bz2
	sudo systemd-nspawn -i coreos_developer_container.bin.bz2 \
		--bind=${PWD}/bin2docker.sh:/bin2docker.sh \
		--bind=${PWD}:/mnt/host \
		/bin/bash -x /bin2docker.sh
	docker load -i coreos_developer_container.tar

