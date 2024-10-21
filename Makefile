version ?= $(shell git describe --always)
version_sortable ?= $(shell git log -1 --format="%at" | xargs -I{} date -d @{} +%y%m%d-%H%M%S)

image=odahub/vo-interface:$(version)
image_sortable=odahub/vo-interface:$(version_sortable)
image_latest=odahub/vo-interface:latest

run: build
	docker run \
		-it \
		-u $(shell id -u) \
		-v /tmp/dev/log:/var/log/containers \
		-v /tmp/dev/workdir:/data/dispatcher_scratch \
		-v $(PWD)/conf:/dispatcher/conf \
		-e DISPATCHER_CONFIG_FILE=/dispatcher/conf/conf.d/osa_data_server_conf.yml \
		-e DISPATCHER_GUNICORN=yes \
		--rm \
		-p 8010:8000 \
		--name dev-oda-dispatcher \
		$(image) 

run-local: build
		docker run \
			-it \
			-u $(shell id -u) \
			-v /tmp/dev/log:/var/log/containers \
			-v /tmp/dev/workdir:/data/dispatcher_scratch \
			-v $(PWD)/conf:/dispatcher/conf \
			-e DISPATCHER_CONFIG_FILE=/dispatcher/conf/conf.d/osa_data_server_conf.yml \
			-e DISPATCHER_GUNICORN=no \
			--rm \
			-p 8010:8000 \
			--name dev-oda-dispatcher \
			$(image) 
