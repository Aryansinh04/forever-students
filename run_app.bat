@echo off
SETLOCAL EnableDelayedExpansion

:: Set window title
title Working With Forever - One-Click Launcher

echo ============================================================
echo      WORKING WITH FOREVER - APPLICATION LAUNCHER
echo ============================================================
echo.

:: 1. Check if Node.js is installed
node -v >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo [ERROR] Node.js is not installed or not in PATH.
    echo Please install Node.js from https://nodejs.org/
    pause
    exit /b 1
)

:: 2. Check for node_modules
if not exist "node_modules\" (
    echo [INFO] node_modules folder is missing. Installing dependencies...
    call npm install
    if !ERRORLEVEL! neq 0 (
        echo [ERROR] Failed to install dependencies.
        pause
        exit /b 1
    )
)

:: 3. Check for .env file
if not exist ".env" (
    if exist ".env.example" (
        echo [INFO] .env file not found. Creating a copy from .env.example...
        copy .env.example .env
    ) else (
        echo [WARNING] .env file not found and .env.example is missing.
        echo Creating a basic .env file...
        (
            echo PORT=4000
            echo JWT_SECRET=change-me-in-production
            echo JWT_EXPIRES_IN=1d
            echo NODE_ENV=development
            echo STORE_DRIVER=file
        ) > .env
    )
)

:: 4. Start the application
echo [INFO] Launching the system...
echo.
echo [TIP] The application will be accessible at http://localhost:4000
echo [TIP] Press Ctrl+C in this window to stop the server.
echo.

:: Briefly wait for server to start before opening browser
start http://localhost:4000/index

:: Run the dev script (uses nodemon)
call npm run dev

:: If the above command exits (usually due to error)
if %ERRORLEVEL% neq 0 (
    echo.
    echo [ERROR] The application stopped unexpectedly with error code %ERRORLEVEL%.
    pause
)

ENDLOCAL
