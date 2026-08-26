$ErrorActionPreference = "Stop"

tailscale funnel --bg --https=443 http://127.0.0.1:8080
tailscale funnel --bg --https=8443 http://127.0.0.1:8081
tailscale funnel --bg --https=10000 http://127.0.0.1:8082

Write-Host "Portal:     https://$env:COMPUTERNAME"
Write-Host "Financeiro: HTTPS porta 8443"
Write-Host "Soneca:     HTTPS porta 10000"
Write-Host "Use 'tailscale funnel status' para ver os enderecos completos."
