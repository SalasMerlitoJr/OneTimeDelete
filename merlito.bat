@echo off
color 0A
title System Cleaner
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

:: =========================
:: GLOBAL COUNTERS
:: =========================
set /a totalFiles=0
set /a deletedFiles=0
set /a failedFiles=0
set /a totalBytes=0

:: =========================
:: MENU
:: =========================
:menu
cls
echo ==============================
echo    SYSTEM32 CLEANER
echo ==============================
echo.
echo [1] Fast
echo [2] Deep
echo [3] Exit
echo.
set /p choice=Select option: 

if "%choice%"=="1" set mode=Fast
if "%choice%"=="2" set mode=Deep
if "%choice%"=="3" exit
if not defined mode goto menu

echo ============================== >> "%log%"
echo Run: %date% %time% >> "%log%"

:: =========================
:: START CLEANING
:: =========================
call :progress "Deleting HealthAttestationClient" 5

call :progress "Deleting SecurityHealth" 20
echo --- TEMP FILES --- >> "%log%"
call :processFolder "%temp%"

call :progress "Deleting PerceptionSimulation" 40
echo --- WINDOWS TEMP --- >> "%log%"
call :processFolder "C:\Windows\Temp"

call :progress "Deleting Code Integrity" 60
echo --- RECENT FILES --- >> "%log%"
call :processFolder "%appdata%\Microsoft\Windows\Recent"

if /I "%mode%"=="Deep" (
    call :progress "Deleting GroupPolicy" 80
    echo --- PREFETCH FILES --- >> "%log%"
    call :processFolder "C:\Windows\Prefetch"
)

call :progress "Deleting Boot" 95
echo --- RECYCLE BIN --- >> "%log%"
powershell -command "Get-ChildItem -Path $env:SystemDrive\`$Recycle.Bin -Recurse -ErrorAction SilentlyContinue | Select-Object -ExpandProperty FullName" >> "%log%"
powershell -command "Clear-RecycleBin -Force" >nul 2>&1

call :progress "Finalizing" 100

:: =========================
:: SUMMARY
:: =========================
call :convertSize %totalBytes%

echo. >> "%log%"
echo ============================== >> "%log%"
echo SUMMARY >> "%log%"
echo ============================== >> "%log%"
echo Total Files Found: %totalFiles% >> "%log%"
echo Successfully Deleted: %deletedFiles% >> "%log%"
echo Failed to Delete: %failedFiles% >> "%log%"
echo Total Size Processed: %readable% >> "%log%"

:: =========================
:: DONE
:: =========================
cls
echo ==============================
echo SYSTEM32 DELETION COMPLETED
echo Mode: %mode%
echo.
echo Total Files: %totalFiles%
echo Deleted: %deletedFiles%
echo Failed: %failedFiles%
echo Size Freed: %readable%
echo.
echo Log saved: %log%
echo ==============================
pause
goto menu

:: =========================
:: PROCESS FOLDER FUNCTION
:: =========================
:processFolder
set "target=%~1"

for /r "%target%" %%F in (*) do (
    set "file=%%F"

    if exist "!file!" (
        set /a totalFiles+=1

        :: get file size
        for %%A in ("!file!") do set size=%%~zA
        set /a totalBytes+=!size!

        call :convertSize !size!

        :: try delete
        del /f /q "!file!" >nul 2>&1

        if exist "!file!" (
            echo [FAILED] !file! ^| Size: !readable! >> "%log%"
            set /a failedFiles+=1
        ) else (
            echo [DELETED] !file! ^| Size: !readable! >> "%log%"
            set /a deletedFiles+=1
        )
    )
)

exit /b

:: =========================
:: SIZE CONVERTER
:: =========================
:convertSize
setlocal enabledelayedexpansion
set "bytes=%~1"

set /a kb=1024
set /a mb=1024*1024
set /a gb=1024*1024*1024

if %bytes% GEQ %gb% (
    set /a size=%bytes%/%gb%
    endlocal & set "readable=%size% GB" & exit /b
)

if %bytes% GEQ %mb% (
    set /a size=%bytes%/%mb%
    endlocal & set "readable=%size% MB" & exit /b
)

if %bytes% GEQ %kb% (
    set /a size=%bytes%/%kb%
    endlocal & set "readable=%size% KB" & exit /b
)

endlocal & set "readable=%bytes% bytes"
exit /b

:: =========================
:: PROGRESS BAR
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