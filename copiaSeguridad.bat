@echo off
chcp 65001 > nul
SET NLS_LANG=AMERICAN_AMERICA.UTF8 
setlocal ENABLEEXTENSIONS
setlocal ENABLEDELAYEDEXPANSION 

set ahora=%date:~6,4%%date:~3,2%%date:~0,2%%time:~0,2%%time:~3,2%%time:~6,2%
set ahora=%ahora: =0%
rem aquí se hace la compresión
set RUTACOPIA=.\
set FICHCOPIA=copiaSeguridad%ahora%.7z
set outlook=NO
rem empaquetador. Este guión usa 7z.exe
set COMPRESOR=c:\Program Files\7-Zip\7z.exe

echo [*] compresor: %COMPRESOR%


:inicio

echo.
echo [ ] Leyendo  "copiaSeguridad.dat"
ECHO [ ] Creando una copia: %RUTACOPIA%%FICHCOPIA%
echo.


REM tasklist | find "OUTLOOK.EXE" > nul
REM if %errorlevel% == 0  ( 
REM 	ECHO [D] OUTLOOK encontrado, matando proceso
REM 	set outlook=SI
REM 	taskkill /F /IM OUTLOOK.EXE > NUL
REM 	WAITFOR /T 1 CASTICOPIASEGURIDAD 2> NUL 
REM )

for /F "tokens=* EOL=#" %%X in (copiaSeguridad.dat) do (
	echo [-] Procesando: %%X
	set elto=%%X
    echo [=] Elto: !elto!
    echo [ ] "%COMPRESOR%" a -r -bso0 -bsp0 "%RUTACOPIA%%FICHCOPIA%" !elto!
    "%COMPRESOR%" a -r -bso0 -bsp0 "%RUTACOPIA%%FICHCOPIA%" !elto!
REM 	if exist !elto! (
rem 	set ATRIB=%%~aX
rem		ECHO atrib !ATRIB!
rem		SET TIPO=!ATRIB:~0,1!
rem		IF NOT !TIPO!==d SET TIPO=!ATRIB:~2,1!
rem 		ECHO TIPO: !TIPO!
REM	)
)

REM ECHO [D] Duplicando la copia
REM xcopy /Q /R %DIR1%\* %DIR2%\*
REM 
REM if %outlook% == SI (
REM "c:\Users\fdello3\AppData\Roaming\Microsoft\Internet Explorer\Quick Launch\User Pinned\TaskBar\Outlook 2016.lnk" 
REM )

:salir
echo [ ] Terminado.
echo.

:fin