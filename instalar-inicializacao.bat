@echo off
setlocal

powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0instalar-inicializacao.ps1"
if errorlevel 1 (
    echo.
    echo Nao foi possivel instalar a atualizacao automatica.
    pause
    exit /b 1
)

echo.
echo A atualizacao automatica foi instalada com sucesso.
pause
