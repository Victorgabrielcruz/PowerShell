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
            $op.Value = Read-Host "Escolha qual das opcoes deseja habilitar?`n[1] Dialogo de login`n[2] Credenciais do Windows `n[3] Usuario basico Milestone"
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
                while($true){
                    $stringconnection = Read-Host "Informe o endereco do servidor"
                    try{
                        if ([System.Uri]::IsWellFormedUriString($stringconnection, [System.UriKind]::Absolute)) {
                            Write-Host "O endereco do servidor e uma URI valida."
                            $serverAddress.Value = [System.Uri]::new($stringconnection)
                            $pingResult = Test-Connection -ComputerName $serverAddress.Value.Host -Count 1 -Quiet
                            if ($pingResult) {
                                Write-Host "O servidor e valido e acessÃ­vel."
                                break
                            }
                            else{
                                Write-Host "O servidor nao esta acessivel."
                                Write-Host "Tente novamente."
                            }
        
                        } else {
                            Write-Host "O endereco do servidor nÃ£o Ã© uma URI vÃ¡lida. Por favor, forneÃ§a um endereÃ§o vÃ¡lido."
                        }
                    }catch{
                        Write-Host "Erro no servidor"
                    }
                    
                }
                $username.Value = Read-Host "Informe o seu nome de usuario"
                $password.Value = Read-Host "Informe a senha"            
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
# [1.2] Configuracao do servidor MILESTONE
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
            Connect-ManagementServer -ServerAddress $serverAddressUri -Credential $credential -BasicUser:$useBasicUser.Value -Force -AcceptEula

            $teste = $true
        }
        elseif ($useWindowsCredentials.Value){
            Write-Host "Autenticando e conectando usando credenciais do Windows..."
            
            # Solicita as credenciais do Windows ao usuÃƒÂ¡rio
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
# [1.3] Obtendo os dados de todas as camaras
function Get-CameraReport {
    $cameraReportData = Get-VmsCameraReport -IncludePlainTextPasswords -IncludeRecordingStats -IncludeRetentionInfo -IncludeSnapshots
    return $cameraReportData
}
# [2.0] Main
$serverAddress = ""
$useDlg = $null
$useWinCred = $null
$useBasic = $null
$username = $null
$password = $null
$op = $null
Credenciamento -op ([ref]$op) -serverAddress ([ref]$serverAddress) -useDialog ([ref]$useDlg) -useWindowsCredentials ([ref]$useWinCred) -useBasicUser ([ref]$useBasic) -username ([ref]$username) -password ([ref]$password)
Modulo_Milestone -useDialog ([ref]$useDlg) -useWindowsCredentials ([ref]$useWinCred) -server ([ref]$serverAddress) -useBasicUser ([ref]$useBasic) -password ([ref]$password) -username ([ref]$username)
$report = Get-CameraReport
foreach ($row in $report) {
    $networkState = 'Online'
    
    if ($row.State -eq 'Not Responding') {
        $uri = [Uri]$row.Address
        $reachable = Test-NetConnection -ComputerName $uri.Host -Port $uri.Port -InformationLevel Quiet
        if (-not $reachable) {
            $networkState = 'Offline'
        }
    }

    $row | Add-Member -MemberType NoteProperty -Name 'NetworkState' -Value $networkState
}
$report | Out-GridView