@echo off
:: ============================================================
::  SETUP AUTOMATICO - launcher
::  Metti setup.cmd e setup.ps1 nella stessa cartella
:: ============================================================

net session >nul 2>&1
if %errorlevel% neq 0 (
    powershell -Command "Start-Process cmd -ArgumentList '/c \"%~f0\"' -Verb RunAs"
    exit /b
)

:: Applica chiavi registro
echo [1/10] Aggiunta CopyTo nel menu contestuale...
reg add "HKCR\AllFilesystemObjects\shellex\ContextMenuHandlers\CopyTo" /ve /d "{C2FBB630-2971-11D1-A18C-00C04FD75D13}" /f

echo [2/10] Aggiunta MoveTo nel menu contestuale...
reg add "HKCR\AllFilesystemObjects\shellex\ContextMenuHandlers\MoveTo" /ve /d "{C2FBB631-2971-11D1-A18C-00C04FD75D13}" /f

echo [3/10] Impostazione RegisteredOwner...
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion" /v RegisteredOwner /t REG_SZ /d "" /f

echo [4/10] Impostazione RegisteredOrganization (PC Evolution)...
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion" /v RegisteredOrganization /t REG_SZ /d "Follow Me on tiktok @momo1098r" /f

echo [5/10] Ripristino visibilita Security Health nella systray...
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender Security Center\Systray" /v HideSystray /t REG_DWORD /d 0 /f

echo [6/10] Abilitazione avvio automatico Security Health...
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\StartupApproved\Run" /v SecurityHealth /t REG_BINARY /d 060000000000000000000000 /f

echo [7/10] Impostazione percorso SecurityHealthSystray...
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" /v SecurityHealth /t REG_EXPAND_SZ /d "%%windir%%\system32\SecurityHealthSystray.exe" /f

echo [8/10] Disabilitazione Cortana nella ricerca...
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Search" /v CortanaConsent /t REG_DWORD /d 0 /f

echo [9/10] Disabilitazione Bing nella ricerca...
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Search" /v BingSearchEnabled /t REG_DWORD /d 0 /f

echo [10/10] Abilitazione estensioni file...
powershell -Command "$sid = (New-Object System.Security.Principal.NTAccount($env:USERNAME)).Translate([System.Security.Principal.SecurityIdentifier]).Value; reg add ('HKU\' + $sid + '\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced') /v HideFileExt /t REG_DWORD /d 0 /f; Stop-Process -Name explorer -Force -ErrorAction SilentlyContinue; Start-Sleep -Seconds 1; Start-Process explorer"

echo.
echo Registro completato. Avvio setup.ps1...
echo.
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0setup.ps1"
