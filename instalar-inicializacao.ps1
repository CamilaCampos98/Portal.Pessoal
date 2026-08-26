$ErrorActionPreference = "Stop"

$taskName = "Portal Pessoal - Atualizacao automatica"
$monitorScript = Join-Path $PSScriptRoot "monitorar-atualizacoes.ps1"

if (-not (Test-Path -LiteralPath $monitorScript)) {
    throw "Monitor nao encontrado: $monitorScript"
}

$powerShellExe = (Get-Command powershell.exe).Source
$arguments = "-NoProfile -WindowStyle Hidden -ExecutionPolicy Bypass -File `"$monitorScript`""
$action = New-ScheduledTaskAction -Execute $powerShellExe -Argument $arguments -WorkingDirectory $PSScriptRoot
$trigger = New-ScheduledTaskTrigger -AtLogOn -User $env:USERNAME
$settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable -ExecutionTimeLimit ([TimeSpan]::Zero)
$principal = New-ScheduledTaskPrincipal -UserId $env:USERNAME -LogonType Interactive -RunLevel Limited

Register-ScheduledTask `
    -TaskName $taskName `
    -Action $action `
    -Trigger $trigger `
    -Settings $settings `
    -Principal $principal `
    -Description "Atualiza os repositorios do Portal Pessoal e reconstrói os containers afetados." `
    -Force | Out-Null

Start-ScheduledTask -TaskName $taskName

Write-Host "Atualizacao automatica instalada e iniciada."
Write-Host "Tarefa: $taskName"
Write-Host "Log: $(Join-Path $PSScriptRoot 'logs\atualizacoes.log')"
