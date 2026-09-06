# Kittygram — запуск и начальная настройка

В этом файле описаны шаги первоначального развёртывания (bootstrap) инфраструктуры и перечислены все переменные окружения (env), которые используются в проекте, с подсказками, как их получить или сгенерировать.

**Коротко:** сначала выполняется bootstrap (создаёт S3-бакет/ресурсы для хранения terraform state), затем основная infra, после — деплой сервисов через `docker-compose`.

**Важные файлы с примерами env/переменных:**
- [/_env.example](_env.example)
- [/infra/terraform.tfvars.example](infra/terraform.tfvars.example)
- [/infra/bootstrap/terraform.tfvars.example](infra/bootstrap/terraform.tfvars.example)

## Требования
- Terraform >= 1.6
- Yandex Cloud CLI (`yc`) настроенный/авторизованный (или сервисный аккаунт)
- Docker, Docker Compose
- Python 3.9+ (для генерации секретов и локального запуска)

## 1) Bootstrap инфраструктуры
1. Перейдите в директорию `infra/bootstrap` и создайте файл с вашими значениями на основе примера:

```bash
cd infra/bootstrap
cp terraform.tfvars.example terraform.tfvars
# Отредактируйте terraform.tfvars: задайте folder_id и уникальное bucket_name
```

2. Инициализируйте и примените terraform для bootstrap (создаст бакет для хранения state и другие ресурсы):

```bash
terraform init
terraform apply -auto-approve -var-file=terraform.tfvars
```

После успешного выполнения запомните `bucket_name` — он используется как backend для основного Terraform (bootstrap создаёт удалённый backend).

## 2) Развёртывание основной инфраструктуры
1. Перейдите в `infra`, скопируйте пример и заполните параметры:

```bash
cd infra
cp terraform.tfvars.example terraform.tfvars
# Отредактируйте terraform.tfvars: folder_id, zone, ssh_public_key и т.д.
```

2. Инициализируйте и примените terraform (использует бакет, созданный на шаге bootstrap):

```bash
terraform init
terraform apply -auto-approve -var-file=terraform.tfvars
```

## 3) Запуск сервисов (docker-compose)
В корне проекта есть `docker-compose.production.yml`. При наличии всех необходимых env можно запустить сервисы так:

```bash
docker compose -f docker-compose.production.yml up -d --build
```

Учтите, что `docker-compose` ожидает переданные переменные окружения (см. раздел Env ниже).

## Перечень переменных окружения и как их получить
Ниже собраны все переменные, которые встречаются в проекте и в примерах. Для большинства переменных есть файл-пример в репозитории — используйте их как шаблон.

**A. Переменные приложения (Django)**
- `SECRET_KEY` : секрет Django. Сгенерировать локально:

```bash
python - <<'PY'
from django.core.management.utils import get_random_secret_key
print(get_random_secret_key())
PY
```
	- Можно положить в файл `.env` в корне или экспортировать в окружение перед запуском.
- `DEBUG` : включить отладку (`1`) или выключить (`0`).
- `ALLOWED_HOSTS` : список хостов через запятую, например `example.com,127.0.0.1`.
- `POSTGRES_DB`, `POSTGRES_USER`, `POSTGRES_PASSWORD` : настройки базы данных. Пример по умолчанию в [_env.example](_env.example).
	- Для production эти учётные данные создаются при настройке Postgres на VM/DB-сервисе — используйте те значения, которые вы задали при развёртывании СУБД.
- `DB_HOST`, `DB_PORT` : хост и порт Postgres. Для docker-compose локально обычно `postgres:5432`; для удалённой ВМ — IP или внутренний адрес.

Где искать: Django читает эти переменные в [backend/kittygram_backend/settings.py](backend/kittygram_backend/settings.py).

**B. Переменные Terraform / инфраструктуры**
- `folder_id` : идентификатор папки Yandex Cloud — получить можно через `yc`:

```bash
yc config get folder-id
# или
yc resource-manager folder list
```
- `region`, `zone` : регион и зона (по умолчанию `ru-central1` / `ru-central1-a`).
- `ssh_public_key` : ваш SSH public key (содержимое `~/.ssh/id_ed25519.pub` или сгенерируйте командой `ssh-keygen -t ed25519`).
- `gateway_port` : публичный порт gateway (по умолчанию `9000`).
- `bucket_name` : уникальное имя S3-совместимого бакета для хранения terraform state (указывается в `infra/bootstrap/terraform.tfvars.example`).

Файлы-примеры: [/infra/terraform.tfvars.example](infra/terraform.tfvars.example) и [/infra/bootstrap/terraform.tfvars.example](infra/bootstrap/terraform.tfvars.example).

**C. Аутентификация Yandex Cloud**
- Настройте `yc` локально: выполните `yc init` и следуйте подсказкам, либо используйте сервисный аккаунт (создайте ключ и сохраните JSON).
- В большинстве случаев провайдер Terraform `yandex` будет использовать конфигурацию `yc` на вашей машине.

Команды полезные:

```bash
# показать текущую папку
yc config get folder-id

# сгенерировать SSH ключ (если не создан)
ssh-keygen -t ed25519 -C "kittygram" -f ~/.ssh/kittygram_id_ed25519
cat ~/.ssh/kittygram_id_ed25519.pub
```

## Примеры: быстро подготовить файлы

1) Подготовить terraform vars для bootstrap:

```bash
cp infra/bootstrap/terraform.tfvars.example infra/bootstrap/terraform.tfvars
# отредактируйте infra/bootstrap/terraform.tfvars
```

2) Подготовить terraform vars для основной infra:

```bash
cp infra/terraform.tfvars.example infra/terraform.tfvars
# отредактируйте infra/terraform.tfvars
```

3) Подготовить переменные для приложения (локально или для CI):

```bash
cp _env.example .env
# отредактируйте .env (POSTGRES_*, SECRET_KEY и т.д.)
export $(cat .env | xargs)
```

> Примечание: `export $(cat .env | xargs)` удобно для локальной проверки, но для production используйте более надёжный менеджер секретов или переменные окружения в системе/CI.

## Полезные файлы
- [infra/cloud-init.yaml](infra/cloud-init.yaml) — cloud-init, используемый для инициализации VM при создании.
- [docker-compose.production.yml](docker-compose.production.yml) — продакшен-компоновка сервисов.
- [backend/kittygram_backend/settings.py](backend/kittygram_backend/settings.py) — где Django берёт env-переменные.

Если нужно, могу добавить готовый скрипт для генерации всех локальных `.tfvars` и `.env` по интерактивной форме. Хотите, чтобы я его написал?

## Переменные из GitHub Actions (Secrets и Repo Variables)
Workflows используют набор секретов и переменных репозитория для автоматизации CI/CD и деплоя. Ниже — список, которые нужно добавить в `Settings -> Secrets and variables` вашего репозитория, и краткие инструкции, где их взять.

- **GitHub Secrets (вкладка Secrets)**
- `ACCESS_KEY` / `SECRET_KEY` — S3-подобные ключи для доступа к объектному хранилищу (используются как backend для terraform).
	- В этом репозитории bootstrap Terraform автоматически создаёт сервисный аккаунт и статические ключи, а также S3-бакет. После выполнения `infra/bootstrap` получите значения командой:

```bash
cd infra/bootstrap
terraform output -raw access_key
terraform output -raw secret_key
terraform output -raw bucket_name
terraform output -raw authorized_key   # содержит JSON с ключами сервисного аккаунта
```

	- Поместите `access_key`/`secret_key` в секреты `ACCESS_KEY` / `SECRET_KEY`, а `bucket_name` — в `TF_STATE_BUCKET`.
- `TF_STATE_BUCKET` — имя бакета для хранения terraform state (тот самый `bucket_name`, который вы задали в bootstrap). Можно заполнить значением из `infra/bootstrap/terraform.tfvars.example`.
- `SSH_KEY` — приватный SSH-ключ (PEM) для доступа к VM при деплое (используется appleboy/scp/ssh-action). Храните приватный ключ в секретах, а публичный ключ положите в `infra/terraform.tfvars` или передайте как `SSH_PUBLIC_KEY`.
- `DOCKER_USERNAME` / `DOCKER_TOKEN` — учётные данные Docker Hub (логин и access token). Создайте токен доступа на hub.docker.com → Account settings → Security → Access Tokens.
- `POSTGRES_DB`, `POSTGRES_USER`, `POSTGRES_PASSWORD`, `DB_HOST`, `DB_PORT` — настройки БД, которые workflow кладёт в `.env` на сервере. Установите те значения, которые вы используете при развёртывании Postgres.
- `TELEGRAM_TOKEN`, `TELEGRAM_CHAT_ID` — токен бота и id чата для уведомлений. Токен даёт BotFather, chat id можно узнать через `@userinfobot` или вызов getUpdates к API после отправки сообщения боту.
- `FOLDER_ID` — идентификатор папки Yandex Cloud (используется в terraform.yml как `TF_VAR_folder_id`). Получить: `yc config get folder-id`.
- `SSH_PUBLIC_KEY` — публичный SSH-ключ (если вы предпочитаете хранить его в секретах вместо tfvars).
-- `YC_SERVICE_ACCOUNT_KEY` — JSON ключ сервисного аккаунта Yandex Cloud (если вы используете сервисный аккаунт для Terraform). Создаётся bootstrap'ом и возвращается как output `authorized_key` в `infra/bootstrap` — используйте `terraform output -raw authorized_key` и сохраните результат в этот secret.

**GitHub Repository Variables (Settings -> Variables)**
- `USER` — имя SSH-пользователя на VM (например `kittygram`). Используется в deploy workflow.
- `GATEWAY_PORT` — порт gateway (по умолчанию `9000`).

Как добавить: зайдите в `Settings -> Secrets and variables -> Actions` и создайте новые secrets/variables с именами выше.