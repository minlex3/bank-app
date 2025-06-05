# Bank-app

### Микросервисное приложение банка

## Установка и запуск приложения

#### Требования:

- JDK 21 (Для локального запуска)
- PostgreSQL (Для локального запуска)
- Gradle
- Docker + Docker Compose

## Функционал

Приложение состоит из нескольких микросервисов:

- Front UI — Веб-приложение с клиентским интерфейсом
- Accounts — Сервис управления аккаунтами и счетами
- Cash — Сервис пополнения и снятия наличных
- Transfer — Сервис транзакций между счетами
- Exchange — Сервис конвертации валют
- Exchange Generator — Сервис генерации курсов валют
- Blocker — Сервис блокировки подозрительных транзакций
- Notifications — Сервис уведомлений

### Технологии

- ЯП и фреймворк: Java 21 + Spring Boot
- БД: PostgreSQL + Liquibase
- Контейнеризация: Helm + Kubernetes
- Орекстрация: Docker Compose
- Авторизация: OAuth 2.0
- CI/CD: Jenkins

#### Запуск приложения:

1. Клонирование репозитория в выбранную директорию
2. Сборка приложения командой `gradle build`
3. Запуск Minikube `minikube start`
4. Запуск окружения для Minikube `minikube docker-env >minikube-docker-env.sh`
   (Возможно потребуется выставить права для файла `chmod +x minikube-docker-env.sh`)
5. Получение bitnamicharts

```bash
  helm pull oci://registry-1.docker.io/bitnamicharts/keycloak --version 24.7.3
   helm pull oci://registry-1.docker.io/bitnamicharts/postgresql --version 14.2.3
   ```

6. Сборка Docker-образов

```bash 
   docker images
   minikube image ls   
   docker build -t exchange-generator-application:0.0.1-SNAPSHOT ./exchangeGeneratorApplication
   docker build -t notifications-application:0.0.1-SNAPSHOT ./notificationsApplication
   docker build -t blocker-application:0.0.1-SNAPSHOT ./blockerApplication
   docker build -t exchange-application:0.0.1-SNAPSHOT ./exchangeApplication
   docker build -t accounts-application:0.0.1-SNAPSHOT ./accountsApplication
   docker build -t cash-application:0.0.1-SNAPSHOT ./cashApplication   
   docker build -t transfer-application:0.0.1-SNAPSHOT ./transferApplication
   docker build -t bank-ui-application:0.0.1-SNAPSHOT ./bankUIApplication
```

7. Запуск helm
   ```bash
   helm dependency update .
   helm install yabank ./
   ```

### Тестирование

Для запуска тестов можно воспользоваться командой `gradle test`.

### Авторизация и аутентификация

В приложении реализована система авторизации и аутентификации OAuth 2.0 с помощью сервера
Keycloak. Сервис разворачивается по адресу: `http:\\localhost:8282` (admin/password).
Настройка задается в файле realm-config.json

### CI/CD
Для работы Jenkins необходимо создать .env файл

```env
# Path to the local kubeconfig (macOS/Linux format)
KUBECONFIG_PATH=C:\Users\pav\.kube\config.yaml

# GHCR (GitHub Container Registry) credentials
GITHUB_USERNAME=minlex3
GITHUB_TOKEN=ghp_{your_token}
GHCR_TOKEN=ghp_{your_token}

# Docker registry configuration (GHCR)
DOCKER_REGISTRY=ghcr.io/your-username
GITHUB_REPOSITORY=minlex3/bank-app

# PostgreSQL database password
DB_PASSWORD=password
```

Запуск Jenkins
```bash
cd jenkins
docker compose up -d --build
```
Будет доступен по адресу `http://localhost:8080`

Для завершения работы и очистки пространств имен выполнить готовый скрипт
```bash
cd jenkins
./purge-all.sh
```
