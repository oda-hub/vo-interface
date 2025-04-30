#!/bin/bash

cat <<EOF > kind_cluster_config.yml
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
  - role: control-plane
    extraMounts:
      - hostPath: ${DISPATCHER_CONFIG_DIR}
        containerPath: /dispatcher/conf/conf.d
EOF

kind create cluster --config kind_cluster_config.yml
