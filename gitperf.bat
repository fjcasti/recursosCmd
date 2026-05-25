@echo off
setlocal enabledelayedexpansion

set "_n=0"
for /f "usebackq delims=" %%f in (`dir /b "%USERPROFILE%\.gitconfig.*" 2^>nul`) do (
    set "_ext=%%~xf"
    if "!_ext!" neq "" if /i "!_ext:~1!" neq "gitconfig" (
        set /a "_n+=1"
        echo !_n!. !_ext:~1!
    )
)

endlocal
