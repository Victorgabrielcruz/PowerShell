# Script PowerShell para Geração de Relatórios de Câmeras no Milestone

## Introdução
Este script PowerShell foi desenvolvido para automatizar o processo de geração de relatórios de câmeras no sistema de gerenciamento de vídeo Milestone. Ele oferece a flexibilidade de configurar o relatório, conectar-se ao servidor Milestone e salvar os dados do relatório em um arquivo Excel. O script fornece opções para personalizar o caminho do relatório, configurações de credenciais e muito mais.

## Funções

### 1. Credenciamento
Esta função lida com a configuração de credenciais, permitindo a configuração do endereço do servidor, o uso do diálogo de login, credenciais do Windows e credenciais de usuário básico.

### 2. Configurar Relatório
Configure as definições do relatório, especificando o caminho do relatório, o nome do arquivo de relatório e opções para personalização.

### 3. Módulo Milestone
Esta função realiza a conexão ao servidor Milestone e a autenticação com base nas credenciais e opções configuradas, como o uso do diálogo de login, credenciais do Windows e credenciais de usuário básico.

### 4. Criar Pasta de Relatório
Crie a pasta do relatório, se ela ainda não existir, e fornece informações sobre a criação da pasta ou seu status de existência.

### 5. Verificar Arquivo Existente
Verifica se um arquivo existe no caminho especificado.

### 6. Obter Dados da Câmera
Esta função coleta os dados de todas as câmeras, incluindo senhas em texto simples, estatísticas de gravação, informações de retenção e capturas de tela.

### 7. Salvar Relatório em Excel
Salve os dados da câmera em um relatório Excel, permitindo que você atualize um relatório existente ou crie um novo relatório.

## Script Principal

O script principal executa as seguintes etapas:

1. Configuração de credenciais usando a função `Credenciamento`.
2. Configuração das definições do relatório com a função `Configurar Relatório`.
3. Conexão ao servidor Milestone e autenticação com a função `Módulo Milestone`.
4. Criação da pasta de relatório usando a função `Criar Pasta de Relatório`.
5. Recuperação de dados da câmera com `Obter Dados da Câmera`.
6. Salvamento dos dados da câmera em um relatório Excel com `Salvar Relatório em Excel`.

Este script simplifica o processo de criação de relatórios de câmeras no sistema de gerenciamento de vídeo Milestone, com opções de personalização e facilidade de uso.

## Rescrito
Víctor Gabriel Cruz Pereira

## Contato
- Email: victorgabrielcruzpereira21@gmail.com
- Email: v.g.pplayer21@gmail.com
- Email: vgcp@aluno.ifnmg.edu.br
