SHELL:=/bin/bash


## DBus within the container needs a "machine id" to work properly
MACHINEID?=$(shell if test -f /etc/machine-id; then            \
                     cat /etc/machine-id;                      \
                   elif test -f /var/lib/dbus/machine-id; then \
                     at /var/lib/dbus/machine-id;              \
                   fi)


default: docker-freipose

.PHONY: docker-freipose

docker-freipose:
	docker build                                  \
	       -f Dockerfile                          \
	       -t $@                                  \
	       --build-arg machine_id=$(MACHINEID) \
	       --build-arg uid=$$UID                  \
	       --build-arg gid=$$GROUPS               \
	       --build-arg username=$$USER            \
.
