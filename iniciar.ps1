$ErrorActionPreference = "Stop"

if (-not (Test-Path -LiteralPath ".env")) {
    throw "Arquivo .env não encontrado. Copie .env.example para .env e preencha as credenciais da API financeira."
}

docker compose up -d --build
docker compose ps

