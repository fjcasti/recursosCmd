@echo off 

REM para trabajar con la consola en UTF8
chcp 65001 > nul
SET NLS_LANG=AMERICAN_AMERICA.UTF8 
SET REGISTRO="c:\Users\fdello3\Desktop\Trabajo\Jiras\cerrados\00000 diario\%date:~6,4%%date:~3,2%.log"
SET BASE=c:\users\fdello3\Desktop\trabajo\JIRAS
SET CERR=%BASE%\CERRADOS
CD /D %BASE%
SET AHORA=%date:~6,4%/%date:~3,2%/%date:~0,2% %time:~0,2%:%time:~3,2%:%time:~6,2%

SETLOCAL ENABLEDELAYEDEXPANSION
SET NPP=C:\Desarrollo\Apps\Notepad++\notepad++.exe
SET FF=C:\Users\fdello3\Bin\Firefox64\firefox.exe
SET ABRE=0
SET MUESTRA=0
SET BUSCA=0
SET CIERRA=0
SET MARCA=0
SET JIRA=-
SET TITULO=
SET DEBUG=0
SET CARPETA=
SET CERRADO=
SET LEEME=
SET PENDIENTE=0


if not exist %NPP% ECHO [E] No encuentro el editor configurado & goto fin
if not exist %FF%  ECHO [E] No encuentro el navegador configurado & goto fin


REM parámetros
if "%1" == "" goto ayuda 

FOR %%E IN (%*) DO (
    call :procesaParam %%E  
)

REM limpia los espacios en blanco
SET JIRA=%JIRA: =%
echo. 

IF %DEBUG%==1 echo [D] Dir Base:  %BASE%
IF %DEBUG%==1 echo [D] Título:    %TITULO%
IF %DEBUG%==1 echo [D] Abre:      %ABRE%
IF %DEBUG%==1 echo [D] Cierra:    %CIERRA%
IF %DEBUG%==1 echo [D] Muestra:   %MUESTRA%
IF %DEBUG%==1 echo [D] Jira:      [%JIRA%]
IF %DEBUG%==1 echo [D] Marca:     %MARCA%
IF %DEBUG%==1 echo [D] Pendiente: %PENDIENTE%
IF %DEBUG%==1 echo [D] Buscar:    %BUSCA%


IF %BUSCA%==1     GOTO buscar
IF %PENDIENTE%==1 GOTO listaPendiente
IF %MUESTRA%==1   GOTO listarJiras
IF %CIERRA%==2    GOTO cierraTodo
SET /A SUMA=%ABRE%+%CIERRA%+%MARCA%
IF NOT %SUMA%==1  GOTO AYUDA
IF "%JIRA%"=="-"  GOTO AYUDA
IF %ABRE%==1      GOTO abrirJira
IF %CIERRA%==1    GOTO cerrarJira
IF %MARCA%==1     GOTO marcarJira
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
	
	rem REGISTRO
    ECHO %AHORA% Abierto el JIRA  %JIRA% >> %REGISTRO% 
	
	IF EXIST %CARPETA%* ECHO [¡] Reabriendo el %JIRA% existente. & GOTO abrirNPP
	if exist %CERRADO%* goto abrirCerrado
	echo [-] Creando entorno Jira %JIRA%

	mkdir "%CARPETA% %TITULO%"
 	SET rutaActual=%CD%
	cd "%CARPETA% %TITULO%"
	ECHO Notas JIRA: %JIRA%    > %LEEME%
	echo             %TITULO% >> %LEEME%
	start %NPP% %leeme%
	rem START %FF% --new-tab --url https://srvespolapl03.mdef.es/jira/browse/DESA-%JIRA%
	START %FF%  https://srvespolapl03.mdef.es/jira/browse/DESA-%JIRA%
 	cd %rutaActual%
	goto fin
	
:abrirCerrado
 	ECHO Reabriendo entorno Jira %JIRA%
 	FOR /F "tokens=*" %%i IN ('DIR /b "%CERRADO%*"') DO set ENCONTRADO=%%i
 	MOVE  "%BASE%\CERRADOS\!encontrado!" %BASE% > NUL
 	START %NPP% "%BASE%\!ENCONTRADO!\%JIRA%.LEEME"
 	START %FF%  https://srvespolapl03.mdef.es/jira/browse/DESA-%JIRA%
 	GOTO FIN
	
:abrirNPP	
	FOR /F "tokens=*" %%i IN ('DIR /b "%CARPETA%*"') DO set ENCONTRADO=%%i
	IF %DEBUG%==1 echo [D] Encontrado: %ENCONTRADO%
	SET rutaActual=%CD%
	cd %base%\%encontrado%
 	start %NPP% %leeme%
	START %FF%  https://srvespolapl03.mdef.es/jira/browse/DESA-%JIRA%
	
	cd %rutaActual%
	goto fin


:cerrarJira
	SET JIRA=%JIRA: =%
	IF %DEBUG%==1 echo [D] CerrarJira: %JIRA%

   	rem REGISTRO
    ECHO %AHORA% Cerrando el JIRA %JIRA% >> %REGISTRO% 

	call :cierraUno %JIRA%
	goto fin

:listarJiras
    SET VAR=
    FOR /F "tokens=* USEBACKQ" %%F IN (`dir /b %BASE%`) DO (
        SET var=!VAR!%%F
    )
    if %debug%==1 echo [D] dir /b %base% = !var!
    IF !VAR!==cerrados (
        ECHO Sin tareas
    ) ELSE (
        ECHO [ ] Lista de tareas
        dir /b %BASE% |  find /v /i "cerrados"
    )

	goto fin

:cierraTodo
	choice /t 5 /C SN /D S /m "Se van a cerrar todos los JIRAS ¿de acuerdo?(S/N)?"
	IF %errorlevel%==1 GOTO cierraTodoSi
	goto FIN
	
:cierraTodoSi	
    	rem REGISTRO
    ECHO %AHORA% ¡¡Cerrando todo^^!^^! >> %REGISTRO% 

	FOR /F "tokens=*" %%X IN ('dir /b ^| findstr [0-9]') DO (
        ECHO %%X >> %REGISTRO%  
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
	) ELSE (
		IF %DEBUG%==1 ECHO [D] NO ENCONTRADO:   "%BASE%\%JIRA%*"
	)

	
	goto :eof
    
:listaPendiente
    echo [A] Lista tareas pendientes. 
    echo [A] A su vez, también él pendiente.
    echo [A] "%BASE%"
    echo [A] buscar las etiquetas hacer:  y   error:
    FOR /F "tokens=*" %%i IN ('DIR /b /s  *leeme ^| FIND /V /I "cerrados"') DO (
        echo [F] %%i
    )
    
    
    goto :fin

:buscar
    echo [ ] Buscando tareas con el texto: %JIRA%
    IF %DEBUG%==1 ECHO [B] DIR /B /AD "CERRADOS\*%JIRA%*"
    FOR /F "tokens=*" %%L IN ('DIR /B /AD "CERRADOS\*%JIRA%*"') DO (
        echo [^>] %%L
    )
    goto :fin


:procesaParam [%1]
	set kk=%1
	SET DD=%KK:~0,1%
	if /I  "%1"=="/d" set DEBUG=1     & GOTO :EOF
 	If /I  "%1"=="/l" set MUESTRA=1   & GOTO :EOF
 	If /I  "%1"=="/b" set BUSCA=1     & GOTO :EOF    
 	If /I  "%1"=="/a" set ABRE=1      & GOTO :EOF
 	if /I  "%1"=="/c" set CIERRA=1    & GOTO :EOF
    if /I  "%1"=="/t" set CIERRA=2    & GOTO :EOF
    if /I  "%1"=="/p" set MARCA=1     & GOTO :EOF
    IF /i  "%1"=="/u" SET PENDIENTE=1 & GOTO :EOF
    IF   "%DD%"=="/"                    GOTO :EOF
	if "%JIRA%"=="-"  SET JIRA=%1     & GOTO :EOF
	IF NOT "%1"==""   SET TITULO=%TITULO%%1
	goto :eof
	
	


:ayuda
rem SETLOCAL DISABLEDELAYEDEXPANSION
echo.
echo Crea, abre o cierra la carpeta y los ficheros para trabajar sobre un JIRA.
echo Necesita el número del JIRA para nombrar la carpeta.
echo Modo de Uso:  jira [/A /C] [/B CADENA] XXX [TEXTO]
echo   donde:
echo               XXX   es un número de JIRA.
echo               /A    creará o abrirá un entorno para el jira XXX
echo                     se puede abrir un jira solo con su número sin el TEXTO          
echo               /B    Busca el texto dado en nombres de JIRAS cerrados y los MUESTRA 
ECHO               /C    cerrará el entorno del jira XXX
ECHO               /T    cerrará todos los JIRAS abiertos
ECHO               /L    muestra la lista de JIRAS.
ECHO               TEXTO Es un texto descriptivo que se añade al nombre 
echo                     del directorio que se crea. No puede llevar espacios
ECHO               /D    Muestra información de depuración.
ECHO               /U    (pendiente) Muestra las tareas pendientes marcadas en los 
ECHO                     ficheros .LEEME de todos los jiras abiertos.
echo.
echo   ¡¡¡¡ CUIDADO ^^!^^!^^!^^!
echo   Los parámetros van en el orden indicado, en otro caso los resultados son impredecibles
ECHO   Esto ya lo cambiaré, pero de momento no está hecho.




:fin
ECHO.



