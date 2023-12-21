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
# [1.3] Funcao para agrupar dispositivos por modelo
function Group-DevicesByModel {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0, ValueFromPipelineByPropertyName, Mandatory)]
        [string]
        $BaseGroupPath,

        [Parameter(Position = 1, ValueFromPipelineByPropertyName)]
        [ValidateRange(1, 400)]
        [int]
        $MaxGroupSize = 400,

        [Parameter(Position = 2)]
        [string]
        $DeviceType = "Camera"  # Tipo de dispositivo padr�o
    )

    process {
        $parentProgress = @{
            Activity        = 'Creating groups by model'
            Status          = 'Discovering models'
            Id              = Get-Random
            PercentComplete = 0
        }
        $childProgress = @{
            Activity        = 'Populating groups'
            Id              = Get-Random
            ParentId        = $parentProgress.Id
            PercentComplete = 0
        }
        try {
            Write-Progress @parentProgress
            
            Write-Host "Removing group '$BaseGroupPath' if present"
            Clear-VmsCache
            Get-VmsDeviceGroup -Path $BaseGroupPath -ErrorAction SilentlyContinue | Remove-VmsDeviceGroup -Recurse -Confirm:$false -ErrorAction Stop
            
            Write-Host "Discovering all enabled $DeviceType devices"
            $ms = [VideoOS.Platform.ConfigurationItems.ManagementServer]::new((Get-VmsSite).FQID.ServerId)
            $filters = 'RecordingServer', 'Hardware', $DeviceType | ForEach-Object {
                [VideoOS.ConfigurationApi.ClientService.ItemFilter]::new($_, $null, 'Enabled')
            }
            $ms.FillChildren($filters.ItemType, $filters)

            $parentProgress.Status = 'Grouping and sorting devices'
            Write-Progress @parentProgress

            Write-Host "Sorting $DeviceType devices by model"
            $modelGroups = $ms.RecordingServerFolder.RecordingServers.HardwareFolder.Hardwares | Group-Object Model | Sort-Object Name
            $totalDevices = ($modelGroups.Group.($DeviceType + "Folder").($DeviceType + "s")).Count
            $devicesProcessed = 0

            $parentProgress.Status = 'Processing'
            Write-Progress @parentProgress

            foreach ($group in $modelGroups) {
                $modelName = $group.Name
                $safeModelName = $modelName.Replace('/', '`/')
                
                $devices = $group.Group.($DeviceType + "Folder").($DeviceType + "s") | Sort-Object Name
                $totalForModel = $devices.Count
                
                
                $childProgress.Status = "Current: $BaseGroupPath/$modelName"                
                $parentProgress.PercentComplete = $devicesProcessed / $totalDevices * 100
                Write-Progress @parentProgress

                # Modificacao aqui: Formato do nome da pasta de modelo
                $modelNameFormatted = "$safeModelName ($($folderNameFormat -f $totalForModel))"
                $groupName = "$BaseGroupPath/$modelNameFormatted"
                Write-Host "Creating group $groupName"
                $group = New-VmsDeviceGroup -Type $DeviceType -Path $groupName
                
                foreach ($device in $devices) {
                    Add-VmsDeviceGroupMember -Group $group -Device $device
                    $devicesProcessed++
                }
            }
        } catch {
            Add-LogMessage "Erro durante a execu��o da fun��o Group-DevicesByModel: $_"
        } finally {
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
Credenciamento -op ([ref]$op) -serverAddress ([ref]$serverAddress) -useDialog ([ref]$useDlg) -useWindowsCredentials ([ref]$useWinCred) -useBasicUser ([ref]$useBasic) -username ([ref]$username) -password ([ref]$password)
Modulo_Milestone -useDialog ([ref]$useDlg) -useWindowsCredentials ([ref]$useWinCred) -server ([ref]$serverAddress) -useBasicUser ([ref]$useBasic) -password ([ref]$password) -username ([ref]$username)
$folderNameFormat = "Qtde = {0}"
$rootGroupName = "GERAL"
$baseGroupPath = "/$rootGroupName"
Group-DevicesByModel -BaseGroupPath $baseGroupPath -DeviceType "Metadata"