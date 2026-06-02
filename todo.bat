@echo off
set NLS_LANG=AMERICAN_AMERICA.UTF8
chcp 65001 > nul
setlocal enabledelayedexpansion

set "DATAFILE=%~dp0todo.dat"
set "TEMPFILE=%~dp0todo.tmp"

if not exist "%DATAFILE%" type nul > "%DATAFILE%"

if /i "%~1"=="/?" goto :show_help
if /i "%~2"=="/?" goto :show_help
if /i "%~3"=="/?" goto :show_help

if "%~1"=="" goto :show_pending
if /i "%~1"=="/a" goto :add_task
if /i "%~1"=="/l" goto :show_all
if /i "%~1"=="/c" goto :complete_task
if /i "%~1"=="/d" goto :detail_task
if /i "%~1"=="/n" goto :add_note
if /i "%~1"=="/+" goto :boost_task
if /i "%~1"=="/-" goto :lower_task
if /i "%~1"=="/compacta" goto :compact_tasks

:: ============================================================
:show_help
echo.
echo  TODO.BAT 1.2 - Gestor de tareas pendientes
echo.
echo  Uso: TODO [opcion] [argumentos]
echo.
echo  (sin opciones)     Lista las tareas pendientes
echo( /?                 Muestra esta ayuda
echo  /a XXX             Crea una nueva tarea con el texto XXX
echo  /l                 Lista todas las tareas
echo  /c NNN             Completa la tarea con el número NNN
echo  /d NNN             Muestra el detalle de la tarea NNN
echo  /n NNN XXX         Añade una nota con el texto XXX a la tarea XXX
echo  /+ NNN             Incrementa la prioridad de la tarea NNN
echo  /- NNN             Decrementa la prioridad de la tarea NNN
echo  /compacta          Elimina tareas completadas y renumera las restantes
echo.
goto :end

:: ============================================================
:show_pending
call :do_list 0
goto :end

:show_all
call :do_list 1
goto :end

:: Formato: T|id|prio|created|completed|title  (tokens=1-5*)
::   %%a=T  %%b=id  %%c=prio  %%d=created  %%e=completed  %%f=title
:do_list
set "_showall=%~1"
set "_shown=0"
set "_maxprio=0"
for /f "usebackq tokens=1-5* delims=|" %%a in ("%DATAFILE%") do (
    if /i "%%a"=="T" (
        set /a "_p=%%c"
        if !_p! GTR !_maxprio! set "_maxprio=!_p!"
    )
)
set /a "_curprio=_maxprio"
:_prio_iter
for /f "usebackq tokens=1-5* delims=|" %%a in ("%DATAFILE%") do (
    if /i "%%a"=="T" (
        set /a "_p=%%c"
        if !_p! EQU !_curprio! (
            if "!_showall!"=="1" (
                call :print_row %%b "%%e" "%%f" !_curprio!
                set /a _shown+=1
            ) else if "%%e"=="0" (
                call :print_row %%b "%%e" "%%f" !_curprio!
                set /a _shown+=1
            )
        )
    )
)
set /a "_curprio-=1"
if !_curprio! GEQ 0 goto :_prio_iter
if !_shown!==0 (
    if "!_showall!"=="1" (
        echo No hay tareas registradas.
    ) else (
        echo No hay tareas pendientes.
    )
)
goto :eof

:print_row
set /a "_rn=%~1"
set "_rc=%~2"
set "_rt=%~3"
set /a "_rp=%~4"
set "_mark= "
if "!_rc!" neq "0" (
    set "_mark=X"
) else if !_rp! GTR 0 (
    set "_mark=!_rp!"
)
if !_rn! LSS 10 (
    echo 0!_rn! [!_mark!] !_rt!
) else (
    echo !_rn! [!_mark!] !_rt!
)
goto :eof

:: ============================================================
:add_task
if "%~2"=="" (
    echo Error: Especifique el titulo de la tarea.
    echo Uso: TODO /a ^<titulo^>
    goto :end
)
set "_title=%~2"

:_loop_title
shift /2
if "%~2"=="" goto :_do_add
set "_title=!_title! %~2"
goto :_loop_title

:_do_add
call :get_now
set "_max=0"
for /f "usebackq tokens=1,2 delims=|" %%a in ("%DATAFILE%") do (
    if /i "%%a"=="T" (
        set /a "_cur=%%b"
        if !_cur! GTR !_max! set "_max=!_cur!"
    )
)
set /a "_next=_max+1"
echo T^|!_next!^|0^|!_now!^|0^|!_title!>> "%DATAFILE%"
if !_next! LSS 10 (
    echo Tarea 0!_next! creada: !_title!
) else (
    echo Tarea !_next! creada: !_title!
)
goto :end

:: ============================================================
:complete_task
if "%~2"=="" (
    echo Error: Especifique el numero de tarea.
    echo Uso: TODO /c ^<numero^>
    goto :end
)
set /a "_target=%~2"
set "_found=0"
set "_done=0"
for /f "usebackq tokens=1-5* delims=|" %%a in ("%DATAFILE%") do (
    if /i "%%a"=="T" (
        set /a "_cn=%%b"
        if !_cn! EQU !_target! (
            set "_found=1"
            if "%%e" neq "0" set "_done=1"
        )
    )
)
if "!_found!"=="0" (
    echo Error: La tarea !_target! no existe.
    goto :end
)
if "!_done!"=="1" (
    echo La tarea !_target! ya estaba completada.
    goto :end
)
call :get_now
if exist "%TEMPFILE%" del "%TEMPFILE%"
for /f "usebackq delims=" %%L in ("%DATAFILE%") do (
    set "_line=%%L"
    set "_is_target=0"
    for /f "tokens=1,2 delims=|" %%a in ("!_line!") do (
        if /i "%%a"=="T" (
            set /a "_ln=%%b"
            if !_ln! EQU !_target! set "_is_target=1"
        )
    )
    if "!_is_target!"=="1" (
        for /f "tokens=1-5* delims=|" %%a in ("!_line!") do (
            echo T^|%%b^|%%c^|%%d^|!_now!^|%%f>> "%TEMPFILE%"
        )
    ) else (
        echo !_line!>> "%TEMPFILE%"
    )
)
move /y "%TEMPFILE%" "%DATAFILE%" >nul
goto :show_pending

:: ============================================================
:boost_task
if "%~2"=="" (
    echo Error: Especifique el numero de tarea.
    echo Uso: TODO /+ ^<numero^>
    goto :end
)
set /a "_target=%~2"
set "_found=0"
set "_curprio=0"
for /f "usebackq tokens=1-5* delims=|" %%a in ("%DATAFILE%") do (
    if /i "%%a"=="T" (
        set /a "_cn=%%b"
        if !_cn! EQU !_target! (
            set "_found=1"
            set /a "_curprio=%%c"
        )
    )
)
if "!_found!"=="0" (
    echo Error: La tarea !_target! no existe.
    goto :end
)
set /a "_newprio=_curprio+1"
if exist "%TEMPFILE%" del "%TEMPFILE%"
for /f "usebackq delims=" %%L in ("%DATAFILE%") do (
    set "_line=%%L"
    set "_is_target=0"
    for /f "tokens=1,2 delims=|" %%a in ("!_line!") do (
        if /i "%%a"=="T" (
            set /a "_ln=%%b"
            if !_ln! EQU !_target! set "_is_target=1"
        )
    )
    if "!_is_target!"=="1" (
        for /f "tokens=1-5* delims=|" %%a in ("!_line!") do (
            echo T^|%%b^|!_newprio!^|%%d^|%%e^|%%f>> "%TEMPFILE%"
        )
    ) else (
        echo !_line!>> "%TEMPFILE%"
    )
)
move /y "%TEMPFILE%" "%DATAFILE%" >nul
if !_target! LSS 10 (
    echo Tarea 0!_target! prioridad: !_curprio! -^> !_newprio!
) else (
    echo Tarea !_target! prioridad: !_curprio! -^> !_newprio!
)
goto :end

:: ============================================================
:lower_task
if "%~2"=="" (
    echo Error: Especifique el numero de tarea.
    echo Uso: TODO /- ^<numero^>
    goto :end
)
set /a "_target=%~2"
set "_found=0"
set "_curprio=0"
for /f "usebackq tokens=1-5* delims=|" %%a in ("%DATAFILE%") do (
    if /i "%%a"=="T" (
        set /a "_cn=%%b"
        if !_cn! EQU !_target! (
            set "_found=1"
            set /a "_curprio=%%c"
        )
    )
)
if "!_found!"=="0" (
    echo Error: La tarea !_target! no existe.
    goto :end
)
if !_curprio! EQU 0 (
    echo La tarea !_target! ya tiene prioridad minima ^(0^).
    goto :end
)
set /a "_newprio=_curprio-1"
if exist "%TEMPFILE%" del "%TEMPFILE%"
for /f "usebackq delims=" %%L in ("%DATAFILE%") do (
    set "_line=%%L"
    set "_is_target=0"
    for /f "tokens=1,2 delims=|" %%a in ("!_line!") do (
        if /i "%%a"=="T" (
            set /a "_ln=%%b"
            if !_ln! EQU !_target! set "_is_target=1"
        )
    )
    if "!_is_target!"=="1" (
        for /f "tokens=1-5* delims=|" %%a in ("!_line!") do (
            echo T^|%%b^|!_newprio!^|%%d^|%%e^|%%f>> "%TEMPFILE%"
        )
    ) else (
        echo !_line!>> "%TEMPFILE%"
    )
)
move /y "%TEMPFILE%" "%DATAFILE%" >nul
if !_target! LSS 10 (
    echo Tarea 0!_target! prioridad: !_curprio! -^> !_newprio!
) else (
    echo Tarea !_target! prioridad: !_curprio! -^> !_newprio!
)
goto :end

:: ============================================================
:detail_task
if "%~2"=="" (
    echo Error: Especifique el numero de tarea.
    echo Uso: TODO /d ^<numero^>
    goto :end
)
set /a "_target=%~2"
call :show_detail
goto :end

:show_detail
set "_found=0"
for /f "usebackq tokens=1-5* delims=|" %%a in ("%DATAFILE%") do (
    if /i "%%a"=="T" (
        set /a "_cn=%%b"
        if !_cn! EQU !_target! (
            set "_found=1"
            set "_dprio=%%c"
            set "_dcreated=%%d"
            set "_dcomp=%%e"
            set "_dtitle=%%f"
        )
    )
)
if "!_found!"=="0" (
    echo Error: La tarea !_target! no existe.
    goto :eof
)
echo.
if !_target! LSS 10 (
    echo  Tarea  : 0!_target!
) else (
    echo  Tarea  : !_target!
)
echo  Titulo : !_dtitle!
echo  Prio   : !_dprio!
call :fmt_dt "!_dcreated!" _disp_c
echo  Creada : !_disp_c!
if "!_dcomp!"=="0" (
    echo  Estado : Pendiente
) else (
    call :fmt_dt "!_dcomp!" _disp_d
    echo  Estado : Completada el !_disp_d!
)
echo  Notas  :
set "_has_notes=0"
for /f "usebackq tokens=1-2* delims=|" %%a in ("%DATAFILE%") do (
    if /i "%%a"=="N" (
        set /a "_nt=%%b"
        if !_nt! EQU !_target! (
            set "_has_notes=1"
            echo    - %%c
        )
    )
)
if "!_has_notes!"=="0" echo    (sin notas)
echo.
goto :eof

:fmt_dt
set "_ds=%~1"
set "_ov=%~2"
set "!_ov!=!_ds:~6,2!/!_ds:~4,2!/!_ds:~0,4! !_ds:~8,2!:!_ds:~10,2!:!_ds:~12,2!"
goto :eof

:: ============================================================
:add_note
if "%~2"=="" (
    echo Error: Especifique el numero de tarea.
    echo Uso: TODO /n ^<numero^> ^<nota^>
    goto :end
)
set /a "_target=%~2"
if "%~3"=="" (
    echo Error: Especifique el texto de la nota.
    echo Uso: TODO /n ^<numero^> ^<nota^>
    goto :end
)
set "_note=%~3"

:_loop_note
shift /3
if "%~3"=="" goto :_do_note
set "_note=!_note! %~3"
goto :_loop_note

:_do_note
set "_found=0"
for /f "usebackq tokens=1,2 delims=|" %%a in ("%DATAFILE%") do (
    if /i "%%a"=="T" (
        set /a "_cn=%%b"
        if !_cn! EQU !_target! set "_found=1"
    )
)
if "!_found!"=="0" (
    echo Error: La tarea !_target! no existe.
    goto :end
)
echo N^|!_target!^|!_note!>> "%DATAFILE%"
call :show_detail
goto :end

:: ============================================================
:compact_tasks
set "_count_done=0"
for /f "usebackq tokens=1-5* delims=|" %%a in ("%DATAFILE%") do (
    if /i "%%a"=="T" (
        if "%%e" neq "0" set /a "_count_done+=1"
    )
)
if !_count_done!==0 (
    echo No hay tareas completadas que eliminar.
    goto :end
)
echo Se eliminaran !_count_done! tarea(s) completada(s) y se renumeraran las restantes.
set /p "_confirm=Confirmar? (S/N): "
if /i "!_confirm!" neq "S" (
    echo Operacion cancelada.
    goto :end
)
set "_new_id=0"
for /f "usebackq tokens=1-5* delims=|" %%a in ("%DATAFILE%") do (
    if /i "%%a"=="T" (
        if "%%e"=="0" (
            set /a "_new_id+=1"
            set "_map_%%b=!_new_id!"
        )
    )
)
if exist "%TEMPFILE%" del "%TEMPFILE%"
type nul > "%TEMPFILE%"
for /f "usebackq delims=" %%L in ("%DATAFILE%") do (
    set "_line=%%L"
    for /f "tokens=1 delims=|" %%a in ("!_line!") do set "_rectype=%%a"
    if /i "!_rectype!"=="T" (
        for /f "tokens=1-5* delims=|" %%a in ("!_line!") do (
            if "%%e"=="0" (
                set "_newnum=!_map_%%b!"
                echo T^|!_newnum!^|%%c^|%%d^|%%e^|%%f>> "%TEMPFILE%"
            )
        )
    ) else if /i "!_rectype!"=="N" (
        for /f "tokens=1-2* delims=|" %%a in ("!_line!") do (
            set "_newnum=!_map_%%b!"
            if "!_newnum!" neq "" (
                echo N^|!_newnum!^|%%c>> "%TEMPFILE%"
            )
        )
    )
)
move /y "%TEMPFILE%" "%DATAFILE%" >nul
echo Compactacion completada: !_count_done! tarea(s) eliminada(s), !_new_id! tarea(s) renumerada(s).
goto :show_pending

:: ============================================================
:get_now
set "_hh=%time:~0,2%"
if "!_hh:~0,1!"==" " set "_hh=0!_hh:~1,1!"
set "_now=%date:~6,4%%date:~3,2%%date:~0,2%!_hh!%time:~3,2%%time:~6,2%"
goto :eof

:: ============================================================
:end
endlocal
