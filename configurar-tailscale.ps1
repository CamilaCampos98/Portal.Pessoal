$ErrorActionPreference = "Stop"

tailscale serve --bg --https=443 http://127.0.0.1:8080
tailscale serve --bg --https=8443 http://127.0.0.1:8081
tailscale serve --bg --https=9443 http://127.0.0.1:8082

Write-Host "Portal:     https://$env:COMPUTERNAME"
Write-Host "Financeiro: HTTPS porta 8443"
Write-Host "Soneca:     HTTPS porta 9443"
Write-Host "Use 'tailscale serve status' para ver os enderecos completos."

