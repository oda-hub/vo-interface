version ?= $(shell git describe --always)

IMAGE=odahub/vo-interface:$(version)
IMAGE_LATEST=odahub/vo-interface:latest

DISPATCHER_CONFIG_DIR?="$(PWD)/conf"
DISPATCHER_CONFIG_FILE?="/dispatcher/conf/conf.d/osa_data_server_conf.yml"

run: build
	docker run \
		-it \
		-v $(DISPATCHER_CONFIG_DIR):/dispatcher/conf/conf.d \
		-e DISPATCHER_GUNICORN=yes \
		-e DISPATCHER_CONFIG_FILE=$(DISPATCHER_CONFIG_FILE) \
		--rm \
		--name dev-oda-dispatcher \
		$(IMAGE) 

run-local: build
		docker run \
			-it \
			-v $(DISPATCHER_CONFIG_DIR):/dispatcher/conf/conf.d \
			-e DISPATCHER_GUNICORN=no \
			-e DISPATCHER_CONFIG_FILE=$(DISPATCHER_CONFIG_FILE) \
			--network=host \
			--rm \
			--name dev-oda-dispatcher \
			$(IMAGE) 

build: Dockerfile
	docker build . -t $(IMAGE)
	docker build . -t $(IMAGE_LATEST)

build-no-cache: Dockerfile
	docker build . --no-cache -t $(IMAGE)
	docker build . --no-cache -t $(IMAGE_LATEST)