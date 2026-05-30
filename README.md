### Hexlet tests and linter status:
[![Actions Status](https://github.com/okorovin/devops-for-developers-project-77/actions/workflows/hexlet-check.yml/badge.svg)](https://github.com/okorovin/devops-for-developers-project-77/actions)

# DevOps for developers — project 77

Учебный проект Hexlet. Инфраструктура полностью описана в Terraform и разворачивается в Yandex Cloud: VPC с одной подсетью, две ВМ с nginx, Application Load Balancer с HTTP/HTTPS-листенерами, публичный домен с автоматическим Let's Encrypt сертификатом.

**Приложение:** https://gosha.exchange

## Требования к системе

- Terraform 1.6+
- Ansible 2.14+ (нужен только `ansible-vault` для расшифровки секретов)
- Bash / GNU Make

## Подготовка

1. Создай локально файл `.vault-password` с паролем от Ansible Vault:
   ```bash
   echo 'твой-пароль-от-vault' > .vault-password
   chmod 600 .vault-password
   ```
2. Bootstrap-ресурсы (создаются один раз вручную в Yandex Cloud, чтобы Terraform мог хранить state):
   - **Service Account** `tf-state-sa` с ролью `storage.editor`
   - **Static access key** (HMAC) для этого SA
   - **Object Storage bucket** `hexlet-77-tf-state-gosha` (имя зашито в `terraform/backend.tf`)
3. Положи в vault HMAC-ключи и YC-токен:
   ```bash
   make edit-vault
   ```
   Файл должен содержать:
   ```yaml
   vault_yc_token: <OAuth токен>
   vault_yc_cloud_id: <id облака>
   vault_yc_folder_id: <id каталога hexlet-77>
   vault_tf_state_access_key: <HMAC access>
   vault_tf_state_secret_key: <HMAC secret>
   vault_datadog_api_key: <DataDog API Key>
   vault_datadog_app_key: <DataDog Application Key>
   ```
4. DataDog: зарегистрируйся на https://www.datadoghq.eu, в Organization Settings создай **API Key** (для агента и Terraform) и **Application Key** (для управления ресурсами через API).

## Команды

### Передача переменных из vault в Terraform
```bash
make tfvars          # Ansible-плейбук render-tfvars.yml расшифровывает vault
                     # и пишет terraform/secrets.auto.tfvars (в .gitignore)
                     # Terraform автоматически подхватывает все *.auto.tfvars
```
Любая команда `make plan/apply/destroy/init` сначала автоматически дёргает `make tfvars`, так что вручную обычно не нужно.

### Terraform
```bash
make init           # terraform init (подтягивает провайдеров и подключает remote state)
make plan           # terraform plan
make apply          # terraform apply (создать/обновить инфру)
make destroy        # terraform destroy (снести всё)
make output         # значения output (IP балансера, NS-серверы и т.д.)
make fmt            # terraform fmt -recursive
make validate       # terraform validate
```

### Ansible (деплой приложения)
```bash
make ansible-install # подтянуть роли из Ansible Galaxy
make gen-inventory   # сгенерировать ansible/inventory.ini из terraform outputs
make setup           # ansible-install + установить Docker и Python-пакеты на ВМ (тег setup)
make deploy          # развернуть контейнер приложения (тег deploy)
make ping            # SSH-доступность всех ВМ
```

### Vault
```bash
make edit-vault      # редактировать секреты
make view-vault      # посмотреть секреты
```

**Поток секретов:**
- `vault_yc_*`, `vault_datadog_*` → через Ansible-плейбук `render-tfvars.yml` пишутся в `terraform/secrets.auto.tfvars` → Terraform читает как обычные variables.
- `vault_tf_state_*` (HMAC ключи для S3 backend) → пробрасываются в окружение через Makefile как `AWS_ACCESS_KEY_ID` / `AWS_SECRET_ACCESS_KEY` (backend.tf не читает .tfvars, только env).

## Полный сценарий «с нуля до прода»

```bash
make init                  # terraform backend + providers
make apply                 # создаём инфру (повторить если упадёт на cert — подождать 15 мин)
make gen-inventory         # обновить ansible/inventory.ini из публичных IP ВМ
make setup                 # установить Docker на ВМ
make deploy                # запустить контейнер приложения
```

После этого https://gosha.exchange отдаёт страницу из контейнера, ALB балансирует между двумя ВМ.

## Что создаёт Terraform

| Слой | Ресурсы |
|---|---|
| **Network** | `yandex_vpc_network`, `yandex_vpc_subnet`, две security group (`sg-alb`, `sg-vm`) |
| **Compute** | две `yandex_compute_instance` (Ubuntu 22.04) |
| **ALB** | target group, backend group, HTTP-роутер, балансер с HTTPS-listener'ом на 443 |
| **DNS** | публичная зона в Cloud DNS + A-записи для apex и `www` + CNAME для ACME-валидации |
| **TLS** | managed Let's Encrypt сертификат с DNS-валидацией |

## Что делает Ansible

| Тег | Действия |
|---|---|
| `setup` | apt update, universe repo, python3-docker/requests, роли `geerlingguy.pip`, `geerlingguy.docker` и `datadog.datadog` (агент мониторинга с http_check на локальное приложение), остановка nginx из apt |
| `deploy` | поднимает контейнер `nginxdemos/hello:plain-text` на порту 80 с `restart_policy=unless-stopped` |

## Мониторинг (DataDog)

- DataDog Agent ставится через Ansible-роль `datadog.datadog` (тег `setup`). Конфигурирует `http_check` integration, который раз в N секунд опрашивает локальный эндпоинт приложения и пишет метрику `http.can_connect`.
- Terraform через ресурс `datadog_monitor` (`terraform/monitor.tf`) создаёт алерт типа `service check`: если 2 подряд проверки `http.can_connect` в статусе `CRITICAL` — срабатывает уведомление.
- Дашборды/мониторы лежат в каталоге DataDog аккаунта, привязаны через тег `project:hexlet-77`.

## Делегирование домена

Терraform создаёт публичную DNS-зону, но не управляет регистратором. Один раз руками: у регистратора домена пропиши NS-серверы Яндекса (`ns1.yandexcloud.net`, `ns2.yandexcloud.net`). После делегирования (5–60 мин) Let's Encrypt сертификат выпустится автоматически.
