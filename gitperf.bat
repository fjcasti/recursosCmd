@echo off
setlocal enabledelayedexpansion

for /f "usebackq delims=" %%f in (`dir /b "%USERPROFILE%\.gitconfig.*" 2^>nul`) do (
    set "_ext=%%~xf"
    if "!_ext!" neq "" if /i "!_ext:~1!" neq "gitconfig" echo !_ext:~1!
)

endlocal
