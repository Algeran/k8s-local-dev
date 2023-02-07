# k8s-local-dev

This repo specifies scripts to deploy and configure a simple dev environment including:
- kubernetes cluster (kind, single node)
- local docker repository (connected to the k8s cluster)

You can use this repo as a part of your application repository

## Requirements

- docker engine
- [kind](https://kind.sigs.k8s.io/docs/user/quick-start/)
- [kubectl client](https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/)

## Available configuration

You can change the configuration by passing environment variables: 

| Variable name            | Description                                                                                                                  | Default value                                                                                |
|--------------------------|------------------------------------------------------------------------------------------------------------------------------|----------------------------------------------------------------------------------------------|
| **DOCKER_REGISTRY_NAME** | container name of the local docker registry.                                                                                 | docker-registry                                                                              |
| **DOCKER_REGISTRY_PORT** | local docker registry port. This port will be used to tag docker images, e.g. `localhost:5001/my-app:1.1.1`                  | 5001                                                                                         |
| **KIND_CLUSTER_NAME**    | the name of the kind cluster                                                                                                 | local-dev                                                                                    |
| **KIND_NODE_IMAGE**      | [k8s kind image](https://github.com/kubernetes-sigs/kind/releases). By default will be bootstrapped kubernetes cluster v1.25 | kindest/node:v1.25.3@sha256:f52781bc0d7a19fb6c405c2af83abfeb311f130707a0e219175677e366cc45d1 |
