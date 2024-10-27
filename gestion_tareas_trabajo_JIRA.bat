@echo off 

REM para trabajar con la consola en UTF8
chcp 65001 > nul
SET NLS_LANG=AMERICAN_AMERICA.UTF8 

SETLOCAL ENABLEDELAYEDEXPANSION
rem configuracion de rutas
SET BASE=c:\users\fdello3\Desktop\trabajo\JIRAS
SET NPP=C:\Desarrollo\Apps\Notepad++\notepad++.exe
SET FF=C:\Users\fdello3\bin\FirefoxPortable\App\Firefox64\firefox.exe
if not EXIST %BASE% echo [E] No encuentro la carpeta de trabajo. Ajuste la configuracion & GOTO fin
if not EXIST %NPP%  echo [E] No encuentro Notepad ++. Ajuste la configuracion & GOTO fin
if not EXIST %FF%   echo [E] No encuentro Firefox. Ajuste la configuracion & GOTO fin

rem variables 
set URLJIRA=https://srvespolapl03.mdef.es/jira/browse
SET CERR=%BASE%\CERRADOS
SET ABRE=0
SET MUESTRA=0
SET CIERRA=0
SET MARCA=0
SET JIRA=-
SET TITULO=
SET DEBUG=0
SET CARPETA=
SET CERRADO=
SET LEEME=




REM tratamiento de los parámetros
if "%1" == "" goto ayuda 
SET DATO=XXX
FOR %%E IN (%*) DO (
	call :procesaParam %%E 
)

IF %DEBUG%==1 echo [D] titulo  %TITULO%
IF %DEBUG%==1 echo [D] abre    %ABRE%
IF %DEBUG%==1 echo [D] cierra  %CIERRA%
IF %DEBUG%==1 echo [D] muestra %MUESTRA%
IF %DEBUG%==1 echo [D] jira    %JIRA%
IF %DEBUG%==1 echo [D] marca   %MARCA%


IF %MUESTRA%==1 GOTO listarJiras
IF %CIERRA%==2 GOTO cierraTodo
SET /A SUMA=%ABRE%+%CIERRA%+%MARCA%
IF NOT %SUMA%==1 GOTO AYUDA
IF "%JIRA%"=="-" GOTO AYUDA
IF %ABRE%==1 GOTO abrirJira
IF %CIERRA%==1 GOTO cerrarJira
IF %MARCA%==1  GOTO marcarJira
goto ayuda



:abrirJira
	SET JIRA=%JIRA: =%
	SET CARPETA=%BASE%\%JIRA%
	SET CERRADO=%BASE%\cerrados\%JIRA%
	SET LEEME=%JIRA%.leeme

	IF %DEBUG%==1 echo [D] carpeta            "%CARPETA%"
	IF %DEBUG%==1 echo [D] cerrado            "%CERRADO%"
	IF %DEBUG%==1 echo [D] titulo             "%TITULO%"
	IF %DEBUG%==1 echo [D] Carpeta y titulo   "%CARPETA% %TITULO%"
	IF %DEBUG%==1 ECHO [D] jira               %JIRA%
	IF %DEBUG%==1 ECHO [D] leeme              %LEEME%
	
	
	IF EXIST %CARPETA%* ECHO [¡] %JIRA% YA EXISTE & GOTO abrirNPP
	if exist %CERRADO%* goto abrirCerrado
	echo [-] Creando entorno Jira %JIRA%
	
	mkdir "%CARPETA% %TITULO%"
 	SET rutaActual=%CD%
	cd "%CARPETA% %TITULO%"
	ECHO Notas JIRA: %JIRA%    > %LEEME%
	echo             %TITULO% >> %LEEME%
	start %NPP% %leeme%
	START %FF% --new-tab --url %URLJIRA%/DESA-%JIRA%
 	cd %rutaActual%
	goto fin
	
:abrirCerrado
	ECHO Abriendo entorno Jira %JIRA%
	FOR /F "tokens=*" %%i IN ('DIR /b "%CERRADO%*"') DO set ENCONTRADO=%%i
	MOVE  "%BASE%\CERRADOS\!encontrado!" %BASE% > NUL
	START %NPP% "%BASE%\!ENCONTRADO!\%JIRA%.LEEME"
	START %FF% --new-tab --url %URLJIRA%/DESA-%JIRA%
	GOTO FIN
	
:abrirNPP	
	FOR /F "tokens=*" %%i IN ('DIR /b "%CARPETA%*"') DO set ENCONTRADO=%%i
	IF %DEBUG%==1 echo [D] Encontrado: %ENCONTRADO%
	SET rutaActual=%CD%
	cd %base%\%encontrado%
 	start %NPP% %leeme%
	START %FF% --new-tab --url %URLJIRA%/DESA-%JIRA%
	
	cd %rutaActual%
	goto fin


:cerrarJira
	SET JIRA=%JIRA: =%
	IF %DEBUG%==1 echo [D] CerrarJira: %JIRA%
	call :cierraUno %JIRA%
	goto fin

:listarJiras
	dir /b %BASE% |  find /v /i "cerrados"
	goto fin

:cierraTodo
	choice /t 5 /C SN /D S /m "Se van a cerrar todos los JIRAS ¿de acuerdo?(S/N)?"
	IF %errorlevel%==1 GOTO cierraTodoSi
	goto FIN
	
:cierraTodoSi	
	FOR /F "tokens=*" %%X IN ('dir /b ^| findstr [0-9]') DO (
		call :cierraUno %%X
	)
	goto FIN
	
:cierraUno	[%1]
	set FABUSCAR=
	set ENCONTRADO=
	set J=%1
	set FABUSCAR=%BASE%\%J%*
	
	
	IF %DEBUG%==1 ECHO [D] parametro:              "%1"
	IF %DEBUG%==1 ECHO [D] BASE/JIRA:              "%BASE%\%J%"

	if exist %FABUSCAR% (
		FOR /F "tokens=*" %%L IN ('DIR /b %FABUSCAR% 2^> NUL') DO ( SET ENCONTRADO=%%L)
		IF %DEBUG%==1 ECHO [D] ENCONTRADO:      !ENCONTRADO!
 		IF %DEBUG%==1 ECHO [D] MOVER ORIGEN:    "%BASE%\!encontrado!" 
 		IF %DEBUG%==1 ECHO [D] MOVER DESTINO:   "%CERR%\!encontrado!"
	) else (
		IF %DEBUG%==1 echo [E] No encontrado:   "%J%"
	)
	IF %DEBUG%==1 ECHO [D] move "%BASE%\!encontrado!" "%CERR%\!encontrado!" 
 	move "%BASE%\!encontrado!" "%CERR%\!encontrado!" > nul
	goto :eof

:marcarJira 
	SET ENCONTRADO=
	SET JIRA=%JIRA: =%
	IF %DEBUG%==1 ECHO [D] marcarJira parametro:   "%JIRA%"
	IF %DEBUG%==1 ECHO [D] ruta completa:          "%BASE%\%JIRA%*"
	
	set FABUSCAR=%BASE%\%JIRA%*
	if exist %FABUSCAR% (
		IF %DEBUG%==1 ECHO [D] EXISTE:          "%BASE%\%JIRA%*"
		FOR /F "tokens=*" %%L IN ('DIR /b %FABUSCAR% 2^> NUL') DO ( SET ENCONTRADO=%%L )
		IF %DEBUG%==1 ECHO [D] NOMBRE COMPLETO: "!ENCONTRADO!"
		SET NUEVO=!ENCONTRADO: =###!
		IF %DEBUG%==1 ECHO [D] NUEVO NOMBRE: "!NUEVO!"
		
REM		for /F "tokens=1,2" %%a in ( "!ENCONTRADO!" ) do (
REM		   echo --- %%a
REM		   echo --- %%b
REM			ren !ENCONTRADO!
REM		)
	) ELSE (
		IF %DEBUG%==1 ECHO [D] NO ENCONTRADO:   "%BASE%\%JIRA%*"
	)

	
	goto :eof



:procesaParam [%1]
	set kk=%1
	SET DD=%KK:~0,1%
	if /I  "%1"=="/d" set DEBUG=1   & GOTO :EOF
 	If /I  "%1"=="/l" set MUESTRA=1 & GOTO :EOF
 	If /I  "%1"=="/a" set ABRE=1    & GOTO :EOF
 	if /I  "%1"=="/c" set CIERRA=1  & GOTO :EOF
    if /I  "%1"=="/t" set CIERRA=2  & GOTO :EOF
    if /I  "%1"=="/p" set MARCA=1   & GOTO :EOF
    IF   "%DD%"=="/"  goto :eof
	if "%JIRA%"=="-"  SET JIRA=%1   & goto :eof
	IF NOT "%1"==""   SET TITULO=%TITULO%%1
	goto :eof
	
	


:ayuda
rem SETLOCAL DISABLEDELAYEDEXPANSION
echo.
echo Crea, abre o cierra la carpeta y los ficheros para trabajar sobre un JIRA.
echo Necesita el número del JIRA para nombrar la carpeta.
echo Modo de Uso:  jira [/A /C] XXX [TEXTO]
echo   donde:
echo               XXX   es un número de JIRA.
echo               /A    creará o abrirá un entorno para el jira XXX
echo                     se puede abrir un jira solo con su número sin el TEXTO          
ECHO               /C    cerrará el entorno del jira XXX
ECHO               /T    cerrará todos los JIRAS abiertos
ECHO               /L    muestra la lista de JIRAS.
ECHO               TEXTO Es un texto descriptivo que se añade al nombre 
echo                     del directorio que se crea. No puede llevar espacios
ECHO               /D    Muestra información de depuración
echo.
echo   Los parámetros van en el orden indicado, en otro caso los resultados son impredecibles
echo   ¡¡¡¡ CUIDADO !!!!
ECHO   Este guión cambia el directorio de trabajo a la ruta: %BASE% 
ECHO.


ECHO cd "%BASE%"
chdir %BASE%

:fin



