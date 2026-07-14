# ============================================================
#  STOP-WINDOWSUPDATELOOP.PS1
#  Ferma il ciclo infinito di Windows Update e ripulisce il sistema
#  Eseguire come Amministratore
# ============================================================

Write-Host "=== Stop del ciclo Windows Update ===" -ForegroundColor Cyan

# 1. Annulla un eventuale riavvio già programmato
Write-Host "Annullamento riavvio programmato (se presente)..." -ForegroundColor Yellow
shutdown /a 2>$null

# 2. Rimuovi lo Scheduled Task che rilancia lo script al login
Write-Host "Rimozione Scheduled Task 'SetupWindowsUpdate'..." -ForegroundColor Yellow
Unregister-ScheduledTask -TaskName "SetupWindowsUpdate" -Confirm:$false -ErrorAction SilentlyContinue

# 3. Rimuovi la variabile d'ambiente di stato
Write-Host "Rimozione variabile d'ambiente SETUP_UPDATE_MODE..." -ForegroundColor Yellow
[System.Environment]::SetEnvironmentVariable("SETUP_UPDATE_MODE", $null, "Machine")

# 4. Termina eventuali processi PowerShell residui che eseguono lo script
#    (esclude la sessione corrente)
Write-Host "Controllo processi PowerShell residui..." -ForegroundColor Yellow
$currentPID = $PID
Get-CimInstance Win32_Process -Filter "Name = 'powershell.exe'" |
    Where-Object { $_.ProcessId -ne $currentPID -and $_.CommandLine -match "SetupWindowsUpdate|Install-WindowsUpdate" } |
    ForEach-Object {
        Write-Host "  Termino processo PID $($_.ProcessId)" -ForegroundColor Red
        Stop-Process -Id $_.ProcessId -Force -ErrorAction SilentlyContinue
    }

Write-Host ""
Write-Host "Fatto. Il ciclo di aggiornamenti/riavvii e' stato disattivato." -ForegroundColor Green
Write-Host "Nessun nuovo riavvio automatico verra' programmato." -ForegroundColor Green
