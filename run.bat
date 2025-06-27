@echo off
chcp 65001
setlocal

REM Check if Deno is installed
where deno >nul 2>&1
if %errorlevel% neq 0 (
    echo Deno is not installed or not in PATH. Please visit https://deno.land/ to install Deno.
    pause
    exit /b 1
)

REM Start Deno Server
echo Starting Edge auto-close server...
start "" /D "stop-edge-src" deno run --allow-read --allow-run --allow-net edge-stop-server.js &
timeout /t 2 /nobreak >nul
start "" http://localhost:19100/

endlocal