@echo off
setlocal enabledelayedexpansion

for /f "usebackq delims=" %%f in (`dir /b "%USERPROFILE%\.gitconfig.*" 2^>nul`) do (
    set "_ext=%%~xf"
    if "!_ext!" neq "" echo !_ext:~1!
)

endlocal
