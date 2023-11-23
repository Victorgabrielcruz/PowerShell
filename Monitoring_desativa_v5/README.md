# Script PowerShell para Monitoramento e Desabilitação de Dispositivos no Milestone

## Introdução
Este script PowerShell foi desenvolvido para monitorar dispositivos no sistema de gerenciamento de vídeo Milestone. Ele realiza testes de ping para avaliar a conectividade dos dispositivos e desabilita aqueles com baixa taxa de sucesso ou alta latência. O script oferece configurações flexíveis, permitindo ajustar parâmetros como o número máximo de dispositivos por iteração, contagem de pings, taxa mínima de sucesso e limiar de latência média.

## Funções

### 1. Credenciamento
Esta função permite configurar as opções de credenciais, incluindo o uso do diálogo de login, credenciais do Windows e credenciais de usuário básico Milestone.

### 2. Módulo Milestone
Esta função lida com a conexão ao servidor Milestone e a autenticação com base nas opções de credenciais configuradas.

### 3. PerformPing
Realiza testes de ping para determinar a conectividade online e a latência de um dispositivo.

### 4. Disable-Device
Desabilita um dispositivo no Milestone devido a baixa taxa de sucesso ou alta latência.

## Script Principal

O script principal executa as seguintes etapas:

1. Configuração de credenciais usando a função `Credenciamento`.
2. Configuração do servidor Milestone com a função `Modulo_Milestone`.
3. Monitoramento e avaliação de dispositivos com base em testes de ping.
4. Desabilitação de dispositivos com baixa taxa de sucesso ou alta latência.
5. Desconexão do Milestone no final de cada iteração.

O script simplifica o processo de monitoramento e gerenciamento de dispositivos no sistema Milestone, permitindo ajustes finos por meio de configurações personalizáveis.

## Autor
Víctor Gabriel Cruz Pereira

## Contato
- Email: victorgabrielcruzpereira21@gmail.com
- Email: v.g.pplayer21@gmail.com
- Email: vgcp@aluno.ifnmg.edu.br
