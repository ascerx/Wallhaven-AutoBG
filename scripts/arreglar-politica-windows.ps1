# ============================================================
#  Diagnostico + arreglo de politicas que bloquean ejecutables
#  Ejecutar como Administrador en la maquina afectada
# ============================================================
$ErrorActionPreference = 'Continue'

"=== 1) Politicas SRP (Software Restriction Policies) ==="
$safer = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Safer'
if (Test-Path $safer) {
    Get-ChildItem $safer -Recurse | ForEach-Object {
        "  clave: $($_.Name)"
        $_.Property | ForEach-Object -Begin {} -Process { }
    }
    Get-ItemProperty $safer -ErrorAction SilentlyContinue | Format-List
    $rules = Get-ChildItem "$safer\CodeIdentifiers" -Recurse -ErrorAction SilentlyContinue
    if ($rules) { $rules | ForEach-Object { "  regla: $($_.Name)" } }
} else {
    "[OK] No hay politicas SRP"
}

"=== 2) Politicas AppLocker (SrpV2) ==="
$srpv2 = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\SrpV2'
if (Test-Path $srpv2) {
    Get-ChildItem $srpv2 | ForEach-Object {
        $rule = Get-ItemProperty $_.PSPath
        "  $($_.PSChildName): Enforced=$($rule.EnforcementMode)  Reglas: $($rule.RuleCollections)"
    }
} else {
    "[OK] No hay politicas AppLocker"
}

"=== 3) Ultimos bloqueos en el registro de eventos ==="
try {
    Get-WinEvent -FilterHashtable @{LogName='Application'; Id=866} -MaxEvents 3 -ErrorAction Stop |
        ForEach-Object { "  [$($_.TimeCreated)] $($_.Message)" }
} catch { "  (sin eventos SRP 866)" }
try {
    Get-WinEvent -LogName 'Microsoft-Windows-AppLocker/EXE and DLL' -MaxEvents 3 -ErrorAction Stop |
        ForEach-Object { "  [$($_.TimeCreated)] $($_.Message)" }
} catch { "  (sin eventos AppLocker)" }

""
"=== 4) ELIMINAR las politicas de bloqueo (arreglo) ==="
$answer = Read-Host "Quieres eliminar las politicas SRP/AppLocker de bloqueo? (S/N)"
if ($answer -match '^s') {
    if (Test-Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Safer') {
        Remove-Item 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Safer' -Recurse -Force
        "[OK] SRP eliminado"
    }
    if (Test-Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\SrpV2') {
        Remove-Item 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\SrpV2' -Recurse -Force
        "[OK] AppLocker eliminado"
    }
    gpupdate /force | Out-Null
    "[OK] Politicas refrescadas. Ahora vuelve a ejecutar el instalador."
}
""
Read-Host "Pulsa ENTER para cerrar"
