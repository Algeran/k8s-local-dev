#!/bin/sh
set -o errexit

DOCKER_REGISTRY_NAME=${DOCKER_REGISTRY_NAME:=docker-registry}
KIND_CLUSTER_NAME=${KIND_CLUSTER_NAME:=local-dev}

kind delete cluster --name ${KIND_CLUSTER_NAME}

docker rm -f ${DOCKER_REGISTRY_NAME}
