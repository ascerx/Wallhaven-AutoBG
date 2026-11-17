$ErrorActionPreference = 'Continue'

$iso = 'D:\HyperV\ubuntu-24.04.4-desktop-amd64.iso'
"=========================================================="
"  Reparacion de la VM Ubuntu (montar ISO correcta)"
"=========================================================="

if (-not (Test-Path $iso)) { "FALTA la ISO: $iso"; Read-Host ENTER; exit 1 }

"--- VMs actuales ---"
$vms = Get-VM
foreach ($v in $vms) {
    $dvd = (Get-VMDvdDrive -VM $v.Name).Path
    "  $($v.Name) | Gen$($v.Generation) | $($v.State) | DVD: $dvd"
}

"--- Apagando todas las VMs en ejecucion ---"
Get-VM | Where-Object { $_.State -eq 'Running' } | Stop-VM -Force -TurnOff
Start-Sleep -Seconds 4
"[OK] apagadas"

$vm = Get-VM | Where-Object { $_.Name -like '*Ubuntu*' } | Select-Object -First 1
if (-not $vm) {
    "No existe ninguna VM con 'Ubuntu' en el nombre."
    "Ejecuta crear-vm-ubuntu.cmd para crearla."
    Read-Host "ENTER para salir"
    exit 1
}

"--- Configurando '$($vm.Name)' ---"
Set-VMDvdDrive -VMName $vm.Name -Path $iso
if ($vm.Generation -ge 2) {
    Set-VMFirmware -VMName $vm.Name -EnableSecureBoot On -SecureBootTemplate MicrosoftUEFICertificateAuthority
}
$dvd = Get-VMDvdDrive -VMName $vm.Name
Set-VMFirmware -VMName $vm.Name -FirstBootDevice $dvd
"[OK] ISO de 24.04.4 montada + arranque desde DVD"

"--- Arrancando y abriendo consola ---"
Start-VM -Name $vm.Name
Start-Sleep -Seconds 3
vmconnect.exe localhost $vm.Name

""
"Ahora en la consola deberias ver el menu GRUB del instalador"
"de Ubuntu (o el logo de Ubuntu con el spinner de carga)."
"Si sale negro mas de 2-3 minutos, cuentame que dice."
""

Read-Host "Pulsa ENTER para cerrar"
