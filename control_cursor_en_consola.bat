@echo off
REM Para saber más sobre los códigos de control en la consola visitar la página
REM Secuencias de terminal virtuales de la consola
REM En microsoft.com:
REM https://learn.microsoft.com/es-es/windows/console/console-virtual-terminal-sequences


rem calcula el código Ansi para enviar comandos a la consola
echo 1B 5B>ESC.hex
rem Del ESC.bin >NUL 2>&1
certutil -decodehex ESC.hex ESC.bin >NUL 2>&1
Set /P ESC=<ESC.bin

echo [ ] inicio

rem ESC[ es 1B 5B
rem 1F significa 1 linea hacia atrás desde el cursor.
rem en la consola para mostrar caracteres especiales como la tubería | 
rem hay que precederlos del carácter ^
Timeout /t 1 >Nul
ECHO.
Echo %ESC%1F[^|] linea que 
Timeout /t 1 >Nul
Echo %ESC%1F[/] linea que se
Timeout /t 1 >Nul
Echo %ESC%1F[-] linea que se repinta
Timeout /t 1 >Nul
Echo %ESC%1F[\] linea que se repinta
Timeout /t 1 >Nul
Echo %ESC%1F[^|] linea que se repinta :)
Timeout /t 1 >Nul

echo. 
echo [!]movemos el cursor y sobreescribimos las lineas
Echo [ ]Lin. 1. este texto 
Echo [ ]Lin. 2. de aquí
Echo [ ]Lin. 3. es largo 
Echo [ ]Lin. 4. y no se borra

Timeout /t 1 >Nul
Echo %ESC%4F[*]linea 1
Timeout /t 1 >Nul
Echo [*]linea 2
Timeout /t 1 >Nul
Echo [*]linea 3
Timeout /t 1 >Nul
Echo [*]linea 4


Echo %ESC%5F[#]Repetimos pero borrándo la linea y escribiendo de nuevo
Timeout /t 1 >Nul
Echo %ESC%0K[=]L 1
Timeout /t 1 >Nul
Echo %ESC%0K[=]L 2 2 
Timeout /t 1 >Nul
Echo %ESC%0K[=]L 3 3 3
Timeout /t 1 >Nul
Echo %ESC%0K[=]L 4 4 4 4

ECHO.
echo [ ] fin ;) 
