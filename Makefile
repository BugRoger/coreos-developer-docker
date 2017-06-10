COREOS_TRACK   ?= beta
COREOS_VERSION ?= 1409.1.0

.PHONY: all
all:
	curl -L https://${COREOS_TRACK}.release.core-os.net/amd64-usr/${COREOS_VERSION}/coreos_developer_container.bin.bz2 -o coreos_developer_container.bin.bz2
	bunzip2 -k coreos_developer_container.bin.bz2
	mkdir -p /mnt/${COREOS_VERSION}
	mount -o ro,loop,offset=2097152 coreos_developer_container.bin /mnt/${COREOS_VERSION}
	tar -cp --one-file-system -C /mnt/${COREOS_VERSION} . | docker import - bugroger/coreos-developer:${COREOS_VERSION}
	docker push bugroger/coreos-developer:${COREOS_VERSION}
