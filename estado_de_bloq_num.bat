@echo off
set NLS_LANG=AMERICAN_AMERICA.UTF8
chcp 65001 > nul

for /f "tokens=4 delims=: " %%g in ('klocks.exe') do set BloqMay=%%g

if %BloqMay% equ 1 goto activo
echo "Bloq Mayúsculas APAGADO"
GOTO fin

:activo
echo "Bloq Mayúsculas ENCENDIDO"

:FIN
