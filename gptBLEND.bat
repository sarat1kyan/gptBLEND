@echo off

:: Check for dependencies
set "dependencies=curl,jq,blender"
set "missing_dependencies="

for %%d in (%dependencies%) do (
    where /q %%d || set "missing_dependencies=!missing_dependencies! %%d"
)

if not "%missing_dependencies%" == "" (
    echo Error: The following dependencies are missing: %missing_dependencies%
    set /p install_deps=Would you like to install them now? (y/n)

    if /i "%install_deps%" == "y" (
        :: Detect package manager
        if exist "%ProgramFiles%\Git\usr\bin\apt.exe" (
            "%ProgramFiles%\Git\usr\bin\apt.exe" install %missing_dependencies%
        ) elif exist "%ProgramFiles(x86)%\Microsoft SDKs\Windows\v7.1A\Bin\SetEnv.cmd" (
            call "%ProgramFiles(x86)%\Microsoft SDKs\Windows\v7.1A\Bin\SetEnv.cmd" /Release /x86 /win7
            "%ProgramFiles(x86)%\Microsoft Visual Studio\2019\Community\VC\Auxiliary\Build\vcvars32.bat"
            "%ProgramFiles(x86)%\Microsoft Visual Studio\2019\Community\VC\Tools\MSVC\14.29.30133\bin\Hostx86\x86\vc_redist.x86.exe"
            powershell -Command "Install-Package %missing_dependencies%"
        ) else (
            echo Error: Could not detect package manager. Please install the missing dependencies manually.
            pause
            exit /b 1
        )
    ) else (
        echo Error: The missing dependencies must be installed to run this script. Please install them manually.
        pause
        exit /b 1
    )
)

:: Print usage instructions
echo This script generates Python code for Blender using the ChatGPT API.
echo To use this script, enter a prompt that describes the Python code you want to generate.
echo For best results, use natural language and be as specific as possible.
echo For example: "Generate Python code to create a 3D model of a car in Blender"

:: Prompt the user for input
set /p prompt=Enter a prompt:

:: Validate the input prompt
if "%prompt%" == "" (
    echo Error: Prompt cannot be empty. Please try again.
    pause
    exit /b 1
)

:: Send request to ChatGPT API
set "response="
for /f "delims=" %%r in ('curl -s -H "Authorization: Bearer YOUR_API_KEY" -d "{\"prompt\": \"%prompt%\"}" https://api.openai.com/v1/engines/davinci-codex/completions ^| jq -r ".choices[0].text"') do set "response=%%r"

:: Extract the generated Python code from the API response
set "code=%response%"

:: Validate the generated code
if "%code%" == "" (
    echo Error: Generated code is empty. Please try a different prompt.
    pause
    exit /b 1
)

:: Save the Python code to a file
echo %code% > script.py

:: Execute the Python code in Blender
blender --background --python script.py

pause

