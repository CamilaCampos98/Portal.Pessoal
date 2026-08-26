$ErrorActionPreference = "Continue"

$portalDir = $PSScriptRoot
$reposDir = Split-Path -Parent $portalDir
$logDir = Join-Path $portalDir "logs"
$logFile = Join-Path $logDir "atualizacoes.log"
$checkSeconds = 60

New-Item -ItemType Directory -Force -Path $logDir | Out-Null

function Write-UpdateLog {
    param([string]$Message)

    $line = "[{0}] {1}" -f (Get-Date -Format "yyyy-MM-dd HH:mm:ss"), $Message
    Add-Content -LiteralPath $logFile -Value $line -Encoding UTF8
}

$mutex = [Threading.Mutex]::new($false, "Local\PortalPessoalAtualizador")
if (-not $mutex.WaitOne(0, $false)) {
    Write-UpdateLog "O monitor ja esta em execucao."
    exit 0
}

function Resolve-RepositoryPath {
    param([string]$BasePath)

    if (-not (Test-Path -LiteralPath $BasePath -PathType Container)) {
        return $BasePath
    }

    & git -C $BasePath rev-parse --is-inside-work-tree *> $null
    if ($LASTEXITCODE -eq 0) {
        return (& git -C $BasePath rev-parse --show-toplevel 2>$null)
    }

    $gitMarker = Get-ChildItem -LiteralPath $BasePath -Filter ".git" -Force -Recurse -ErrorAction SilentlyContinue |
        Sort-Object { $_.FullName.Length } |
        Select-Object -First 1

    if ($gitMarker) {
        return $gitMarker.Parent.FullName
    }

    return $BasePath
}

$repositories = @(
    @{ Name = "Portal Pessoal"; Path = (Resolve-RepositoryPath $portalDir); Service = "portal" },
    @{ Name = "Soneca"; Path = (Resolve-RepositoryPath (Join-Path $reposDir "soneca")); Service = $null },
    @{ Name = "Financeiro Web"; Path = (Resolve-RepositoryPath (Join-Path $reposDir "Portal.ControleFinanceiro")); Service = "financeiro-web" },
    @{ Name = "Financeiro API"; Path = (Resolve-RepositoryPath (Join-Path $reposDir "ControleFinanceiroAPI")); Service = "financeiro-api" }
)

function Wait-Docker {
    while ($true) {
        & docker info *> $null
        if ($LASTEXITCODE -eq 0) {
            return
        }

        Write-UpdateLog "Aguardando o Docker ficar disponivel."
        Start-Sleep -Seconds 15
    }
}

function Update-Repository {
    param([hashtable]$Repository)

    $repoPath = $Repository.Path
    if (-not (Test-Path -LiteralPath $repoPath -PathType Container)) {
        Write-UpdateLog "$($Repository.Name): pasta Git nao encontrada em $repoPath."
        return
    }

    & git -C $repoPath rev-parse --is-inside-work-tree *> $null
    if ($LASTEXITCODE -ne 0) {
        Write-UpdateLog "$($Repository.Name): pasta Git nao encontrada em $repoPath."
        return
    }

    $dirtyFiles = & git -C $repoPath status --porcelain 2>&1
    if ($LASTEXITCODE -ne 0) {
        Write-UpdateLog "$($Repository.Name): nao foi possivel consultar o repositorio."
        return
    }

    if ($dirtyFiles) {
        Write-UpdateLog "$($Repository.Name): atualizacao pausada porque existem alteracoes locais."
        return
    }

    & git -C $repoPath fetch --quiet 2>&1 | Out-Null
    if ($LASTEXITCODE -ne 0) {
        Write-UpdateLog "$($Repository.Name): falha ao consultar o Git remoto."
        return
    }

    $upstream = & git -C $repoPath rev-parse --abbrev-ref --symbolic-full-name "@{u}" 2>$null
    if ($LASTEXITCODE -ne 0 -or -not $upstream) {
        Write-UpdateLog "$($Repository.Name): a branch atual nao possui upstream configurado."
        return
    }

    $localCommit = & git -C $repoPath rev-parse HEAD 2>$null
    $remoteCommit = & git -C $repoPath rev-parse $upstream 2>$null
    if ($localCommit -eq $remoteCommit) {
        return
    }

    & git -C $repoPath merge-base --is-ancestor HEAD $upstream 2>$null
    if ($LASTEXITCODE -ne 0) {
        Write-UpdateLog "$($Repository.Name): historico local divergiu do remoto; atualizacao automatica pausada."
        return
    }

    Write-UpdateLog "$($Repository.Name): nova versao encontrada em $upstream."
    & git -C $repoPath pull --ff-only 2>&1 | ForEach-Object { Write-UpdateLog "$($Repository.Name): $_" }
    if ($LASTEXITCODE -ne 0) {
        Write-UpdateLog "$($Repository.Name): o pull falhou."
        return
    }

    if ($Repository.Service) {
        Write-UpdateLog "$($Repository.Name): reconstruindo o container $($Repository.Service)."
        & docker compose --project-directory $portalDir up -d --build --force-recreate $Repository.Service 2>&1 |
            ForEach-Object { Write-UpdateLog "$($Repository.Name): $_" }

        if ($LASTEXITCODE -ne 0) {
            Write-UpdateLog "$($Repository.Name): falha ao atualizar o container."
            return
        }
    }

    Write-UpdateLog "$($Repository.Name): atualizacao concluida."
}

try {
    Write-UpdateLog "Monitor de atualizacoes iniciado."
    foreach ($repository in $repositories) {
        Write-UpdateLog "$($repository.Name): repositorio resolvido em $($repository.Path)."
    }
    Wait-Docker
    & docker compose --project-directory $portalDir up -d 2>&1 |
        ForEach-Object { Write-UpdateLog "Docker: $_" }

    while ($true) {
        foreach ($repository in $repositories) {
            Update-Repository -Repository $repository
        }

        Start-Sleep -Seconds $checkSeconds
    }
}
finally {
    $mutex.ReleaseMutex()
    $mutex.Dispose()
}
