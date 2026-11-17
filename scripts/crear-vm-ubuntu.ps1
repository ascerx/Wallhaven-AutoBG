# ============================================================
#  Crear y arrancar VM Ubuntu en Hyper-V para probar Wallhaven AutoBG
#  Ejecutar como Administrador (el .cmd se auto-eleva)
# ============================================================
$ErrorActionPreference = 'Continue'

$vmName   = 'Ubuntu-Test'
$vhdPath  = 'D:\HyperV\VMs\Ubuntu-Test.vhdx'
$isoPath  = 'D:\HyperV\ubuntu-24.04.4-desktop-amd64.iso'
$debPath  = "$env:TEMP\opencode\wallhaven-autobg_0.2.0_amd64.deb"

"=== 1) Verificando Hyper-V ==="
$feature = Get-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V-All
if ($feature.State -ne 'Enabled') {
    "Hyper-V no esta activo. Activandolo (requiere reinicio)..."
    Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V-All -NoRestart
    "REINICIA el equipo y vuelve a ejecutar este script."
    exit 1
}
"[OK] Hyper-V activo"

"=== 2) Comprobando ficheros ==="
if (-not (Test-Path $isoPath)) { "FALTA la ISO: $isoPath"; exit 1 }
if (-not (Test-Path $debPath)) { "FALTA el .deb: $debPath"; exit 1 }
"[OK] ISO y .deb presentes"

"=== 3) Firewall: permitiendo puerto 8000 para servir el .deb ==="
netsh advfirewall firewall delete rule name="WallhavenAutoBG-Test" 2>$null | Out-Null
netsh advfirewall firewall add rule name="WallhavenAutoBG-Test" dir=in action=allow protocol=TCP localport=8000 | Out-Null
"[OK] Regla de firewall creada"

"=== 4) Creando VM ==="
$existing = Get-VM -Name $vmName -ErrorAction SilentlyContinue
if ($existing) {
    "La VM ya existe, la reutilizo"
    if ($existing.State -ne 'Off') { Stop-VM -Name $vmName -Force -TurnOff | Out-Null; Start-Sleep -Seconds 3 }
} else {
    New-Item -ItemType Directory -Force -Path (Split-Path $vhdPath) | Out-Null
    $switchName = (Get-VMSwitch | Select-Object -First 1).Name
    "Usando switch: $switchName"
    New-VM -Name $vmName -Generation 2 -MemoryStartupBytes 4GB `
        -NewVHDPath $vhdPath -NewVHDSizeBytes 40GB `
        -SwitchName $switchName | Out-Null
    Set-VMProcessor -VMName $vmName -Count 2
    Set-VMFirmware -VMName $vmName -EnableSecureBoot On -SecureBootTemplate MicrosoftUEFICertificateAuthority
    Set-VM -VMName $vmName -DynamicMemory -MemoryMinimumBytes 2GB -MemoryMaximumBytes 6GB
    "[OK] VM creada"
}

"=== 5) Montando ISO y orden de arranque ==="
$existingDvd = Get-VMDvdDrive -VMName $vmName
if ($existingDvd) {
    Set-VMDvdDrive -VMName $vmName -Path $isoPath
} else {
    Add-VMDvdDrive -VMName $vmName -Path $isoPath
}
$dvd = Get-VMDvdDrive -VMName $vmName
Set-VMFirmware -VMName $vmName -FirstBootDevice $dvd
"[OK] ISO montada como primer arranque"

"=== 6) Arrancando VM y abriendo consola ==="
Start-VM -Name $vmName
Start-Sleep -Seconds 3
vmconnect.exe localhost $vmName
"[OK] VM arrancada - completar la instalacion de Ubuntu en la ventana de consola"

"=== 7) Esperando IP del invitado (poll cada 15 s, max 30 min) ==="
$ip = $null
for ($i = 0; $i -lt 120; $i++) {
    Start-Sleep -Seconds 15
    $ips = (Get-VM -Name $vmName).NetworkAdapters.IPAddresses |
        Where-Object { $_ -match '^\d+\.\d+' -and $_ -notmatch '^169\.254' }
    if ($ips) { $ip = $ips[0]; break }
}
if (-not $ip) {
    "No se obtuvo IP automaticamente. Ejecuta 'ip a' en la VM para verla."
    exit 0
}
"[OK] IP de la VM: $ip"

$hostIp = (Get-NetIPAddress -AddressFamily IPv4 |
    Where-Object { $_.InterfaceAlias -like '*Default Switch*' -or $_.InterfaceAlias -like '*Conmutador predeterminado*' } |
    Select-Object -First 1).IPAddress
if (-not $hostIp) {
    $hostIp = (Get-NetIPAddress -AddressFamily IPv4 -PrefixOrigin Manual,Dhcp |
        Where-Object { $_.IPAddress -notmatch '^169\.' -and $_.IPAddress -ne '127.0.0.1' } |
        Select-Object -First 1).IPAddress
}
"Host IP (Default Switch): $hostIp"

"=== 8) Sirviendo el .deb en http://$($hostIp):8000 ==="
Start-Process powershell -ArgumentList '-NoProfile', '-Command', "Set-Location '$env:TEMP\opencode'; python -m http.server 8000"

@"
============================================================================
  DENTRO DE LA VM UBUNTU (terminal):
    wget http://$($hostIp):8000/wallhaven-autobg_0.2.0_amd64.deb
    sudo dpkg -i ./wallhaven-autobg_0.2.0_amd64.deb
    wallhaven_client
  Luego pestaña Auto -> 'Cambiar ahora' -> el fondo debe cambiar.
============================================================================
"@
