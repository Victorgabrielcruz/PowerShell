# Script PowerShell para Relatórios de Câmeras no Milestone

## Introdução
Este script PowerShell automatiza a geração de relatórios de câmeras no sistema de gerenciamento de vídeo Milestone. Ele oferece flexibilidade para configurar o relatório, conectar-se ao servidor Milestone e salvar os dados do relatório em um arquivo Excel.

## [1.0] Funções

### [1.1] Função de Credenciamento
A função `Credenciamento` gerencia a configuração de credenciais, permitindo escolher entre o uso de diálogo de login, credenciais do Windows ou credenciais de usuário básico Milestone.

#### Parâmetros:
- `$op`: Opção escolhida pelo usuário.
- `$serverAddress`: Endereço do servidor Milestone.
- `$useDialog`: Indica se deve ser usado o diálogo de login.
- `$useWindowsCredentials`: Indica se devem ser usadas credenciais do Windows.
- `$useBasicUser`: Indica se devem ser usadas credenciais de usuário básico.
- `$username`: Nome de usuário para autenticação.
- `$password`: Senha para autenticação.

### [1.2] Função do Módulo Milestone
A função `Modulo_Milestone` realiza a conexão ao servidor Milestone e a autenticação com base nas credenciais e opções configuradas. Pode utilizar diálogo de login, credenciais do Windows ou credenciais de usuário básico.

#### Parâmetros:
- `$useDialog`: Indica se deve ser usado o diálogo de login.
- `$useWindowsCredentials`: Indica se devem ser usadas credenciais do Windows.
- `$server`: Endereço do servidor Milestone.
- `$useBasicUser`: Indica se devem ser usadas credenciais de usuário básico.
- `$password`: Senha para autenticação.
- `$username`: Nome de usuário para autenticação.

### [1.3] Função de Obtenção de Dados de Todas as Câmeras
A função `Get-CameraReport` obtém dados de todas as câmeras, incluindo senhas, estatísticas de gravação, informações de retenção e capturas de tela.

## [2.0] Script Principal

O script principal executa as seguintes etapas:

1. Configuração de credenciais usando a função `Função de Credenciais`.
2. Conexão ao servidor Milestone e autenticação usando a função `Função do Módulo Milestone`.
3. Obtém dados de todas as câmeras usando a função `Função de Obtenção de Dados de Todas as Câmeras`.
4. Adiciona informações sobre o estado da rede (Online/Offline) para cada câmera.
5. Exibe o relatório em uma grade visual (`Out-GridView`).

## Autor
- Víctor Gabriel Cruz Pereira

## Contato
- Email: victorgabrielcruzpereira21@gmail.com
- Email: v.g.pplayer21@gmail.com
- Email: vgcp@aluno.ifnmg.edu.br


