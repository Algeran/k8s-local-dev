#!/bin/sh
set -o errexit

DOCKER_REGISTRY_NAME=${DOCKER_REGISTRY_NAME:=docker-registry}
DOCKER_REGISTRY_PORT=${DOCKER_REGISTRY_PORT:=5001}
KIND_CLUSTER_NAME=${KIND_CLUSTER_NAME:=local-dev}
KIND_NODE_IMAGE=${KIND_NODE_IMAGE:=kindest/node:v1.25.3@sha256:f52781bc0d7a19fb6c405c2af83abfeb311f130707a0e219175677e366cc45d1}

# create registry container unless it already exists
if [ "$(docker inspect -f '{{.State.Running}}' "${DOCKER_REGISTRY_NAME}" 2>/dev/null || true)" != 'true' ]; then
  docker run \
    -d --restart=always -p "127.0.0.1:${DOCKER_REGISTRY_PORT}:5000" --name "${DOCKER_REGISTRY_NAME}" \
    registry:2
fi

# create a cluster with the local registry enabled in containerd
cat <<EOF | kind create cluster --config=-
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
name: ${KIND_CLUSTER_NAME}
containerdConfigPatches:
- |-
  [plugins."io.containerd.grpc.v1.cri".registry.mirrors."localhost:${DOCKER_REGISTRY_PORT}"]
    endpoint = ["http://${DOCKER_REGISTRY_NAME}:5000"]
nodes:
  - role: control-plane
    image: ${KIND_NODE_IMAGE}
EOF

# connect the registry to the cluster network if not already connected
if [ "$(docker inspect -f='{{json .NetworkSettings.Networks.kind}}' "${DOCKER_REGISTRY_NAME}")" = 'null' ]; then
  docker network connect "kind" "${DOCKER_REGISTRY_NAME}"
fi

kubectl config use-context kind-${KIND_CLUSTER_NAME}

# Document the local registry
# https://github.com/kubernetes/enhancements/tree/master/keps/sig-cluster-lifecycle/generic/1755-communicating-a-local-registry
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: ConfigMap
metadata:
  name: local-registry-hosting
  namespace: kube-public
data:
  localRegistryHosting.v1: |
    host: "localhost:${DOCKER_REGISTRY_PORT}"
    help: "https://kind.sigs.k8s.io/docs/user/local-registry/"
EOF
