Aqui está o código corrigido, levando em consideração as sugestões mencionadas:
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
# [1.3] Valida as configurações

function PerformPing {
    param (
        [string]$ipAddress
    )
    try {
        $pingResponse = Test-Connection -ComputerName $ipAddress -Count 1 -ErrorAction Stop
        $online = $true
        $latency = $pingResponse.ResponseTime
    }
    catch {
        $online = $false
        $latency = 0
        Write-Host "Ping para $($ipAddress): Falhou, Erro: $($_.Exception.Message)" -logLevel "ERROR"
    }
     
    if ($online) {
        Write-Host "Ping para $($ipAddress): Online, Latência $($latency) ms"
    }

    return [PSCustomObject]@{
        Online = $online
        Latency = $latency
    }
}
# [1.4] Desabilita um dispositivo
function Disable-Device {
    param (
        [PSCustomObject]$device
    )

    Write-Host "Desabilitando o dispositivo $($device.Name)..."
    
    try {
        Set-VmsHardware -Hardware $device -Enabled $false 
        Write-Host "Dispositivo $($device.Name) foi desabilitado com sucesso."
    } catch {
        Write-Host "Falha ao desabilitar o dispositivo $($device.Name): $_"
    }
}
# [2.0] Main
# [2.1] VARIÁVEIS GLOBAIS

$connected = $false
$iterationNumber = 0
# [2.2] CONFIGURAÇÃO DO SCRIPT
$config = @{
    MaxDevicesPerIteration = 50
    PingCount = 4
    ShowOutput = $true
    MinPingSuccessRate = 0.85
    AverageLatencyThreshold = 1200
    WaitTimeBetweenFullIterations = 10
    IterationsPerGroup = 4
    WaitTimeBetweenGroupIterations = 6
    MaxConnectionAttempts = 2
    ConnectionAttemptInterval = 10
}
Credenciamento -op ([ref]$op) -serverAddress ([ref]$serverAddress) -useDialog ([ref]$useDlg) -useWindowsCredentials ([ref]$useWinCred) -useBasicUser ([ref]$useBasic) -username ([ref]$username) -password ([ref]$password)
$allHardware = Get-VmsHardware | Where-Object { $_.Enabled -eq $true }
$allHardware = $allHardware | Sort-Object -Property Address | Get-Unique -AsString
try {
    if (-not $allHardware) {
        Write-Host "Nenhum dispositivo registrado no momento."
        Start-Sleep -Seconds $config.WaitTimeBetweenFullIterations
        continue
    }

    $totalDevices = $allHardware.Count
    $iterationsRequired = [math]::Ceiling($totalDevices / $config.MaxDevicesPerIteration)
    $pingsPerIteration = $config.IterationsPerGroup * $config.PingCount
    $tempoMedioPing = 2  

    for ($i = 0; $i -lt $iterationsRequired; $i++) {
        Write-Host "Processando grupo de dispositivos $(($i + 1)) de $iterationsRequired..."
        $devicesToProcess = $allHardware | Select-Object -Skip ($i * $config.MaxDevicesPerIteration) -First $config.MaxDevicesPerIteration

        # Determina quantos dispositivos estão neste grupo
        $devicesInCurrentGroup = $devicesToProcess.Count

        # Estimativa de tempo para este grupo específico
        $tempo_ping_grupo_atual = $pingsPerIteration * $tempoMedioPing * $devicesInCurrentGroup
        $tempo_estimado_grupo_atual = $tempo_ping_grupo_atual + $config.WaitTimeBetweenGroupIterations

        if ($tempo_estimado_grupo_atual -lt 60) {
            $tempoEstimadoGrupoFormatado = "{0}s" -f $tempo_estimado_grupo_atual
        } else {
            $minutes = [math]::Floor($tempo_estimado_grupo_atual / 60)
            $seconds = $tempo_estimado_grupo_atual % 60
            $tempoEstimadoGrupoFormatado = "{0}m:{1}s" -f $minutes, $seconds
        }

        Write-Host "Estimativa de tempo para este grupo: $tempoEstimadoGrupoFormatado"

        foreach ($device in $devicesToProcess) {
            Write-Host "Iniciando processamento do dispositivo $($device.Name)..."
            
            $pingFailures = 0
            
            for ($j = 0; $j -lt $config.IterationsPerGroup; $j++) {
                Write-Host "Processando dispositivo $($device.Name) - Iteração $(($j + 1)) de $($config.IterationsPerGroup)..."
                
                for ($k = 0; $k -lt $config.PingCount; $k++) {
                    $originalUrl = $device.Address
                    $pattern = "(?<=://)([^\s:/]+)"
                    $ip = [regex]::Match($originalUrl, $pattern).Value
                    $pingResult = PerformPing -ipAddress $ip

                    if ($pingResult.Online) {
                        Write-Host "Ping $(($k + 1)) para o dispositivo $($device.Name): Online, Latência $($pingResult.Latency) ms"
                    } else {
                        Write-Host "Ping $(($k + 1)) para o dispositivo $($device.Name): Offline"
                        $pingFailures++
                    }

                    if ($k -lt $config.PingCount - 1) {
                        Start-Sleep -Seconds 2
                    }
                }

                Start-Sleep -Seconds $config.WaitTimeBetweenGroupIterations
            }

            $totalPings = $config.IterationsPerGroup * $config.PingCount
            if ($pingFailures -ge ($totalPings * (1 - $config.MinPingSuccessRate)) -or $pingResult.Latency -gt $config.AverageLatencyThreshold) {
                Write-Host "Desabilitando o dispositivo $($device.Name) devido à baixa taxa de sucesso ou alta latência."
                Disable-Device -device $device
            }

            Write-Host "Concluído o processamento do dispositivo $($device.Name)..."
        }

        Write-Host "Concluído o processamento do grupo de dispositivos $(($i + 1)) de $iterationsRequired."
        Start-Sleep -Seconds $config.WaitTimeBetweenGroupIterations
    }
} catch {
    Write-Host "Erro durante a iteração de monitoramento: $_"
} finally {
    # Desconecta do Milestone no final de cada iteração
    if ($connected) {
        Disconnect-ManagementServer
        Write-Host "Desconectado do Milestone após a iteração #$iterationNumber."
        $connected = $false
    }

    Write-Host "Concluída a iteração completa de monitoramento #$iterationNumber."
    Start-Sleep -Seconds $config.WaitTimeBetweenFullIterations
}
