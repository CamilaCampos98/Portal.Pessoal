# Portal Pessoal

Entrada única para o Soneca e o Controle Financeiro, executados na máquina local e acessíveis pela tailnet.

Os projetos originais permanecem independentes. Este repositório apenas constrói ou serve cada um a partir de sua pasta original:

- `../soneca`
- `../Portal.ControleFinanceiro`
- `../ControleFinanceiroAPI`

## Portas locais

| Serviço | Porta |
|---|---:|
| Portal Pessoal | 8080 |
| Financeiro | 8081 |
| Soneca | 8082 |
| API financeira | somente rede Docker |

## Configuração

1. Execute `./iniciar.ps1` no PowerShell.
2. Confirme localmente em `http://localhost:8080`.
3. Execute `./configurar-tailscale.ps1` e confira os endereços com `tailscale serve status`.

A API usa a configuração de produção já existente em `../ControleFinanceiroAPI/ControleFinanceiroAPI/appsettings.Production.json` e a credencial existente em `wwwroot/credentials.json`. O arquivo `.env.example` fica disponível apenas para uma migração futura das credenciais para variáveis de ambiente.

O Tailscale publica:

- HTTPS 443: Portal Pessoal
- HTTPS 8443: Controle Financeiro
- HTTPS 9443: Soneca

## Observação sobre o Soneca

O aplicativo principal continua usando Google Apps Script. Os endpoints `/api/push/*` não estão presentes na pasta recebida; por isso, notificações push remotas dependem do backend em que esses endpoints estiverem hospedados. As demais funções e notificações locais permanecem independentes desse backend.
