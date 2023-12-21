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
                while ($true) {
                    $stringconnection = Read-Host "Informe o endereco do servidor"
                    try {
                        if ([System.Uri]::IsWellFormedUriString($stringconnection, [System.UriKind]::Absolute)) {
                            Write-Host "O endereco do servidor e uma URI valida."
                            $serverAddress.Value = [System.Uri]::new($stringconnection)
                            $pingResult = Test-Connection -ComputerName $serverAddress.Value.Host -Count 1 -Quiet
                            if ($pingResult) {
                                Write-Host "O servidor e valido e acessível."
                                break
                            }
                            else {
                                Write-Host "O servidor nao esta acessivel."
                                Write-Host "Tente novamente."
                            }
                        }
                        else {
                            Write-Host "O endereco do servidor nao e uma URI valida. Por favor, forneça um endereco valido."
                        }
                    }
                    catch {
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
        $errorMessage = "Erro no credenciamento: $_"
        Write-Error $errorMessage
        Add-Content -Path "log.txt" -Value $errorMessage
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
        elseif ($useWindowsCredentials.Value) {
            Write-Host "Autenticando e conectando usando credenciais do Windows..."
            $credential = [System.Management.Automation.PSCredential]::Empty
            $server.Value = "http://localhost/"
            $serverAddressUri = [System.Uri]::new($server.Value)
            Connect-ManagementServer -ServerAddress $serverAddressUri -Credential $credential -Force -AcceptEula
            $teste = $true
        }
        elseif ($useBasicUser.Value) {
            $credential = $null
            Write-Host "Autenticando e conectando usando usuario basico Milestone..."
            $serverAddressUri = [System.Uri]::new($server.Value)
            Connect-ManagementServer -ServerAddress $serverAddressUri -Credential $credential -BasicUser:$useBasicUser.Value -Force -AcceptEula
            $teste = $true
        }
        else {
            Write-Host "Erro"
        }
    }
    catch {
        $errorMessage = "Erro no Modulo_Milestone: $_"
        Write-Error $errorMessage
        Add-Content -Path "log.txt" -Value $errorMessage
        $teste = $false
    }
    finally {
        Connect-Vms -ServerAddress $server.Value -Credential $credential
        if ($teste) {
            Write-Host "Conexao realizada com sucesso"
        }
        else {
            Write-Host "Falha ao conectar ao servidor"
        }
    }
}
# [1.3] Criando os grupos
function Group-CamerasByModel {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0, ValueFromPipelineByPropertyName, Mandatory)]
        [string]$BaseGroupPath,
 
        [Parameter(Position = 1, ValueFromPipelineByPropertyName)]
        [ValidateRange(1, 400)]
        [int]$MaxGroupSize = 400
    )
 
    process {
        $parentProgress = @{
            Activity        = 'Creating camera groups by model'
            Status          = 'Discovering camera models'
            Id              = Get-Random
            PercentComplete = 0
        }
        $childProgress = @{
            Activity        = 'Populating camera groups'
            Id              = Get-Random
            ParentId        = $parentProgress.Id
            PercentComplete = 0
        }
        try {
            Add-LogMessage "Iniciando o agrupamento de câmeras por modelo..."
            Write-Progress @parentProgress
            
            Write-Verbose "Removing camera group '$BaseGroupPath' if present"
            Clear-VmsCache
            Get-VmsDeviceGroup -Path $BaseGroupPath -ErrorAction Stop | Remove-VmsDeviceGroup -Recurse -Confirm:$false -ErrorAction Stop
            
            Write-Verbose 'Discovering all enabled cameras'
            $ms = [VideoOS.Platform.ConfigurationItems.ManagementServer]::new((Get-VmsSite).FQID.ServerId)
            $filters = 'RecordingServer', 'Hardware', 'Camera' | ForEach-Object {
                [VideoOS.ConfigurationApi.ClientService.ItemFilter]::new($_, $null, 'Enabled')
            }
            $ms.FillChildren($filters.ItemType, $filters)
 
            $parentProgress.Status = 'Grouping and sorting cameras'
            Write-Progress @parentProgress
 
            Write-Verbose 'Sorting cameras by model'
            $modelGroups = $ms.RecordingServerFolder.RecordingServers.HardwareFolder.Hardwares | Group-Object Model | Sort-Object Name
            $totalCameras = ($modelGroups.Group.CameraFolder.Cameras).Count
            $camerasProcessed = 0
 
            $parentProgress.Status =

 'Processing'
            Write-Progress @parentProgress
 
            foreach ($group in $modelGroups) {
                $modelName = $group.Name
                $safeModelName = $modelName.Replace('/', '`/')
                
                # Determinar o caminho base para este modelo
                if ($modelo -eq 1) {
                    # Criando o grupo para o modelo da câmera
                    $modelGroupPath = "$BaseGroupPath/$safeModelName"
                    New-VmsDeviceGroup -Type Camera -Path $modelGroupPath | Out-Null
                }
                else {
                    $modelGroupPath = $BaseGroupPath
                }
                
                $cameras = $group.Group.CameraFolder.Cameras | Sort-Object Name
                $totalForModel = $cameras.Count
                $groupNumber = $positionInGroup = 1
                $group = $null
                
                if ($modelo -eq 1) {
                    $childProgress.Status = "Current: $modelGroupPath"
                }
                elseif ($modelo -eq 2) {
                    $childProgress.Status = "Current: $modelGroupPath/$safeModelName ($folderNameFormat)" -f $totalForModel
                    $parentProgress.PercentComplete = $camerasProcessed / $totalCameras * 100
                    Write-Progress @parentProgress
                   
                    Write-Verbose "Creating groups for $totalForModel cameras of model '$modelName'"
                    for ($i = 0; $i -lt $totalForModel; $i++) {
                        $childProgress.PercentComplete = $i / $totalForModel * 100
                        Write-Progress @childProgress
                        if ($null -eq $group) {
                            $first = $groupNumber * $MaxGroupSize - ($MaxGroupSize - 1)
                            $last = $groupNumber * $MaxGroupSize
                            if ($totalForModel - ($i + 1) -lt $MaxGroupSize) {
                                $last = $totalForModel
                            }
                            if ($modelo -eq 1) {
                                $groupName = '{0}-{1}' -f $first, $last
                            }
                            elseif ($modelo -eq 2) {
                                $groupName = "$safeModelName ($folderNameFormat)" -f $totalForModel
                            }
                            Write-Verbose "Creating group $modelGroupPath/$groupName"
                            $group = New-VmsDeviceGroup -Type Camera -Path "$modelGroupPath/$groupName"
                        }
                      
                        Add-VmsDeviceGroupMember -Group $group -Device $cameras[$i]
                      
                        $camerasProcessed++
                        $positionInGroup++
                        if ($positionInGroup -gt $MaxGroupSize) {
                            $group = $null
                            $positionInGroup = 1
                            $groupNumber++
                        }
                    }
                }
               
                Add-LogMessage "Agrupamento de câmeras por modelo concluído com sucesso."
            }
        } 
        catch {
            $errorMessage = "Erro durante a execução da função Group-CamerasByModel: $($_.Exception.Message)"
            Write-Error $errorMessage
            Add-LogMessage $errorMessage
        }
        finally {
            $childProgress.Completed = $true
            Write-Progress @childProgress
        
            $parentProgress.Completed = $true
            Write-Progress @parentProgress
        }
    }
}                     

# [2.0] Main
$serverAddress = ""
$useDlg = $null
$useWinCred = $null
$useBasic = $null
$username = $null
$password = $null
$op = $null
$modelo = $null
$folderNameFormat = "TOTAL ={0} DISPOSITIVOS"
$rootGroupName = "Manutenção1"
Credenciamento -op ([ref]$op) -serverAddress ([ref]$serverAddress) -useDialog ([ref]$useDlg) -useWindowsCredentials ([ref]$useWinCred) -useBasicUser ([ref]$useBasic) -username ([ref]$username) -password ([ref]$password)
Modulo_Milestone -useDialog ([ref]$useDlg) -useWindowsCredentials ([ref]$useWinCred) -server ([ref]$serverAddress) -useBasicUser ([ref]$useBasic) -password ([ref]$password) -username ([ref]$username)

while ($true) {
    $modelo.value = Read-Host "Escolha entre o modelo 1 e 2: "
    if ($modelo.value -eq 1) {
        break
    }
    elseif ($modelo.value -eq 2) {
        break
    }
    else {
        Write-Host "Opcao invalida"
    }
}

$baseGroupPath = "/$rootGroupName"
Group-CamerasByModel -BaseGroupPath $baseGroupPath -MaxGroupSize 400