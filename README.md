# Nginx log → CSV → Git (Docker)

This project initializes a container featuring the Bash script `parser.sh`. This script parses Nginx (Ingress-style) access logs into CSV format (using a semicolon `;` delimiter), after which it commits and pushes the CSV file to a GitHub repository specified via the `.env` configuration.

## Prerequisites

- Docker and Docker Compose must be installed on the host machine.
- A Personal Access Token (PAT) must be generated within GitHub to authorize access (push privileges) to the repository where the `.csv` files will be deposited. GitHub Documentation: [https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/managing-your-personal-access-tokens](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/managing-your-personal-access-tokens)

## Configuration

Execute the following command within the project root directory:

```bash
cp .env.example .env
```

Edit the `.env` file and populate the following fields:

- `GIT_USER_NAME` and `GIT_USER_EMAIL` (commit author details)
- `GIT_USERNAME` (GitHub username)
- `GIT_TOKEN` (PAT)
- `GIT_REPO_URL` (excluding `https://` and `.git`, for example `github.com/hostprotestm-tech/itoutposts`)
- `GIT_BRANCH` (typically `main`)

## Execution

Following the configuration of the `.env` file, execute:

```bash
docker compose up --build -d
```

The log file must be located within the `input/` directory.

Processed files (`.csv`) will be stored within the `output/` directory.

## `parser.sh` Parameters

- `-i <path>`: input log file (for example, `/input/nginx.log`).
- `-o <path>`: output CSV file (for example, `/output/parsed_logs.csv`).
- `-f <key=value>`: filter (limit of one condition per execution).

## Filtering (`-f key=value`)

Supported keys include:

- `ip` (exact match)
- `time` (substring, for example, `time=26/Apr/2021` or `time=26/Apr/2021:21:20:17`)
- `method` (exact match)
- `url` (substring)
- `protocol` (exact match)
- `status` (exact match)
- `bytes` (exact match)
- `referer` (substring)
- `user_agent` (substring)
- `request_length` (exact match)
- `request_time` (exact match)
- `upstream_name` (substring)
- `alt_upstream_name` (substring)
- `upstream_addr` (substring)
- `upstream_response_length` (exact match)
- `upstream_response_time` (exact match)
- `upstream_status` (exact match)
- `request_id` (substring)

## Usage Example

```bash
docker exec -it nginx-log-parser parser.sh -i /input/nginx.log -o /output/parsed_logs_filterIP.csv -f ip=192.168.226.64
```

## Notes

- If a Git repository does not yet exist within the `output/` directory, the script will automatically perform a `git clone` operation into `output/`.
- The script pushes changes to the branch specified in `GIT_BRANCH`.
- Examples of processed `.csv` files are located in the repository: [https://github.com/hostprotestm-tech/didactic-octo-parakeet](https://github.com/hostprotestm-tech/didactic-octo-parakeet)
