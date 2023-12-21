```markdown
# Script PowerShell para Agrupamento de Dispositivos no Milestone

## Introdução
Este script PowerShell realiza o agrupamento de dispositivos no sistema de gerenciamento de vídeo Milestone. Ele oferece funcionalidades para configurar credenciais, conectar-se ao servidor Milestone e agrupar dispositivos com base no modelo.

## [1.0] Funções

### [1.1] Função de Credenciamento
A função `Credenciamento` gerencia a configuração de credenciais, permitindo ao usuário escolher entre o uso de diálogo de login, credenciais do Windows ou credenciais de usuário básico Milestone.

#### Parâmetros:
- `$op`: Opção escolhida pelo usuário.
- `$serverAddress`: Endereço do servidor Milestone.
- `$useDialog`: Indica se deve ser usado o diálogo de login.
- `$useWindowsCredentials`: Indica se devem ser usadas credenciais do Windows.
- `$useBasicUser`: Indica se devem ser usadas credenciais de usuário básico.
- `$username`: Nome de usuário para autenticação.
- `$password`: Senha para autenticação.

### [1.2] Função de Configuração do Servidor MILESTONE
A função `Modulo_Milestone` realiza a conexão ao servidor Milestone e a autenticação com base nas credenciais e opções configuradas. Pode utilizar diálogo de login, credenciais do Windows ou credenciais de usuário básico.

#### Parâmetros:
- `$useDialog`: Indica se deve ser usado o diálogo de login.
- `$useWindowsCredentials`: Indica se devem ser usadas credenciais do Windows.
- `$server`: Endereço do servidor Milestone.
- `$useBasicUser`: Indica se devem ser usadas credenciais de usuário básico.
- `$password`: Senha para autenticação.
- `$username`: Nome de usuário para autenticação.

### [1.3] Função para Agrupar Dispositivos por Modelo
A função `Group-DevicesByModel` realiza o agrupamento de dispositivos com base no modelo. Isso é feito criando grupos no servidor Milestone e organizando dispositivos dentro desses grupos, considerando um tamanho máximo de grupo especificado.

#### Parâmetros:
- `$BaseGroupPath`: Caminho base para grupos de dispositivos.
- `$MaxGroupSize`: Tamanho máximo para cada grupo.
- `$DeviceType`: Tipo de dispositivo, padrão é "Camera".

## [2.0] Script Principal

O script principal executa as seguintes etapas:

1. Configuração de credenciais usando a função `Função de Credenciais`.
2. Conexão ao servidor Milestone e autenticação usando a função `Função do Módulo Milestone`.
3. Chama a função `Função para Agrupar Dispositivos por Modelo` para realizar o agrupamento de dispositivos.

## Autor
- Víctor Gabriel Cruz Pereira

## Contato
- Email: victorgabrielcruzpereira21@gmail.com
- Email: v.g.pplayer21@gmail.com
- Email: vgcp@aluno.ifnmg.edu.br
