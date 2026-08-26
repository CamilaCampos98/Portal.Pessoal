# Portal Pessoal

Entrada única para o Soneca e o Controle Financeiro, executados na máquina local e publicados com Tailscale Funnel.

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

1. Crie a pasta `secrets` e copie o `credentials.json` da API financeira para `secrets/google-credentials.json`.
2. Execute `./iniciar.ps1` no PowerShell.
3. Confirme localmente em `http://localhost:8080`.
4. Execute `./configurar-tailscale.ps1` e confira os endereços com `tailscale funnel status`.

A API usa o ID da planilha da configuração de produção existente e recebe a credencial por um volume somente leitura. O arquivo fica em `secrets/google-credentials.json`, fora do controle de versão.

O Tailscale publica:

- HTTPS 443: Portal Pessoal
- HTTPS 8443: Controle Financeiro
- HTTPS 10000: Soneca

## Atualização automática

Execute `instalar-inicializacao.bat` uma vez. A tarefa **Portal Pessoal - Atualizacao automatica** será iniciada a cada logon do Windows, aguardará o Docker Desktop e verificará os quatro repositórios a cada 60 segundos.

O monitor usa apenas `git pull --ff-only`, não altera repositórios com arquivos locais modificados e reconstrói somente o container relacionado ao repositório atualizado. O Soneca não exige reconstrução porque seus arquivos são montados diretamente no nginx.

Consulte o histórico em `logs/atualizacoes.log`.

## Observação sobre o Soneca

O aplicativo principal continua usando Google Apps Script. Os endpoints `/api/push/*` não estão presentes na pasta recebida; por isso, notificações push remotas dependem do backend em que esses endpoints estiverem hospedados. As demais funções e notificações locais permanecem independentes desse backend.
