@echo off
setlocal enabledelayedexpansion

:: Configuration
set "SCRIPT_NAME=gptBLEND"
set "VERSION=2.0"
set "API_MODEL=gpt-4"  :: Updated to current model
set "LOG_FILE=gptblend.log"
set "OUTPUT_SCRIPT=blend_generated.py"

:: Color codes for Windows 10+
if not defined IN_COLOR_INIT (
    for /F "tokens=1,2 delims=#" %%a in ('"prompt #$H#$E# & echo on & for %%b in (1) do rem"') do (
        set "COLOR_RESET=%%a"
        set "COLOR_GREEN=%%a%%b"
        set "COLOR_YELLOW=%%a%%b"
        set "COLOR_RED=%%a%%b"
        set "COLOR_CYAN=%%a%%b"
    )
    set "IN_COLOR_INIT=1"
)

:: Banner
echo.
echo ========================================
echo    gptBLEND v%VERSION% - AI Blender Assistant
echo ========================================
echo.

:: Check for admin rights
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo [WARNING] Some features may require administrator privileges.
    echo.
)

:: Check for dependencies
set "dependencies=curl jq blender"
set "missing_deps="

echo Checking dependencies...
for %%d in (%dependencies%) do (
    where /q %%d >nul 2>&1
    if errorlevel 1 (
        echo [ERROR] Missing: %%d
        set "missing_deps=!missing_deps! %%d"
    ) else (
        echo [OK] Found: %%d
    )
)

if not "!missing_deps!"=="" (
    echo.
    echo === MISSING DEPENDENCIES ===
    echo The following tools are required:!missing_deps!
    echo.
    
    if "!missing_deps:curl=!" neq "!missing_deps!" (
        echo To install curl:
        echo 1. Download from: https://curl.se/windows/
        echo 2. Add to PATH environment variable
        echo.
    )
    
    if "!missing_deps:jq=!" neq "!missing_deps!" (
        echo To install jq:
        echo 1. Download from: https://stedolan.github.io/jq/download/
        echo 2. Or use winget: winget install jqlang.jq
        echo.
    )
    
    if "!missing_deps:blender=!" neq "!missing_deps!" (
        echo To install Blender:
        echo 1. Download from: https://www.blender.org/download/
        echo 2. Add to PATH or specify full path
        echo.
    )
    
    set /p "install_choice=Would you like to try automatic installation? (y/n): "
    
    if /i "!install_choice!"=="y" (
        echo.
        echo Attempting to install missing dependencies...
        
        :: Try winget (Windows 10+)
        where winget >nul 2>&1
        if not errorlevel 1 (
            echo Using winget package manager...
            for %%d in (!missing_deps!) do (
                if "%%d"=="jq" (
                    winget install jqlang.jq -s winget --accept-package-agreements
                ) else if "%%d"=="curl" (
                    winget install curl.curl -s winget --accept-package-agreements
                ) else if "%%d"=="blender" (
                    winget install BlenderFoundation.Blender -s winget --accept-package-agreements
                )
            )
        ) else (
            :: Try chocolatey
            where choco >nul 2>&1
            if not errorlevel 1 (
                echo Using Chocolatey package manager...
                for %%d in (!missing_deps!) do (
                    choco install %%d -y
                )
            ) else (
                echo.
                echo No package manager found. Please install manually.
                echo.
                pause
                exit /b 1
            )
        )
        
        :: Verify installation
        echo.
        echo Verifying installation...
        set "still_missing="
        for %%d in (!missing_deps!) do (
            where /q %%d >nul 2>&1
            if errorlevel 1 (
                echo [WARNING] %%d still not found after installation
                set "still_missing=!still_missing! %%d"
            )
        )
        
        if not "!still_missing!"=="" (
            echo Please install these manually and restart the script.
            pause
            exit /b 1
        )
    ) else (
        echo Please install the missing dependencies and restart the script.
        pause
        exit /b 1
    )
)

echo.
echo All dependencies satisfied!
echo.

:: API Key Handling
:api_key_check
set "OPENAI_API_KEY="
if not defined OPENAI_API_KEY (
    :: Check environment variable
    if not "%OPENAI_API_KEY%"=="" (
        set "OPENAI_API_KEY=%OPENAI_API_KEY%"
    ) else (
        :: Check for config file
        if exist "api_config.txt" (
            for /f "tokens=*" %%a in (api_config.txt) do (
                if "!OPENAI_API_KEY!"=="" (
                    set "OPENAI_API_KEY=%%a"
                )
            )
        )
    )
)

if "%OPENAI_API_KEY%"=="" (
    echo === API KEY REQUIRED ===
    echo To use gptBLEND, you need an OpenAI API key.
    echo.
    echo Options:
    echo 1. Enter your API key now (will be saved locally in api_config.txt)
    echo 2. Set environment variable: set OPENAI_API_KEY=your_key_here
    echo 3. Create api_config.txt with your key in the same directory
    echo.
    set /p "OPENAI_API_KEY=Enter your OpenAI API key (or press Enter to skip): "
    
    if not "%OPENAI_API_KEY%"=="" (
        echo %OPENAI_API_KEY% > api_config.txt
        echo [INFO] API key saved to api_config.txt
    ) else (
        echo API key is required to continue.
        pause
        exit /b 1
    )
)

:: Validate API key format (starts with sk-)
if not "%OPENAI_API_KEY:sk-=%"=="%OPENAI_API_KEY%" (
    echo [OK] API key format appears valid
) else (
    echo [WARNING] API key doesn't match expected format (should start with 'sk-')
    set /p "continue_anyway=Continue anyway? (y/n): "
    if /i not "!continue_anyway!"=="y" (
        goto :api_key_check
    )
)

echo.

:: Main menu
:main_menu
cls
echo ========================================
echo    gptBLEND v%VERSION% - Main Menu
echo ========================================
echo.
echo 1. Generate new Blender script
echo 2. Edit/Review existing script
echo 3. Run existing script in Blender
echo 4. View log file
echo 5. Settings
echo 6. Exit
echo.

set /p "menu_choice=Select option (1-6): "

if "%menu_choice%"=="1" goto :generate
if "%menu_choice%"=="2" goto :edit
if "%menu_choice%"=="3" goto :run_existing
if "%menu_choice%"=="4" goto :view_log
if "%menu_choice%"=="5" goto :settings
if "%menu_choice%"=="6" exit /b 0

echo Invalid choice. Press any key to continue...
pause >nul
goto :main_menu

:generate
cls
echo ========================================
echo    Generate New Blender Script
echo ========================================
echo.
echo Provide a detailed description of what you want to create.
echo Be specific about shapes, colors, lighting, and animation.
echo.
echo Examples:
echo - "Create a red cube that rotates slowly"
echo - "Generate a landscape with mountains and trees"
echo - "Make a bouncing ball with physics"
echo.

set /p "user_prompt=Describe your 3D scene: "

if "%user_prompt%"=="" (
    echo Prompt cannot be empty.
    timeout /t 2 >nul
    goto :generate
)

echo.
echo Generating code with AI... Please wait.

:: Create a more specific system prompt
set "system_prompt=You are a Blender Python expert. Generate ONLY Python code for Blender 3.0+. Do not include explanations, markdown formatting, or comments outside of the code. The code should be complete and runnable. Use modern Blender Python API. Import necessary modules. Focus on: "

:: Prepare the API request
set "temp_file=%temp%\gptblend_request.json"
set "response_file=%temp%\gptblend_response.json"

(
echo {
echo   "model": "%API_MODEL%",
echo   "messages": [
echo     {"role": "system", "content": "%system_prompt%"},
echo     {"role": "user", "content": "%user_prompt%"}
echo   ],
echo   "temperature": 0.7,
echo   "max_tokens": 2000
echo }
) > "%temp_file%"

:: Call OpenAI API
curl -s -X POST "https://api.openai.com/v1/chat/completions" ^
  -H "Content-Type: application/json" ^
  -H "Authorization: Bearer %OPENAI_API_KEY%" ^
  -d "@%temp_file%" > "%response_file%"

if errorlevel 1 (
    echo [ERROR] Failed to connect to OpenAI API
    echo Check your internet connection and API key.
    pause
    goto :main_menu
)

:: Extract the code
set "generated_code="
for /f "tokens=*" %%i in ('jq -r ".choices[0].message.content" "%response_file%"') do set "generated_code=%%i"

if "%generated_code%"=="" (
    echo [ERROR] No code generated. API response: 
    type "%response_file%"
    echo.
    pause
    goto :main_menu
)

:: Clean up the code (remove markdown code blocks)
echo %generated_code% | findstr /v "^```" | findstr /v "^python" > "%OUTPUT_SCRIPT%.temp"

:: Add safety wrapper and error handling
(
echo import bpy
echo import sys
echo import traceback
echo.
echo def main():
echo     try:
type "%OUTPUT_SCRIPT%.temp" | findstr /n "^"
echo     except Exception as e:
echo         print("Error executing generated code:")
echo         print(str(e))
echo         traceback.print_exc()
echo         return False
echo     return True
echo.
echo if __name__ == "__main__":
echo     success = main()
echo     if not success:
echo         print("Script execution failed.")
echo     else:
echo         print("Script executed successfully!")
) > "%OUTPUT_SCRIPT%"

del "%OUTPUT_SCRIPT%.temp" 2>nul

echo.
echo [SUCCESS] Code generated and saved to %OUTPUT_SCRIPT%
echo.

:: Preview the generated code
set /p "preview=Preview generated code? (y/n): "
if /i "%preview%"=="y" (
    echo.
    echo ===== GENERATED CODE =====
    type "%OUTPUT_SCRIPT%" | more
    echo ==========================
    echo.
)

set /p "run_now=Run script in Blender now? (y/n): "
if /i "%run_now%"=="y" (
    goto :run_script
)

echo Script saved. You can run it from the main menu.
pause
goto :main_menu

:run_script
echo.
echo Running script in Blender...
echo ============================

:: Check if Blender is available
where blender >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Blender not found in PATH.
    set /p "blender_path=Enter full path to blender.exe: "
    if exist "!blender_path!" (
        set "blender_cmd=!blender_path!"
    ) else (
        echo Blender not found at specified path.
        pause
        goto :main_menu
    )
) else (
    set "blender_cmd=blender"
)

:: Run with logging
echo Starting Blender at %time% >> "%LOG_FILE%"
echo Executing: %OUTPUT_SCRIPT% >> "%LOG_FILE%"
echo. >> "%LOG_FILE%"

%blender_cmd% --background --python "%OUTPUT_SCRIPT%" 2>&1 | tee -a "%LOG_FILE%"

echo.
echo ============================
echo Blender execution completed.
echo Check %LOG_FILE% for details.
pause
goto :main_menu

:edit
if not exist "%OUTPUT_SCRIPT%" (
    echo No generated script found. Generate one first.
    pause
    goto :main_menu
)

echo Opening %OUTPUT_SCRIPT% for editing...
notepad "%OUTPUT_SCRIPT%"
goto :main_menu

:run_existing
set /p "script_path=Enter path to Python script (or press Enter for %OUTPUT_SCRIPT%): "
if "%script_path%"=="" set "script_path=%OUTPUT_SCRIPT%"

if not exist "%script_path%" (
    echo Script not found: %script_path%
    pause
    goto :main_menu
)

echo Running %script_path%...
blender --background --python "%script_path%"
pause
goto :main_menu

:view_log
if exist "%LOG_FILE%" (
    echo ===== LOG FILE CONTENTS =====
    type "%LOG_FILE%"
    echo =============================
) else (
    echo No log file found.
)
pause
goto :main_menu

:settings
cls
echo ========================================
echo    Settings
echo ========================================
echo.
echo Current settings:
echo - API Model: %API_MODEL%
echo - Output script: %OUTPUT_SCRIPT%
echo.
echo 1. Change API model
echo 2. Change output filename
echo 3. Clear API key
echo 4. Back to main menu
echo.

set /p "setting_choice=Select option: "

if "%setting_choice%"=="1" (
    set /p "new_model=Enter new model (gpt-4, gpt-3.5-turbo, etc.): "
    if not "!new_model!"=="" set "API_MODEL=!new_model!"
)
if "%setting_choice%"=="2" (
    set /p "new_output=Enter new output filename: "
    if not "!new_output!"=="" set "OUTPUT_SCRIPT=!new_output!"
)
if "%setting_choice%"=="3" (
    if exist "api_config.txt" (
        del "api_config.txt"
        echo API key cleared.
    )
    set "OPENAI_API_KEY="
    pause
)
goto :main_menu
