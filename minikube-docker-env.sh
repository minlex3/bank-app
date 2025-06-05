#!/bin/bash
export DOCKER_TLS_VERIFY="1"
export DOCKER_HOST="tcp://127.0.0.1:57301"
export DOCKER_CERT_PATH="$HOME/.minikube/certs"
export MINIKUBE_ACTIVE_DOCKERD="minikube"
echo "To point your shell to minikube's docker-daemon, run:"
echo "eval \$(minikube -p minikube docker-env --shell bash)"