# [1.0] Funcoes
# [1.1] Funcao do credenciamento
function Credenciamento {
    param (
        [ref]$op,
        [ref]$serverAddress,
        [ref]$useDialog,
        [ref]$useWindowsCredentials,
        [ref]$useBasicUser,
        [ref]$username,
        [ref]$password
    )

    try {
        
        while ($true) {
            $op.Value = Read-Host "Escolha qual das opcoes deseja habilitar?`n[1] Dialogo de login`n[2] Credenciais do Windows `n[3] Usuario basico Milestone (Recomendado) "
            if ($op.Value -eq '1') {
                $useDialog.Value = $true
                $useWindowsCredentials.value = $false
                $useBasicUser.value = $false
                break
            }
            elseif ($op.Value -eq '2') {
                $useDialog.Value = $false
                $useWindowsCredentials.Value = $true
                $useBasicUser.value = $false                
                break
            }
            elseif ($op.Value -eq '3') {
                $useDialog.Value = $false
                $useWindowsCredentials.Value = $false
                $useBasicUser.value = $true 
                $stringconnection = Read-Host "Informe o endereco do servidor"
                $uriValue = $serverAddress.Value
                $username.Value = Read-Host "Informe o seu nome de usuario"
                $password.Value = Read-Host "Informe a senha" 
                if ($null -eq $uriValue.Value) {
                    $serverAddress.Value = [System.Uri]::new($stringconnection)
                }
                else{
                    Write-Host "Erro"
                }              
                break
            }
            else {
                Write-Host "Opcao invalida"
            }
        }
    }
    catch {
        Write-Host "Erro no credenciamento: $_"
        Write-Host $errorInfo
        Add-Content -Path "log.txt" -Value $errorInfo
    }
}
# [1.3] Configuracao do servidor MILESTONE
function Modulo_Milestone {
    param (
        [ref]$useDialog,
        [ref]$useWindowsCredentials,
        [ref]$server,
        [ref]$useBasicUser,
        [ref]$password,
        [ref]$username
    )
    $teste = $null
    try {
        Write-Host "Tentando conectar"
        if ($useDialog.Value) {
            $server.Value = "http://localhost/"
            $serverAddressUri = [System.Uri]::new($server.Value)
            Write-Host "Autenticando e conectando usando dialogo de login..."
            $serverAddressUri = [System.Uri]::new($server.Value)
            Connect-ManagementServer -ServerAddress $serverAddressUri -Credential $credential -BasicUser:$useBasicUser.Value -Force -AcceptEula

            $teste = $true
        }
        elseif ($useWindowsCredentials.Value){
            Write-Host "Autenticando e conectando usando credenciais do Windows..."
            
            # Solicita as credenciais do Windows ao usuÃ¡rio
            $credential = [System.Management.Automation.PSCredential]::Empty
            $server.Value = "http://localhost/"
            $serverAddressUri = [System.Uri]::new($server.Value)
            # Conecta ao servidor usando as credenciais do Windows
            Connect-ManagementServer -ServerAddress $serverAddressUri -Credential $credential.Value -Force -AcceptEula

            $teste = $true
        }
        elseif ($useBasicUser.Value) {
            $credential = $null
            Write-Host "Autenticando e conectando usando usuario basico Milestone..."
            $serverAddressUri = [System.Uri]::new($server.Value)
            Connect-ManagementServer -ServerAddress $serverAddressUri -Credential $credential -BasicUser:$useBasicUser.Value -Force -AcceptEula
            $teste = $true
        }
        else{
            Write-Host "Erro"
        }
    }
    catch {
        Write-Host "Erro no Modulo_Milestone: $_"
        Write-Host $errorInfo
        Add-Content -Path "log.txt" -Value $errorInfo
        $teste = $false
        
    }
    finally {
        Connect-Vms -ServerAddress $server.Value -Credential $credential.Value 
        if ($teste) {
            Write-Host "Conexao realizada com sucesso"
        }
        else {
            Write-Host "Falha ao conectar ao servidor"
        }
    }
}
# [1.4] Criacao de pasta de relatorios
function Create_ReportFolder {
    param (
        [ref]$reportPath,
        [ref]$path
    )

    try {
        if (-not (Test-Path -Path $reportPath.Value -PathType Container)) {
            New-Item -Path $reportPath.Value -ItemType Directory -Name $path
            Write-Host "Pasta de relatorios criada em: $($reportPath.Value)"
        }
        
    }
    catch {
        Write-Host "Erro em Create-ReportFolder: $_"
        Write-Host $errorInfo
        Add-Content -Path "log.txt" -Value $errorInfo
    }
}
# [1.5] Verificar se o arquivo existe
function Test-FileExists($path) {
    return Test-Path -Path $path -PathType Leaf
}
# [1.6] Obtendo os dados de todas as camaras
function Get-CameraData {
    $cameraReportData = Get-VmsCameraReport -IncludePlainTextPasswords -IncludeRecordingStats -IncludeRetentionInfo -IncludeSnapshots
    return $cameraReportData
}
# [1.7] Salvar relatorio em Excel

function Save-ExcelReport {
    param(
        [ref]$data,
        [ref]$reportPath,
        [ref]$reportFileName
    )
    try {
        $excelPath = Join-Path -Path $reportPath.Value -ChildPath $reportFileName.Value
        if (Test-FileExists $excelPath) {
        Remove-Item -Path $excelPath -Force
            
        Export-Excel -InputObject $data.Value -Path $excelPath -WorksheetName "Relatorio" -AutoSize -TableStyle Medium6 -FreezeTopRow -TableName "Dados"
            
        }
        else {
            Export-Excel -InputObject $data.Value -Path $excelPath -WorksheetName "Relatorio" -AutoSize -TableStyle Medium6 -FreezeTopRow -TableName "Dados"
        }
        Write-Host "Relatorio atualizado e salvo em formato Excel: $excelPath"
    }
    catch {
        Write-Host "Erro em Save-ExcelReport: $_"
        Write-Host $errorInfo
        Add-Content -Path "log.txt" -Value $errorInfo
    }
}
# [2.0] Main
$serverAddress = ""
$useDlg = $null
$useWinCred = $null
$useBasic = $null
$username = $null
$password = $null
$reportPath= "C:\milestone\reports"
$path = $null
$cameraData = $null
$op = $null
Credenciamento -op ([ref]$op) -serverAddress ([ref]$serverAddress) -useDialog ([ref]$useDlg) -useWindowsCredentials ([ref]$useWinCred) -useBasicUser ([ref]$useBasic) -username ([ref]$username) -password ([ref]$password)

$reportFileName = Read-Host "Informe o nome do arquivo do relatorio (ex: CustomReport.xlsx)" 

Modulo_Milestone -useDialog ([ref]$useDlg) -useWindowsCredentials ([ref]$useWinCred) -server ([ref]$serverAddress) -useBasicUser ([ref]$useBasic) -password ([ref]$password) -username ([ref]$username)

$cameraData = Get-CameraData
Create_ReportFolder -reportPath ([ref]$reportPath)
Save-ExcelReport  -data ([ref]$cameraData) -reportPath ([ref]$reportPath) -reportFileName ([ref]$reportFileName)   

