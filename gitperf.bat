@echo off
setlocal enabledelayedexpansion

set "_n=0"
for /f "usebackq delims=" %%f in (`dir /b "%USERPROFILE%\.gitconfig.*" 2^>nul`) do (
    set "_ext=%%~xf"
    if "!_ext!" neq "" if /i "!_ext:~1!" neq "gitconfig" (
        set /a "_n+=1"
        set "_profile_!_n!=!_ext:~1!"
    )
)

if "%~1"=="" goto :list
set "_sel=0"
set /a "_sel=%~1" 2>nul
if !_sel! LSS 1 goto :list
if !_sel! GTR !_n! goto :list

call set "_chosen=%%_profile_!_sel!%%"
copy /Y "%USERPROFILE%\.gitconfig.!_chosen!" "%USERPROFILE%\.gitconfig"
goto :end

:list
for /l %%i in (1,1,!_n!) do (
    set "_mark= "
    fc /b "%USERPROFILE%\.gitconfig" "%USERPROFILE%\.gitconfig.!_profile_%%i!" >nul 2>nul
    if !errorlevel! EQU 0 set "_mark=*"
    echo %%i [!_mark!] !_profile_%%i!
)

:end
endlocal
