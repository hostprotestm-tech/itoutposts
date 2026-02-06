# Nginx log → CSV → Git (Docker)

Цей проєкт піднімає контейнер з Bash-скриптом `parser.sh`, який парсить Nginx (Ingress-style) access log у CSV (розділювач `;`), після чого комітить і пушить CSV у заданий через .env GitHub-репозиторій.

## Передумови

- На хості має бути встановлений Docker та Docker Compose.
- У GitHub має бути створений Personal Access Token (PAT) для доступу (push) у репозиторій, куди будуть додаватися `.csv` файли. Документація GitHub: https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/managing-your-personal-access-tokens

## Налаштування

У корені проєкта:

```bash
cp .env.example .env
```

Відредагуйте `.env` і заповніть:

- `GIT_USER_NAME` та `GIT_USER_EMAIL` (автор коміту)
- `GIT_USERNAME` (GitHub username)
- `GIT_TOKEN` (PAT)
- `GIT_REPO_URL` (без `https://` і без `.git`, наприклад `github.com/hostprotestm-tech/itoutposts`)
- `GIT_BRANCH` (зазвичай `main`)

## Запуск

Після заповнення `.env`:

```bash
docker compose up --build -d
```

Файл із логами повинен знаходитись у каталозі `input/`.

Оброблені файли (`.csv`) будуть у каталозі `output/`.

## Параметри `parser.sh`

- `-i <path>`: вхідний log-файл (наприклад `/input/nginx.log`).
- `-o <path>`: вихідний CSV-файл (наприклад `/output/parsed_logs.csv`).
- `-f <key=value>`: фільтр (одна умова на запуск).

## Фільтрація (`-f key=value`)

Підтримувані ключі:

- `ip` (точна відповідність)
- `time` (підрядок, наприклад `time=26/Apr/2021` або `time=26/Apr/2021:21:20:17`)
- `method` (точна відповідність)
- `url` (підрядок)
- `protocol` (точна відповідність)
- `status` (точна відповідність)
- `bytes` (точна відповідність)
- `referer` (підрядок)
- `user_agent` (підрядок)
- `request_length` (точна відповідність)
- `request_time` (точна відповідність)
- `upstream_name` (підрядок)
- `alt_upstream_name` (підрядок)
- `upstream_addr` (підрядок)
- `upstream_response_length` (точна відповідність)
- `upstream_response_time` (точна відповідність)
- `upstream_status` (точна відповідність)
- `request_id` (підрядок)

## Приклад використання

```bash
docker exec -it nginx-log-parser parser.sh -i /input/nginx.log -o /output/parsed_logs_filterIP.csv -f ip=192.168.226.64
```

## Примітки

- Якщо у каталозі `output/` ще немає Git-репозиторію, скрипт автоматично зробить `git clone` у `output/`.
- Скрипт пушить у вказану гілку `GIT_BRANCH`.
- Приклади опрацьованих .csv файлів розміщується в репозиторії https://github.com/hostprotestm-tech/didactic-octo-parakeet
