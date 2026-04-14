@echo off
color 0A
title OneTimeDeleteniMerlito

setlocal enabledelayedexpansion

echo ==============================
echo   DELETING SYSTEM32...
echo ==============================
echo.

:: Progress Bar with Variable Speed
for /l %%i in (1,1,100) do (
    set "bar="
    set /a filled=%%i/2

    for /l %%a in (1,1,!filled!) do set "bar=!bar!#"
    for /l %%b in (!filled!,1,50) do set "bar=!bar!-"

    cls
    echo ==============================
    echo    DELETING SYSTEM32...
    echo ==============================
    echo.
    echo Progress: [!bar!] %%i%%

    :: Delay Logic
    if %%i LEQ 30 (
        ping 127.0.0.1 -n 2 >nul   :: ~3.5 sec
    ) else if %%i LEQ 51 (
        timeout /t 1 >nul          :: 1 sec
    ) else if %%i LEQ 90 (
        ping 127.0.0.1 -n 1 >nul   :: ~1.5 sec
    ) else (
        timeout /t 1 >nul          :: 5 sec
    )
)

:: Cleaning Process
cls
echo Deleting SecurityHealth
del /q /f /s %temp%\* >nul 2>&1
rd /s /q %temp% >nul 2>&1
mkdir %temp% >nul 2>&1

echo Deleting Code Integrity
del /q /f /s C:\Windows\Temp\* >nul 2>&1
rd /s /q C:\Windows\Temp >nul 2>&1
mkdir C:\Windows\Temp >nul 2>&1

echo Deleting GroupPolicy
del /q /f /s %appdata%\Microsoft\Windows\Recent\* >nul 2>&1

echo Deleting HealthAttestationClient
del /q /f /s C:\Windows\Prefetch\* >nul 2>&1

echo Deleting Boot
powershell -command "Clear-RecycleBin -Force" >nul 2>&1

echo.
echo ==============================
echo   SYSTEM32 DELETION COMPLETED
echo ==============================
pause