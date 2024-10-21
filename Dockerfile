FROM integralsw/osa-python:11.2-2-g667521a3-20220403-190332-refcat-43.0-heasoft-6.32.1-python-3.10.11

RUN python -V

SHELL [ "bash", "-c" ]


RUN cat /init.sh

# these will be mounted at runtime
ENV DISPATCHER_CONFIG_FILE=/dispatcher/conf/conf.d/osa_data_server_conf.yml

ADD requirements.txt /requirements.txt
ADD cdci_data_analysis /cdci_data_analysis

RUN source /init.sh && \
	pip install pip --upgrade && \
    pip install -r /requirements.txt \
                /cdci_data_analysis

WORKDIR /data/dispatcher_scratch

ADD entrypoint.sh /dispatcher/entrypoint.sh
ENTRYPOINT bash /dispatcher/entrypoint.sh