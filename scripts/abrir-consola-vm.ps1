$ErrorActionPreference = 'Continue'

"=========================================================="
"  Estado de Hyper-V / VMs"
"=========================================================="

$feature = Get-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V-All
"Hipervisor: $((Get-CimInstance Win32_ComputerSystem).HypervisorPresent)  |  Feature: $($feature.State)"
""

$vms = Get-VM
if (-not $vms) {
    "No hay ninguna VM creada. Ejecuta de nuevo crear-vm-ubuntu.cmd"
} else {
    "VMs encontradas:"
    $vms | ForEach-Object {
        $ip = ($_.NetworkAdapters.IPAddresses | Where-Object { $_ -match '^\d+\.\d+' -and $_ -notmatch '^169\.' }) -join ', '
        "  $($_.Name)  Estado=$($_.State)  CPU=$($_.ProcessorCount)  Mem=$([Math]::Round($_.MemoryAssigned/1MB))MB  IP=$ip"
    }
    ""
    $ubuntu = Get-VM | Where-Object { $_.Name -like '*Ubuntu*' } | Select-Object -First 1
    if ($ubuntu) {
        if ($ubuntu.State -ne 'Running') { Start-VM $ubuntu.Name }
        Start-Sleep -Seconds 2
        "Abriendo consola de '$($ubuntu.Name)' ..."
        vmconnect.exe localhost $ubuntu.Name
    }
}

""
"=========================================================="
"  Si la ventana de la consola no aparece, mira la BARRA DE"
"  TAREAS: un icono llamado 'Ubuntu-Test - Virtual Machine'"
"  o 'Virtual Machine Connection'. Haz clic en el."
"  Aviso: la primera vez Ubuntu tarda 1-3 min en mostrar"
"  el instalador (arranca desde la ISO)."
"=========================================================="
""
Read-Host "Pulsa ENTER para cerrar esta ventana"
