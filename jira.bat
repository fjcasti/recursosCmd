@echo off
SETLOCAL EnableDelayedExpansion

REM v2.1 Añadida opción /T para abrir solo Total Commander en carpeta de tarea.
REM v2.0 Abrir el navegador con la URL de mantis y el código de la tarea

rem      añadida la función lanzar_apps para todos.
rem      No abrir navegador si el código comienza con 0x (tareas personales).
rem      Integración con Total Commander: abre el directorio de la tarea en panel izquierdo.

REM *** ajuste de parámetros ********************************************
SET VERSION=1.5
SET RUTA_BASE=c:\Users\dars\Desktop\Casti\tareas
SET RUTA_LOG=%RUTA_BASE%\log
SET RUTA_CERR=%RUTA_BASE%\CERRADAS
SET NPP=c:\Users\dars\bin\Npp\notepad++.exe
SET FF="C:\Program Files\Mozilla Firefox\firefox.exe"
SET TC="C:\Program Files\totalcmd\TOTALCMD64.EXE"
SET FICH_LOG=%RUTA_LOG%\%date:~6,4%%date:~3,2%.log
SET AHORA=%date:~6,4%/%date:~3,2%/%date:~0,2% %time:~0,2%:%time:~3,2%:%time:~6,2%


echo JIRA v%VERSION% Gestión de tareas.
REM *** validación de parámetros ********************************************
if not exist "%RUTA_BASE%\" ECHO [E] No encuentro el directorio base configurado: %RUTA_BASE%            & goto fin
if not exist %NPP%          ECHO [E] No encuentro el editor configurado                                  & goto fin
if not exist %FF%           ECHO [E] No encuentro el navegador configurado                               & goto fin
if not exist %TC%           ECHO [E] No encuentro Total Commander configurado                            & goto fin
if not exist "%RUTA_LOG%\"  ECHO [E] No encuentro el directorio log. Creando: %RUTA_LOG%                 & mkdir "%RUTA_LOG%" 
if not exist "%RUTA_CERR%\" ECHO [E] No encuentro el directorio de tareas cerradas. Creando: %RUTA_CERR% & mkdir "%RUTA_CERR%" 

SET ABRE=0
SET MUESTRA=0
SET BUSCA=0
SET CIERRA=0
SET MARCA=0
SET PENDIENTE=0
SET AYUDA=0
SET CODIGO=-
SET TITULO=
SET LEEME=
SET LISTA_TAREAS=0
SET MAXIMO=0
SET TEXTO_BUSCAR=
SET TOTAL_COMMANDER=0

REM *** Cambio a la ruta de trabajo temporalment ********************************************
CD /D %RUTA_BASE%

rem *** Procesamiento de parámetros ********************************************
:procesar_loop
    if [%1]==[] goto fin_procesar
    
    REM Capturar el parámetro en una variable temporal
    set "PARAM=%~1"  
    SET "DD=%PARAM:~0,1%"

    REM Procesar switches
    if /I [%PARAM%]==[/h] SET AYUDA=1         & shift & goto procesar_loop
    if /I [%PARAM%]==[/?] SET AYUDA=1         & shift & goto procesar_loop
    If /I [%PARAM%]==[/l] set LISTA_TAREAS=1  & shift & goto procesar_loop
    if /I [%PARAM%]==[/m] set MAXIMO=1        & shift & goto procesar_loop
    If /I [%PARAM%]==[/a] set ABRE=1          & shift & goto procesar_loop
    IF /I [%PARAM%]==[/c] set CIERRA=1        & shift & goto procesar_loop
    If /I [%PARAM%]==[/b] set BUSCA=1         & shift & goto procesar_loop
    IF /I [%PARAM%]==[/p] set PENDIENTE=1     & shift & goto procesar_loop
    IF /I [%PARAM%]==[/t] set TOTAL_COMMANDER=1 & shift & goto procesar_loop
    
    REM Si llego aquí y el primer caracter es / se ha pasado un parámetro que no se entiende
    IF [%DD%]==[/] ECHO [E] Parámetro no válido: %PARAM% & SET AYUDA=1 & shift & goto procesar_loop
    
    REM Aquí sólo se llega si el primer caracter NO es una barra /
    if [%CODIGO%]==[-] SET "CODIGO=%~1" & shift & goto procesar_loop
    
    REM Si ya se recogió el código se van concatenando uno a uno el resto de parámetros
    IF "%TITULO%"=="" (
        SET "TITULO=%PARAM%"
    ) ELSE (
         SET "TITULO=%TITULO% %PARAM%"
    )
    shift
    goto procesar_loop
    
:fin_procesar

IF %AYUDA%==1          goto ayuda
IF %LISTA_TAREAS%==1   goto lista_tareas
IF %MAXIMO%==1         goto buscar_maximo
IF %BUSCA%==1          goto buscar_texto
IF %TOTAL_COMMANDER%==1 goto abrir_total_commander
IF %ABRE%==1           goto abrir_tarea
IF %CIERRA%==1         goto cerrar_tarea
IF %PENDIENTE%==1      goto mostrar_pendientes

echo.
REM Si llega aquí es que no se ha proporcionado ningún parámetro válido. Se listan las tareas.
goto lista_tareas

rem *** Listado de las tareas pendientes ************************************************
:lista_tareas
    set CONTADOR=0
    FOR /D %%G IN ("%RUTA_BASE%\*") DO (
        IF /I NOT [%%~nG]==[CERRADAS] (
            IF /I NOT [%%~nG]==[log] (
                SET /A CONTADOR+=1
                ECHO [ ] %%~nG
            )
        )
    )
    IF %CONTADOR%==0 echo [ ] No hay tareas pendientes.
    goto :fin

rem *** Busqueda del código máximo ************************************************
:buscar_maximo
    SET MAX_NUM=000

    REM Buscar en RUTA_BASE
    FOR /D %%G IN ("%RUTA_BASE%\0x*") DO (
        SET DIRNAME=%%~nG
        call :extraer_numero "!DIRNAME!"
    )
    
    REM Buscar en RUTA_CERR si existe
    IF EXIST "%RUTA_CERR%\" (
        FOR /D %%G IN ("%RUTA_CERR%\0x*") DO (
            SET DIRNAME=%%~nG
            call :extraer_numero "!DIRNAME!"
        )
    )
    
    ECHO [I] El código máximo encontrado es: 0x%MAX_NUM%
    goto :fin

rem *** Búsqueda de texto en tareas cerradas ************************************************
:buscar_texto
    IF [%CODIGO%]==[-] (
        ECHO [E] Se necesita especificar un texto para buscar.
        GOTO :ayuda
    )
    SET TEXTO_BUSCAR=%CODIGO%
    IF  NOT "%TITULO%"=="" SET "TEXTO_BUSCAR=%CODIGO% %TITULO%"

    SET CONTADOR=0

    FOR /D %%G IN ("%RUTA_CERR%\*") DO (
        SET "NOMBRE_CARPETA=%%~nG"
        echo !NOMBRE_CARPETA! | findstr /I /C:"%TEXTO_BUSCAR%" >nul
        IF !ERRORLEVEL! EQU 0 (
            SET /A CONTADOR+=1
            ECHO [ ] %%~nG
        )
    )
    goto :fin

:extraer_numero [%1]
    SETLOCAL EnableDelayedExpansion
    SET NOMBRE=%~1
    REM Extraer la parte después de "0x"
    SET RESTO=!NOMBRE:~2!
    
    REM Extraer solo los dígitos iniciales
    SET NUM=
    FOR /L %%i IN (0,1,20) DO (
        SET CHAR=!RESTO:~%%i,1!
        IF "!CHAR!" GEQ "0" IF "!CHAR!" LEQ "9" (
            SET NUM=!NUM!!CHAR!
        ) ELSE (
            GOTO :comparar_num
        )
    )
    
:comparar_num
    IF DEFINED NUM (
        REM Eliminar ceros a la izquierda para comparación
        SET /A NUM_INT=1!NUM! - 1000
        SET /A MAX_INT=1!MAX_NUM! - 1000
        IF !NUM_INT! GTR !MAX_INT! (
            ENDLOCAL & SET MAX_NUM=%NUM%
        ) ELSE (
            ENDLOCAL
        )
    ) ELSE (
        ENDLOCAL
    )
    GOTO :EOF


:abrir_total_commander
    IF [%CODIGO%]==[-] (
        ECHO [E] Se necesita un CODIGO para cambiar a la carpeta.
        GOTO :ayuda
    )

    REM Buscar primero en tareas abiertas
    SET CARPETA_ENCONTRADA=
    FOR /F "tokens=*" %%i IN ('DIR /b /ad "%RUTA_BASE%\%CODIGO%*" 2^>nul') DO (
        SET CARPETA_ENCONTRADA=%%i
        GOTO :tc_carpeta_hallada
    )

    REM Si no se encontró, buscar en tareas cerradas
    FOR /F "tokens=*" %%i IN ('DIR /b /ad "%RUTA_CERR%\%CODIGO%*" 2^>nul') DO (
        SET CARPETA_ENCONTRADA=%%i
        SET "RUTA_TAREA=%RUTA_CERR%\%%i\"
        GOTO :tc_abrir
    )

    REM Si no se encontró en ningún sitio
    ECHO [E] No se encontró ninguna tarea con el código: %CODIGO%
    GOTO :fin

:tc_carpeta_hallada
    SET "RUTA_TAREA=%RUTA_BASE%\%CARPETA_ENCONTRADA%\"

:tc_abrir
    ECHO [ ] Abriendo Total Commander en: %CARPETA_ENCONTRADA%
    start "" %TC% /O /T /L="%RUTA_TAREA%"
    GOTO :fin


:abrir_tarea
    IF [%CODIGO%]==[-] (
        ECHO [E] Se necesita un CODIGO para abrir una tarea.
        GOTO :ayuda
    )
    
    REM Verificar si existe en tareas abiertas
    IF EXIST %RUTA_BASE%\%CODIGO%* ECHO [ ] Reabriendo el %CODIGO% existente. & GOTO reabrir_tarea
    
    REM Verificar si existe en tareas cerradas
    IF EXIST "%RUTA_CERR%\%CODIGO%*" GOTO reabrir_tarea_cerrada
    
    REM Si no existe en ningún sitio, crear nueva tarea
    IF "%TITULO%"=="" (
        SET "NUEVA_CARPETA=%RUTA_BASE%\%CODIGO%"
    ) ELSE (
        SET "NUEVA_CARPETA=%RUTA_BASE%\%CODIGO% %TITULO%"
    )

    IF not  EXIST "%NUEVA_CARPETA%" (
        MD "%NUEVA_CARPETA%"
        ECHO [ ] Carpeta creada: %NUEVA_CARPETA%
    )
	
	SET ARCHIVO_LEEME=%NUEVA_CARPETA%\%CODIGO%.leeme
    
    IF NOT EXIST "%ARCHIVO_LEEME%" (
        ECHO Notas de la tarea: %CODIGO% > "%ARCHIVO_LEEME%"
        ECHO                    %TITULO% >> "%ARCHIVO_LEEME%"
    )

    GOTO :lanzar_apps

:reabrir_tarea
	FOR /F "tokens=*" %%i IN ('DIR /b "%RUTA_BASE%\%CODIGO%*"') DO set ENCONTRADO=%%i
    SET "ARCHIVO_LEEME=%RUTA_BASE%\%ENCONTRADO%\%CODIGO%.leeme"
    goto :lanzar_apps


:reabrir_tarea_cerrada
    REM Buscar la carpeta en CERRADAS
    FOR /F "tokens=*" %%i IN ('DIR /b /ad "%RUTA_CERR%\%CODIGO%*" 2^>nul') DO (
        SET CARPETA_CERRADA=%%i
        GOTO :mover_de_cerradas
    )
    
:mover_de_cerradas
    ECHO [ ] Reabriendo tarea: %CARPETA_CERRADA%
    
    REM Mover la carpeta de CERRADAS a RUTA_BASE
    MOVE "%RUTA_CERR%\%CARPETA_CERRADA%" "%RUTA_BASE%\" >nul
    
    IF ERRORLEVEL 1 (
        ECHO [E] Error al mover la tarea desde CERRADAS
        GOTO :fin
    )
    
    REM Abrir el archivo leeme
    SET "ARCHIVO_LEEME=%RUTA_BASE%\%CARPETA_CERRADA%\%CODIGO%.leeme"
    goto :lanzar_apps

:cerrar_tarea
 	SET CODIGO=%CODIGO: =%
    
    IF [%CODIGO%]==[-] (
        ECHO [E] Se necesita un CODIGO para cerrar una tarea.
        GOTO :ayuda
    )
    
    REM Buscar la carpeta que comienza con el código
    SET CARPETA_ENCONTRADA=
    FOR /F "tokens=*" %%i IN ('DIR /b /ad "%RUTA_BASE%\%CODIGO%*" 2^>nul') DO (
        SET CARPETA_ENCONTRADA=%%i
        GOTO :carpeta_hallada
    )
    
    REM Si no se encontró la carpeta
    IF NOT DEFINED CARPETA_ENCONTRADA (
        ECHO [E] No se encontró ninguna tarea con el código: %CODIGO%
        GOTO :fin
    )
    
:lanzar_apps
    REM Extraer el directorio de la tarea desde ARCHIVO_LEEME
    FOR %%A IN ("%ARCHIVO_LEEME%") DO SET "RUTA_TAREA=%%~dpA"

    REM Abrir Notepad++ con el archivo .leeme
    start %NPP% "%ARCHIVO_LEEME%"

    REM Abrir Total Commander en panel izquierdo con nueva pestaña
    start "" %TC% /O /T /L="%RUTA_TAREA%"

    REM Solo abrir navegador si el código NO comienza con 0x (tareas sin mantis)
    SET "PREFIJO=%CODIGO:~0,2%"
    IF /I NOT [%PREFIJO%]==[0x] (
        START %FF%  https://mantis.dars.es/view.php?id=%CODIGO%
    )
    goto :fin

:carpeta_hallada
    ECHO [ ] Cerrando tarea: %CARPETA_ENCONTRADA%
    
    REM Mover la carpeta a CERRADAS
    MOVE "%RUTA_BASE%\%CARPETA_ENCONTRADA%" "%RUTA_CERR%\" >nul
    
    IF ERRORLEVEL 1 (
        ECHO [E] Error al mover la tarea a %RUTA_CERR%
    )    
    goto :fin


rem *** Mostrar pendientes /HACER: ************************************************
:mostrar_pendientes
    IF [%CODIGO%]==[-] (
         FOR /D %%G IN ("%RUTA_BASE%\*") DO (
            IF /I NOT [%%~nG]==[CERRADAS] (
                IF /I NOT [%%~nG]==[log] (
                     FOR %%F IN ("%%G\*.leeme") DO (
                        findstr /I /C:"/HACER:" "%%F" >nul
                        IF !ERRORLEVEL! EQU 0 (
                            ECHO [%%~nG]
                            FOR /F "delims=" %%L IN ('findstr /N /I /C:"/HACER:" "%%F"') DO (
                                ECHO [ ] %%L
                            )
                            ECHO.
                        )
                     )
                )
            )
         )
    ) ELSE (
        REM Logic for specific code
        REM Find folder starting with %CODIGO% in RUTA_BASE
        SET ENCONTRADO=
        SET NOMBRE_ENCONTRADO=
        FOR /D %%G IN ("%RUTA_BASE%\%CODIGO%*") DO (
            SET ENCONTRADO=%%G
            SET NOMBRE_ENCONTRADO=%%~nG
        )
        
        IF DEFINED ENCONTRADO (
            SET FOUND_LEEME=0
            FOR %%F IN ("!ENCONTRADO!\*.leeme") DO (
                SET FOUND_LEEME=1
                ECHO [!NOMBRE_ENCONTRADO!]
                FOR /F "delims=" %%L IN ('findstr /N /I /C:"/HACER:" "%%F"') DO (
                    ECHO [ ] %%L
                )
            )
            IF !FOUND_LEEME!==0 ECHO [I] No se encontró fichero .leeme en !ENCONTRADO!
        ) ELSE (
            ECHO [E] No se encontró tarea abierta con código %CODIGO%
        )
    )
    goto :fin


rem *** AYUDA ********************************************
:ayuda
	echo Crea, abre o cierra la carpeta y los ficheros para trabajar sobre tareas pendientes.
	echo Necesita el CODIGO para nombrar la carpeta.
	echo Modo de Uso:  jira [/H /? /L /M /A /C /T] [/B CADENA] CODIGO [TEXTO]
	echo   donde:
	echo               CODIGO es un número de la tarea.
    echo               /H     Muestra esta ayuda.
    echo(              /?     Muestra esta ayuda.
	echo               /A     creará o abrirá un entorno para la tarea CODIGO.
	echo                      Se puede abrir una tarea solo con su CODIGO y sin el TEXTO.
	ECHO               /M     Busca el código máximo (0xNNN) en tareas abiertas y cerradas.
    ECHO                      Estos códigos son para tareas sin código oficial o tareas personales.
	echo               /B     Busca el texto dado en nombres de tareas cerradas y los muestra.
	ECHO               /C     cerrará el entorno de la tarea con el código CODIGO.
	ECHO               /L     muestra la lista de tareas. Igual que sin parámetros.
	ECHO               /T     Abre Total Commander en la carpeta de la tarea CODIGO.
	ECHO                      Busca en tareas abiertas y cerradas. Solo abre el gestor de archivos.
	ECHO               TEXTO  Es un texto descriptivo que se añade al nombre del directorio que
    echo                      se crea. Todo término que no comience con / después de leer CODIGO
    echo                      se concatenará a TEXTO incluso si hay parámetros intercalados.
	ECHO               /P     Muestra las marcas /HACER: en los ficheros .LEEME
	ECHO                      de todos los jiras abiertos (o del CODIGO especificado).
    ECHO               Independientemente del orden en el que se pasen los parámetros, se ejecutarán
    ECHO               en el orden que se indican en esta ayuda.
    ECHO Este guión cambia la ruta base de trabajo.
	echo.
    goto :fin   

:depurar
    echo [D] AYUDA:         %AYUDA%
    echo [D] LISTA_TAREAS:  %LISTA_TAREAS%
    echo [D] MAXIMO:        %MAXIMO%
    echo [D] ABRE:          %ABRE%
    echo [D] CIERRA:        %CIERRA%
 
    echo [D] MUESTRA:       %MUESTRA%
    echo [D] BUSCA:         %BUSCA%
    echo [D] MARCA:         %MARCA%
    echo [D] TEXTO_BUSCAR:  %TEXTO_BUSCAR%
    echo [D] CODIGO:        %CODIGO%
    echo [D] TITULO:        %TITULO%
    echo [D] NUEVA_CARPETA: %NUEVA_CARPETA%
    echo [D] ARCHIVO_LEEME: %ARCHIVO_LEEME%
    goto :EOF

:fin
ECHO.
