@echo off
set NLS_LANG=AMERICAN_AMERICA.UTF8
chcp 65001 > nul
rem necesario para que las variables se evaluen en cada iteración de los
rem bucles FOR y no solo al principio del programa.
setlocal EnableDelayedExpansion

set file=config.ini 
REM CUIDADO detrás del "TAB=" hay un tabulador.
SET TAB=	

REM parámetros
if "%1" == "" goto ayuda 

set p_clave=%1
set p_seccion=%2
rem Lee el fichero configurado linea a linea y carga en la variable a 
rem todo lo que hay delante de un ; lo que haya detrás lo ignora.
for /f "delims=" %%a in (%file%) do (	
	call :quitaBlancos "%%a"	
	set linea=!linea: =!
  	if not "!linea!" equ "" (
 		set uno=!linea:~0,1!
		if "!uno!"=="[" (
			set linea=!linea:[=!
			set linea=!linea:]=!
			set seccion=!linea: =!
		) ELSE (
			for /f "tokens=1,2 delims==" %%i in ("!linea!") do (			
				set clave=%%i
				set valor=%%j
				set clave=!clave: =!
				set valor=!valor: =!
				if "!p_seccion!"=="" (
					if !p_clave!==!clave! (
						echo !valor!
						goto :eof
					)
				) else (
					if !p_seccion!==!seccion! (
						if !p_clave!==!clave! ( 
							echo !valor!
							goto :eof
						)
					)
				)
			)
		)
  	)
)



GOTO :eof


REM Esta función recibe un texto entre comillado, elimina las comillas,
REM elimina los tabuladores y todos los espacios en blanco que 
REM haya al comienzo del texto.
:quitaBlancos
	set linea=%1
	set linea=%linea:"=%
	set linea=!linea:%TAB%=!
:quitaEspacios
	if "%linea:~0,1%"==" " (
		set "linea=%linea:~1%"
		goto :quitaEspacios
	)  
	if "%linea:~0,1%"==";" set linea= 
 	for /f "tokens=1,2* delims=^;" %%h in ("!linea!") do (	
 		SET linea=%%h
 	)
	GOTO :EOF

:ayuda
echo.
echo  MODO DE USO: lee_fichero_ini  [ccc] [sss]
echo   lee el fichero "!FILE!" y devuelve el valor correspondiente a la clave y sección
echo   indicadas por linea de comandos.
echo        ccc  clave solicitada
echo        sss  sección en la que se busca la clave.  Si no se indica ninguna sección
echo             se buscará la clave en todas las secciones del fichero.
echo.

goto :eof

