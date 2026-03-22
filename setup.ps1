# ============================================================
#  SETUP AUTOMATICO - setup.ps1
# ============================================================

# Auto-elevazione admin
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    Exit
}

Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope LocalMachine -Force

# Legge il flag passato dal Scheduled Task per sapere se siamo in modalita post-riavvio
$UpdateMode = [System.Environment]::GetEnvironmentVariable("SETUP_UPDATE_MODE", "Machine")

# ============================================================
#  BLOCCO PRIMO AVVIO - salta se siamo in post-riavvio update
# ============================================================
if ($UpdateMode -ne "1") {

    # ---- WALLPAPER ----
    Write-Host "Impostazione sfondo..." -ForegroundColor Cyan
    $wpUrl  = "https://r4.wallpaperflare.com/wallpaper/58/631/685/windows-11-microsoft-hd-wallpaper-323833af44ece00a7ca43c56beaf0f2b.jpg"
    $wpPath = Join-Path $env:APPDATA "wallpaper.jpg"
    Invoke-WebRequest -Uri $wpUrl -OutFile $wpPath -UseBasicParsing

    Add-Type @"
using System;
using System.Runtime.InteropServices;
public class Wallpaper {
    [DllImport("user32.dll")]
    public static extern int SystemParametersInfo(int uAction, int uParam, string lpvParam, int fuWinIni);
}
"@
    [Wallpaper]::SystemParametersInfo(20, 0, $wpPath, 3) | Out-Null
    Write-Host "Sfondo impostato." -ForegroundColor Green

    # ---- LOCKSCREEN ----
    Write-Host "Impostazione lockscreen..." -ForegroundColor Cyan

    # Disabilita Spotlight
    $regSpotlight = "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager"
    New-ItemProperty -Path $regSpotlight -Name RotatingLockScreenEnabled        -Value 0 -PropertyType DWORD -Force | Out-Null
    New-ItemProperty -Path $regSpotlight -Name RotatingLockScreenOverlayEnabled -Value 0 -PropertyType DWORD -Force | Out-Null
    New-ItemProperty -Path $regSpotlight -Name SubscribedContent-338387Enabled  -Value 0 -PropertyType DWORD -Force | Out-Null

    # Percorso lockscreen accessibile anche da admin
    $lockDest = "C:\Windows\Web\Screen\lockscreen.jpg"
    Copy-Item -Path $wpPath -Destination $lockDest -Force

    # PersonalizationCSP: funziona su Home e Pro
    $cspPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\PersonalizationCSP"
    if (-not (Test-Path $cspPath)) { New-Item -Path $cspPath -Force | Out-Null }
    New-ItemProperty -Path $cspPath -Name LockScreenImagePath   -Value $lockDest -PropertyType String -Force | Out-Null
    New-ItemProperty -Path $cspPath -Name LockScreenImageUrl    -Value $lockDest -PropertyType String -Force | Out-Null
    New-ItemProperty -Path $cspPath -Name LockScreenImageStatus -Value 1         -PropertyType DWORD  -Force | Out-Null
    Write-Host "Lockscreen impostata." -ForegroundColor Green

    # ---- MENU CONTESTUALE CLASSICO (Windows 11) ----
    Write-Host "Ripristino menu contestuale classico..." -ForegroundColor Cyan
    reg add "HKCU\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32" /f /ve
    taskkill /f /im explorer.exe
    Start-Sleep -Seconds 2
    Start-Process explorer.exe
    Write-Host "Menu contestuale classico attivato." -ForegroundColor Green

    # ---- UAC ----
    Write-Host "Disabilitazione UAC..." -ForegroundColor Cyan
    $uacPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System"
    New-ItemProperty -Path $uacPath -Name ConsentPromptBehaviorAdmin    -Value 0 -PropertyType DWORD -Force | Out-Null
    New-ItemProperty -Path $uacPath -Name ConsentPromptBehaviorUser     -Value 3 -PropertyType DWORD -Force | Out-Null
    New-ItemProperty -Path $uacPath -Name EnableInstallerDetection      -Value 1 -PropertyType DWORD -Force | Out-Null
    New-ItemProperty -Path $uacPath -Name EnableLUA                     -Value 0 -PropertyType DWORD -Force | Out-Null
    New-ItemProperty -Path $uacPath -Name EnableVirtualization          -Value 0 -PropertyType DWORD -Force | Out-Null
    New-ItemProperty -Path $uacPath -Name PromptOnSecureDesktop         -Value 0 -PropertyType DWORD -Force | Out-Null
    New-ItemProperty -Path $uacPath -Name ValidateAdminCodeSignatures   -Value 0 -PropertyType DWORD -Force | Out-Null
    New-ItemProperty -Path $uacPath -Name FilterAdministratorToken      -Value 0 -PropertyType DWORD -Force | Out-Null
    Write-Host "UAC disabilitato." -ForegroundColor Green

    # ---- TEMA SCURO ----
    Write-Host "Attivazione tema scuro..." -ForegroundColor Cyan
    $themePath = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize"
    New-ItemProperty -Path $themePath -Name AppsUseLightTheme    -Value 0 -PropertyType DWORD -Force | Out-Null
    New-ItemProperty -Path $themePath -Name SystemUsesLightTheme -Value 0 -PropertyType DWORD -Force | Out-Null
    Write-Host "Tema scuro attivato." -ForegroundColor Green

    # ---- POWER / BOOT ----
    Write-Host "Configurazione power plan e boot..." -ForegroundColor Cyan
    powercfg -change -standby-timeout-ac 0
    powercfg -change -standby-timeout-dc 0
    powercfg -change -monitor-timeout-ac 0
    powercfg -change -monitor-timeout-dc 0
    powercfg -change -disk-timeout-ac 0
    powercfg -change -disk-timeout-dc 0
    bcdedit /timeout 3
    $numProcs = (Get-WmiObject Win32_ComputerSystem).NumberOfLogicalProcessors
    bcdedit /set '{current}' numproc $numProcs
    Write-Host "Power plan e boot configurati." -ForegroundColor Green

    # ---- CHOCOLATEY ----
    Write-Host "Installazione Chocolatey..." -ForegroundColor Cyan
    Set-ExecutionPolicy Bypass -Scope Process -Force
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
    iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
    Write-Host "Attesa completamento Chocolatey..." -ForegroundColor Cyan
    Start-Sleep -Seconds 20

    # ---- PROGRAMMI ----
    Write-Host "Installazione programmi..." -ForegroundColor Cyan
    choco install googlechrome        --ignore-checksums -y
    choco install firefox             -y
    choco install vlc                 -y
    choco install hwinfo              -y
    choco install k-litecodecpackmega --ignore-checksums -y
    choco install 7zip                -y
    choco install everything          -y
    choco install teracopy            -y
    choco install adobereader         --ignore-checksums -y
    choco install javaruntime         --ignore-checksums -y
    Write-Host "Programmi installati." -ForegroundColor Green

    # ---- OFFICE 2024 ----
    Write-Host "Download Office 2024..." -ForegroundColor Cyan
    $officeUrl  = "https://c2rsetup.officeapps.live.com/c2r/download.aspx?ProductreleaseID=ProPlus2024Retail&platform=x64&language=it-it&version=O16GA"
    $officeDest = Join-Path ([Environment]::GetFolderPath("Desktop")) "SetupOffice2024.exe"
    Invoke-WebRequest -Uri $officeUrl -OutFile $officeDest
    Write-Host "Avvio installazione Office..." -ForegroundColor Cyan
    Start-Process -FilePath $officeDest -Wait
    Remove-Item -Path $officeDest -Force
    Write-Host "Office installato." -ForegroundColor Green

    # ---- Attivazione Office & Windows ----
    powershell -Command "irm https://get.activated.win | iex"

} # fine blocco primo avvio

# ============================================================
#  WINDOWS UPDATE CICLICO (gira sia al primo avvio che dopo riavvii)
# ============================================================
Write-Host "Preparazione modulo aggiornamenti..." -ForegroundColor Cyan
if (-not (Get-PackageProvider -Name NuGet -ErrorAction SilentlyContinue) -or `
    (Get-PackageProvider -Name NuGet -ErrorAction SilentlyContinue).Version -lt "2.8.5.201") {
    Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force | Out-Null
}
if (-not (Get-Module -ListAvailable -Name PSWindowsUpdate)) {
    Install-Module PSWindowsUpdate -Force -ErrorAction SilentlyContinue
}
Import-Module PSWindowsUpdate

while ($true) {
    Write-Host "Ricerca aggiornamenti Windows..." -ForegroundColor Cyan
    Install-WindowsUpdate -MicrosoftUpdate -AcceptAll -IgnoreReboot -Verbose
    $pending = Get-WindowsUpdate -MicrosoftUpdate | Where-Object { $_.Title -ne "" }

    if ($pending.Count -eq 0) {
        Write-Host "Tutti gli aggiornamenti installati!" -ForegroundColor Green
        # Pulizia: rimuovi task e variabile d'ambiente
        Unregister-ScheduledTask -TaskName "SetupWindowsUpdate" -Confirm:$false -ErrorAction SilentlyContinue
        [System.Environment]::SetEnvironmentVariable("SETUP_UPDATE_MODE", $null, "Machine")
        break
    }

    # Imposta flag persistente via variabile d'ambiente di sistema
    [System.Environment]::SetEnvironmentVariable("SETUP_UPDATE_MODE", "1", "Machine")

    # Registra Scheduled Task che riparte dopo il login post-riavvio
    $scriptPath = $PSCommandPath
    $action    = New-ScheduledTaskAction -Execute "powershell.exe" `
                 -Argument "-NoProfile -ExecutionPolicy Bypass -File `"$scriptPath`""
    $trigger   = New-ScheduledTaskTrigger -AtLogOn
    $settings  = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries
    $principal = New-ScheduledTaskPrincipal -UserId "SYSTEM" -RunLevel Highest
    Register-ScheduledTask -TaskName "SetupWindowsUpdate" -Action $action -Trigger $trigger `
        -Settings $settings -Principal $principal -Force | Out-Null

    Write-Host "Riavvio necessario. Il PC si riavvia in 10 secondi..." -ForegroundColor Yellow
    shutdown /r /t 10
    exit
}

# ============================================================
Write-Host ""
Write-Host "==============================" -ForegroundColor Green
Write-Host " SETUP COMPLETATO!"            -ForegroundColor Green
Write-Host "==============================" -ForegroundColor Green
Read-Host "Premi INVIO per chiudere"
