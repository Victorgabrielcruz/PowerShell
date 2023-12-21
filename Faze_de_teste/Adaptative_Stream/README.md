# Script PowerShell para Relatórios de Câmeras no Milestone

## Introdução
Este script PowerShell automatiza o processo de geração de relatórios de câmeras no sistema de gerenciamento de vídeo Milestone. Ele oferece flexibilidade para configurar o relatório, conectar-se ao servidor Milestone e salvar os dados do relatório em um arquivo Excel. O script oferece opções para personalizar o caminho do relatório, configurações de credenciais e muito mais.

## Funções

### 1. Função de Credenciais
Esta função lida com a configuração de credenciais, permitindo a definição do endereço do servidor, o uso do diálogo de login, credenciais do Windows ou credenciais de usuário básico. A função solicita ao usuário a escolha de opções para autenticação.

#### Parâmetros:
- `$op`: Opção escolhida pelo usuário.
- `$serverAddress`: Endereço do servidor Milestone.
- `$useDialog`: Indica se deve ser usado o diálogo de login.
- `$useWindowsCredentials`: Indica se devem ser usadas credenciais do Windows.
- `$useBasicUser`: Indica se devem ser usadas credenciais de usuário básico.
- `$username`: Nome de usuário para autenticação.
- `$password`: Senha para autenticação.

### 2. Função do Módulo Milestone
Esta função realiza a conexão ao servidor Milestone e a autenticação com base nas credenciais e opções configuradas, como o uso do diálogo de login, credenciais do Windows e credenciais de usuário básico. Após a autenticação, a função também se conecta às câmeras no servidor Milestone.

#### Parâmetros:
- `$useDialog`: Indica se deve ser usado o diálogo de login.
- `$useWindowsCredentials`: Indica se devem ser usadas credenciais do Windows.
- `$server`: Endereço do servidor Milestone.
- `$useBasicUser`: Indica se devem ser usadas credenciais de usuário básico.
- `$password`: Senha para autenticação.
- `$username`: Nome de usuário para autenticação.

### 3. Função de Agrupamento de Câmeras por Modelo
Esta função realiza o agrupamento de câmeras com base no modelo, criando grupos no servidor Milestone e organizando câmeras dentro desses grupos. A organização pode ser feita com base no tamanho máximo de grupo especificado.

#### Parâmetros:
- `$BaseGroupPath`: Caminho base para grupos de câmeras.
- `$MaxGroupSize`: Tamanho máximo para cada grupo.

### 4. Função Principal - Main
O script principal executa as seguintes etapas:

1. Configuração de credenciais usando a função `Função de Credenciais`.
2. Conexão ao servidor Milestone e autenticação usando a função `Função do Módulo Milestone`.
3. Escolha entre os modelos 1 e 2 para determinar a estratégia de agrupamento.
4. Chamada da função `Função de Agrupamento de Câmeras por Modelo` para realizar o agrupamento de câmeras.

## Script Principal

O script principal simplifica o processo de criação de relatórios de câmeras no sistema de gerenciamento de vídeo Milestone, com opções de personalização e facilidade de uso. O script realiza as seguintes etapas:

1. Configuração de credenciais.
2. Conexão ao servidor Milestone.
3. Escolha do modelo para agrupamento de câmeras.
4. Agrupamento de câmeras com base no modelo escolhido.

## Autor
- Víctor Gabriel Cruz Pereira

## Contato
- Email: victorgabrielcruzpereira21@gmail.com
- Email: v.g.pplayer21@gmail.com
- Email: vgcp@aluno.ifnmg.edu.br
