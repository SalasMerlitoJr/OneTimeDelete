@echo off
color 0A
title System32 Deletion
setlocal enabledelayedexpansion

:: =========================
:: ADMIN CHECK
:: =========================
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo Mamalihog kog Run as Administrator.
    pause
    exit
)
:: =========================
:: LOG FOLDER SETUP
:: =========================
set "logdir=%~dp0Logs"
if not exist "%logdir%" mkdir "%logdir%"

set "log=%logdir%\cleaner_log.txt"

echo ============================== >> "%log%"
echo Run: %date% %time% >> "%log%"

:: =========================
:: MENU
:: =========================
:menu
cls
echo ==============================
echo    SYSTEM CLEANER
echo ==============================
echo.
echo [1] Fast
echo [2] Deep
echo [3] Exit
echo.
set /p choice=Select option: 

if "%choice%"=="1" set mode=fast
if "%choice%"=="2" set mode=deep
if "%choice%"=="3" exit
if not defined mode goto menu

:: =========================
:: LOG FILE
:: =========================
set log=cleaner_log.txt
echo ============================== >> %log%
echo Run: %date% %time% >> %log%

:: =========================
:: START DELETING
:: =========================
set step=0

call :progress "Deleting SecurityHealth" 5

:: TEMP CLEAN
call :progress "Deleting PerceptionSimulation" 20
del /q /f /s %temp%\* >nul 2>&1
rd /s /q %temp% >nul 2>&1
mkdir %temp% >nul 2>&1
echo TEMP cleaned >> %log%

:: WINDOWS TEMP
call :progress "Deleting Code Integrity" 40
del /q /f /s C:\Windows\Temp\* >nul 2>&1
rd /s /q C:\Windows\Temp >nul 2>&1
mkdir C:\Windows\Temp >nul 2>&1
echo Windows Temp cleaned >> %log%

:: RECENT FILES
call :progress "Deleting GroupPolicy" 60
del /q /f /s %appdata%\Microsoft\Windows\Recent\* >nul 2>&1
echo Recent Files cleaned >> %log%

:: PREFETCH (Deep only)
if "%mode%"=="deep" (
    call :progress "Deleting Boot" 80
    del /q /f /s C:\Windows\Prefetch\* >nul 2>&1
    echo Prefetch cleaned >> %log%
)

:: RECYCLE BIN
call :progress "Deleting HealthAttestationClient" 95
powershell -command "Clear-RecycleBin -Force" >nul 2>&1
echo Recycle Bin cleaned >> %log%

call :progress "Finalizing" 100

:: =========================
:: DONE
:: =========================
cls
echo ==============================
echo CLEANING COMPLETED
echo Mode: %mode%
echo Log saved: %log%
echo ==============================
pause
goto menu

:: =========================
:: PROGRESS BAR FUNCTION
:: =========================
:progress
set msg=%~1
set percent=%~2

set /a filled=%percent%/2
set bar=

for /l %%a in (1,1,!filled!) do set bar=!bar!#
for /l %%b in (!filled!,1,50) do set bar=!bar!-

cls
echo ==============================
echo %msg%
echo ==============================
echo.
echo Progress: [!bar!] %percent%%%

:: speed control (same logic you wanted)
if %percent% LEQ 30 (
    ping 127.0.0.1 -n 2 >nul
) else if %percent% LEQ 60 (
    timeout /t 1 >nul
) else if %percent% LEQ 90 (
    ping 127.0.0.1 -n 1 >nul
) else (
    timeout /t 1 >nul
)

exit /b