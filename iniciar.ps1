$ErrorActionPreference = "Stop"

if (-not (Test-Path -LiteralPath ".\secrets\google-credentials.json")) {
    throw "Credencial Google não encontrada em .\secrets\google-credentials.json. Copie para esse local o credentials.json usado pela API financeira."
}

docker compose up -d --build
docker compose ps
