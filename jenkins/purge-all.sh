#!/bin/bash
set -euo pipefail

# Предупреждение
echo -e "\033[1;31m⚠️  WARNING: This script will DESTROY ALL Jenkins and application data!\033[0m"
echo -e "\033[1;33mThis includes:\n- All Helm releases\n- Kubernetes namespaces (test/prod)\n- Docker containers and volumes\n- Jenkins data\033[0m"
read -r -p "Are you absolutely sure? (type 'yes' to confirm): " answer
if [ "$answer" != "yes" ]; then
    echo "Aborted."
    exit 1
fi

# Загрузка переменных из .env
if [ -f .env ]; then
    # Безопасная загрузка переменных
    export $(grep -v '^#' .env | xargs -d '\n')
else
    echo ".env file not found, proceeding with current environment"
fi

# Проверка обязательных переменных
required_vars=("DOCKER_REGISTRY")
for var in "${required_vars[@]}"; do
    if [ -z "${!var:-}" ]; then
        echo "ERROR: $var is not set in .env" >&2
        exit 1
    fi
done

echo -e "\n\033[1;34mUsing DOCKER_REGISTRY: $DOCKER_REGISTRY\033[0m"

# Функция для обработки ошибок Helm
uninstall_helm() {
    local release=$1
    local namespace=$2
    if helm status "$release" -n "$namespace" &>/dev/null; then
        echo "Uninstalling $release from $namespace..."
        helm uninstall "$release" -n "$namespace"
    else
        echo "$release not found in $namespace, skipping..."
    fi
}

# Удаление Helm-релизов
releases=(
    "exchange-application"
    "blocker-application"
    "exchange-generator-application"
    "notifications-application"
    "accounts-application"
    "cash-application"
    "transfer-application"
    "bank-ui-application"
    "db"
    "keycloak"
)

for ns in test prod; do
    echo -e "\n\033[1;36mProcessing namespace: $ns\033[0m"
    for release in "${releases[@]}"; do
        uninstall_helm "$release" "$ns"
    done

    # Удаление секретов
    secrets=("yabank-db" "yabank-keycloak" "yabank-postgresql")
    for secret in "${secrets[@]}"; do
        if kubectl get secret "$secret" -n "$ns" &>/dev/null; then
            echo "Deleting secret $secret from $ns..."
            kubectl delete secret "$secret" -n "$ns"
        fi
    done
done

# Удаление неймспейсов
for ns in test prod; do
    if kubectl get ns "$ns" &>/dev/null; then
        echo "Deleting namespace $ns..."
        kubectl delete ns "$ns"
    fi
done

# Остановка Jenkins
echo -e "\n\033[1;35mCleaning up Jenkins...\033[0m"
docker compose down -v --remove-orphans || true
docker stop jenkins || true
docker rm jenkins || true
docker volume rm jenkins_home || true

# Удаление образов
images=(
    "${DOCKER_REGISTRY}/exchange-application:1"
    "${DOCKER_REGISTRY}/blocker-application:1"
    "${DOCKER_REGISTRY}/exchange-generator-application:1"
    "${DOCKER_REGISTRY}/notifications-application:1"
    "${DOCKER_REGISTRY}/accounts-application:1"
    "${DOCKER_REGISTRY}/cash-application:1"
    "${DOCKER_REGISTRY}/transfer-application:1"
    "jenkins/jenkins:lts-jdk21"
)

for image in "${images[@]}"; do
    if docker image inspect "$image" &>/dev/null; then
        echo "Removing image $image..."
        docker image rm "$image" || true
    fi
done

# Очистка Docker
echo -e "\n\033[1;32mPruning system...\033[0m"
docker system prune -af --volumes

echo -e "\n\033[1;32m✅ Done! Environment has been completely cleaned.\033[0m"