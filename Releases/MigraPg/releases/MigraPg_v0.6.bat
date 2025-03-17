@ECHO OFF
REM BFCPEOPTIONSTART
REM Advanced BAT to EXE Converter www.BatToExeConverter.com
REM BFCPEEXE=C:\Users\Lodfare\Desktop\MigraPg\MigraPg.exe
REM BFCPEICON=C:\Users\Lodfare\Downloads\iconizer-Round (2).ico
REM BFCPEICONINDEX=-1
REM BFCPEEMBEDDISPLAY=0
REM BFCPEEMBEDDELETE=1
REM BFCPEADMINEXE=0
REM BFCPEINVISEXE=0
REM BFCPEVERINCLUDE=1
REM BFCPEVERVERSION=0.6.0.0
REM BFCPEVERPRODUCT=MigraPg
REM BFCPEVERDESC=Postgresql Database Migrations
REM BFCPEVERCOMPANY=Spartan Tech
REM BFCPEVERCOPYRIGHT=Spartan Tech, 2023
REM BFCPEWINDOWCENTER=1
REM BFCPEDISABLEQE=0
REM BFCPEWINDOWHEIGHT=25
REM BFCPEWINDOWWIDTH=80
REM BFCPEWTITLE=MigraPg
REM BFCPEOPTIONEND
@echo off

set "config_file=config\config.txt"
set "servidor=Nulo"
set "puerto=Nulo"
set "usuario=Nulo"
set "PGPASSWORD=Nulo"
set "db=Nulo"
set "POSTGRES_HOME=Nulo"
set "error_file=false"

REM Verificar si el archivo de configuración existe
if not exist "%config_file%" (
  echo El archivo de configuración no existe.
  pause
  exit /b
)

REM Leer el archivo de configuración
for /f "usebackq tokens=1,2 delims==" %%a in ("%config_file%") do (
  if /i "%%a"=="HOST" set "servidor=%%~b"
  if /i "%%a"=="PORT" set "puerto=%%~b"
  if /i "%%a"=="USER" set "usuario=%%~b"
  if /i "%%a"=="PASSWORD" set "PGPASSWORD=%%~b"
  if /i "%%a"=="DB" set "db=%%~b"
  if /i "%%a"=="DIR" set "POSTGRES_HOME=%%~b"
  if /i "%%a"=="Nulo" set "error_file=true"
)
  
REM Verificar si alguna condición falló
for /f "usebackq tokens=1,2 delims==" %%a in ("%config_file%") do (
  if /i "%servidor%"=="Nulo" set "error_file=true"
  if /i "%puerto%"=="Nulo" set "error_file=true"
  if /i "%usuario%"=="Nulo" set "error_file=true"
  if /i "%PGPASSWORD%"=="Nulo" set "error_file=true"
  if /i "%db%"=="Nulo" set "error_file=true"
  if /i "%POSTGRES_HOME%"=="Nulo" set "error_file=true"
)

if "%error_file%" == "true" (
    color 4
    echo ===== EL ARCHIVO DE CONFIGURACION 'config.txt' NO ES VALIDO ======
    pause
    exit /b   
)

setx PATH "%PATH%;%POSTGRES_HOME%\bin\"

REM Imprimir los valores de configuración
:main
cls
echo ------_----------_----------
echo ------_ MIGRAPG _----------
echo DATABASE POSTGRESQL MIGRATION
echo VERSION: 0.6
echo.
echo Configuracion:
echo HOST: %servidor%
echo PORT: %puerto%
echo USER: %usuario%
echo ROUTE POSTGRESQL: %POSTGRES_HOME%
echo DB: %db%
echo PASSWORD: ********
set /p keybord='ENTER' PARA CONTINUAR (O 'b' PARA SALIR):
if /i "%keybord%" == "b" (
 echo SESION TERMINADA
 exit
)

REM Validar existencia de la Base de Datos Desactualizada
psql -U %usuario% -d %db% -c "SELECT 1" 2>nul || (echo LA BASE DE DATOS ----= %db% =----- NO EXISTE. & color 4 & pause & exit /b)

cls
setlocal EnableDelayedExpansion
REM Seleccionar la Base de datos actualizada
echo OPERACION DE ACTUALIZACION DE '%db%'
echo.
echo SELECCIONA LA BASE DATOS ACTUALIZADA:
set /a count=0
for %%f in (db_updated\*.sql) do (
  set /a count+=1
  echo !count!: %%f
)
echo --------------------
set /p choice=Archivo a utilizar ('b' para volver):
if /i "%choice%" == "b" (
 goto main
)
set /a index=0
for %%f in (db_updated\*.sql) do (
    set /a index+=1
	if !index! == %choice% (
	 set "updated_db=%%f"
	 goto ejecutar_actualizacion
	)
)
echo Opcion invalida
:ejecutar_actualizacion
REM Obtener todos los valores sin Actualizacion
    set "a_numero_tablas="
    for /f "delims=" %%i in ('psql -h %servidor% -p %puerto% -U %usuario% -t -c "SELECT count(*) FROM information_schema.tables WHERE table_schema = 'public'" %db%') do set "a_numero_tablas=%%i"
	set "a_numero_triggers="
    for /f "delims=" %%i in ('psql -h %servidor% -p %puerto% -U %usuario% -t -c "SELECT count(*) FROM pg_trigger WHERE NOT tgisinternal" %db%') do set "a_numero_triggers=%%i"
	set "a_numero_vistas="
    for /f "delims=" %%i in ('psql -h %servidor% -p %puerto% -U %usuario% -t -c "SELECT count(*) FROM information_schema.views WHERE table_schema = 'public'" %db%') do set "a_numero_vistas=%%i"
	set "a_numero_funciones="
    for /f "delims=" %%i in ('psql -h %servidor% -p %puerto% -U %usuario% -t -c "SELECT count(*) FROM pg_proc WHERE pronamespace = (SELECT oid FROM pg_namespace WHERE nspname = 'public')" %db%') do set "a_numero_funciones=%%i"
	set "a_numero_indices="
    for /f "delims=" %%i in ('psql -h %servidor% -p %puerto% -U %usuario% -t -c "SELECT count(*) FROM pg_indexes WHERE schemaname = 'public'" %db%') do set "a_numero_indices=%%i"
	
set "target_db=%db%"

REM Generar un archivo SQL con las diferencias entre las bases de datos
pg_dump -U %usuario% -s -f temp.sql %target_db%

fc %updated_db% temp.sql > nul
if %errorlevel% equ 0 (
    echo Las estructuras de las bases de datos son idénticas.
    del temp.sql
    goto :end
) else (
    echo Las estructuras de las bases de datos son diferentes.
)

echo.
echo Actualizando la base de datos...


REM PRIMERA ETAPA DE ACTUALIZACION
cls
echo INICIANDO PRIMERA ETAPA DE ACTUALIZACION...
pg_restore -U %usuario% -d %target_db% %updated_db%
echo.
echo. --No cierre el programa para continuar la actualizacion--
echo. ===================================================================
echo PRIMERA ETAPA DE ACTUALIZACION COMPLETADA ---ENTER PARA CONTINUAR--
echo ====================================================================
echo.
REM FIN DE PRIMERA DE ACTUALIZACION

REM SEGUNDA ETAPA DE ACTUALIZACION
cls
echo INICIANDO SEGUNDA ETAPA DE ACTUALIZACION... --NO CIERRE EL PROGRAMA---
echo Creando una base de datos temporal...
"%POSTGRES_HOME%\bin\createdb.exe" -h %servidor% -p %puerto% -U %usuario% basedatos_temporal
echo Base de datos temporal creada.
echo Importando la base de datos actualizada...
"%POSTGRES_HOME%\bin\pg_restore.exe" --verbose --clean --no-acl --no-owner -h %servidor% -p %puerto% -U %usuario% -d basedatos_temporal "%updated_db%" 
echo Importada la base de datos temporal.

set host=%servidor% 
set user=%usuario%

echo GENERANDO ARCHVOS TEMPORALES CON LOS ESQUEMAS DE LA BD 'ACTUALIZADA' Y DB 'DESACTUALIZADA'...
rem Base de datos Desactualizada 
set database_desactualizada=%target_db%
psql -h %host% -U %user% -w -c "SELECT table_name, column_name, data_type,  COALESCE(character_maximum_length, 0), COALESCE(column_default, 'NULL') FROM information_schema.columns WHERE table_schema = 'public';" -d %database_desactualizada% > %database_desactualizada%_tables_columns.txt

rem Base de datos Actualizada 
set database_actualizada=basedatos_temporal
psql -h %host% -U %user% -w -c "SELECT table_name, column_name, data_type,  COALESCE(character_maximum_length, 0), COALESCE(column_default, 'NULL') FROM information_schema.columns WHERE table_schema = 'public';" -d %database_actualizada% > %database_actualizada%_tables_columns.txt
echo ARCHIVOS GENERADOS EXITOSAMENTE.

set "database_actualizada_tables_columns=%database_actualizada%_tables_columns.txt"
set "database_desactualizada_tables_columns=%database_desactualizada%_tables_columns.txt"

rem Comparacion de esquemas y actualizacion
color 6
echo INICIANDO LA COMPARACION DE ESQUEMAS ESCRITOS EN LOS ARCHIVOS TEMPORALES...

set "total=0"
for /f "tokens=1,2,3,4,5 delims=|" %%a in ('findstr /C:"|" "%database_actualizada_tables_columns%"') do (
    set /a "total+=1"
)

set "progress=0"
set "add_col=0"
set "add_type_dat=0"
set "add_lenght_val=0"
set "item=Comparando esquema..."

for /f "tokens=1,2,3,4,5 delims=|" %%a in ('findstr /C:"|" "%database_actualizada_tables_columns%"') do (
    findstr /C:"%%b" "%database_desactualizada_tables_columns%" > nul
    if errorlevel 1 (
        set "item=La columna %%b de la tabla %%a no existe en la base de datos desactualizada."
        psql -h %host% -U %user% -w -d %database_desactualizada% -c "ALTER TABLE %%a ADD COLUMN %%b %%c;"
        set /a "add_col+=1"
    ) else (  
        set "item='La columna %%b de la tabla %%a existe en ambas bases de datos'"
        for /f "tokens=1,2,3,4,5 delims=|" %%f in ('findstr /C:"%%b" "%database_desactualizada_tables_columns%"') do (
            if "%%c" neq "%%h" (
                set "item=El tipo de dato de la columna %%b de la tabla %%a es diferente en ambas bases de datos"
                psql -h %host% -U %user% -w -d %database_desactualizada% -c "ALTER TABLE %%a ALTER COLUMN %%b TYPE %%c;"
                set /a "add_type_dat+=1"
            )
            if "%%d" neq "%%i" (
                set "item=La longitud de la columna %%b de la tabla %%a es diferente en ambas bases de datos"
                psql -h %host% -U %user% -w -d %database_desactualizada% -c "ALTER TABLE %%a ALTER COLUMN %%b TYPE %%c(%%d);"
                set /a "add_lenght_val+=1"
            )
            if "%%e" neq "%%j" (
                set "item=El valor por defecto en la columna %%b de la tabla %%a es diferente en ambas bases de datos"
                psql -h %host% -U %user% -w -d %database_desactualizada% -c "ALTER TABLE %%a ALTER COLUMN %%b SET DEFAULT %%e"  
            )
        )
    )
    cls
    echo COMPARANDO ESQUEMAS Y ACTUALIZANDO %target_db% POR FAVOR ESPERE --'click para pausar'/'enter para continuar'--
    echo.

    set /a "progress+=1"
    set /a "percentage=progress*100/total"

    echo ESTADO:
    echo ===========================
    echo !item!
    echo ===========================
    echo Columnas agregadas: !add_col!
    echo Tipo de datos modificados: !add_type_dat!
    echo Longitud de valores modificados: !add_lenght_val!
    echo =============================
    echo PROGRESO: -------------------============ !percentage!%% ============--------------------------
    echo =============================
)
color 6
cls
echo. --No cierre el programa para continuar con la tabla de resultados--
echo Columnas agregadas: !add_col!
echo Tipo de datos modificados: !add_type_dat!
echo Longitud de valores modificados: !add_lenght_val!
echo =============================
echo PROGRESO: -------------------============ !percentage!%% ============--------------------------
echo =============================
echo COMPARACION DE ESQUEMAS COMPLETADO.
color F
echo SEGUNDA ETAPA DE ACTUALIZACION COMPLETADA EXITOSAMENTE.
echo.
REM FIN SEGUNDA ETAPA DE ACTUALIZACION

REM Obtener todos los valores con Actualizacion
    set "b_numero_tablas="
    for /f "delims=" %%i in ('psql -h %servidor% -p %puerto% -U %usuario% -t -c "SELECT count(*) FROM information_schema.tables WHERE table_schema = 'public'" %db%') do set "b_numero_tablas=%%i"
	set "b_numero_triggers="
    for /f "delims=" %%i in ('psql -h %servidor% -p %puerto% -U %usuario% -t -c "SELECT count(*) FROM pg_trigger WHERE NOT tgisinternal" %db%') do set "b_numero_triggers=%%i"
	set "b_numero_vistas="
    for /f "delims=" %%i in ('psql -h %servidor% -p %puerto% -U %usuario% -t -c "SELECT count(*) FROM information_schema.views WHERE table_schema = 'public'" %db%') do set "b_numero_vistas=%%i"
	set "b_numero_funciones="
    for /f "delims=" %%i in ('psql -h %servidor% -p %puerto% -U %usuario% -t -c "SELECT count(*) FROM pg_proc WHERE pronamespace = (SELECT oid FROM pg_namespace WHERE nspname = 'public')" %db%') do set "b_numero_funciones=%%i"
	set "b_numero_indices="
    for /f "delims=" %%i in ('psql -h %servidor% -p %puerto% -U %usuario% -t -c "SELECT count(*) FROM pg_indexes WHERE schemaname = 'public'" %db%') do set "b_numero_indices=%%i"
	
echo.
echo Actualización completada.

cls
REM Crear una tabla formateada para comparar los valores
echo.
echo ACTUALIZACION DE LA BASE DATOS '%db%':
echo.
echo "="
echo "= %db% SIN ACTUALIZAR***
echo "=============================================================================="
echo "= Tablas     =   !a_numero_tablas! 
echo "= Triggers   =   !a_numero_triggers!              
echo "= Vistas     =   !a_numero_vistas!                 
echo "= Funciones  =   !a_numero_funciones!   
echo "= Indices    =   !a_numero_indices!          
echo "=============================================================================="
echo "="
echo "= %db% ACTUALIZADA
echo "=============================================================================="
echo "= Tablas     =   !b_numero_tablas! 
echo "= Triggers   =   !b_numero_triggers!              
echo "= Vistas     =   !b_numero_vistas!                 
echo "= Funciones  =   !b_numero_funciones!   
echo "= Indices    =   !b_numero_indices!          
echo "=============================================================================="

set /a "numero_tablas=b_numero_tablas-a_numero_tablas"
set /a "numero_triggers=b_numero_triggers-a_numero_triggers"
set /a "numero_vistas=b_numero_vistas-a_numero_vistas"
set /a "numero_funciones=b_numero_funciones-a_numero_funciones"
set /a "numero_indices=b_numero_indices-a_numero_indices"

echo "="
echo "= %db% ELEMENTOS AGREGADOS
echo "=============================================================================="
echo "= Tablas     =   !numero_tablas! 
echo "= Columnas   =   !add_col!
echo "= Triggers   =   !numero_triggers!              
echo "= Vistas     =   !numero_vistas!                 
echo "= Funciones  =   !numero_funciones!   
echo "= Indices    =   !numero_indices!          
echo "=============================================================================="
REM Archivo de backup
for /f "tokens=1-3 delims=/ " %%d in ('date /t') do set fecha=%%f%%e%%d
for /f "tokens=1-3 delims=: " %%t in ('time /t') do set hora=%%t%%u%%v
set respaldo_file="%db%_%fecha%_%hora%.sql"

ren "temp.sql" "%respaldo_file%" 
move %respaldo_file% respaldos

echo ELIMINANDO DATOS TEMPORALES...
REM Cerrar sesión de la base de datos
REM psql -h %servidor% -p %puerto% -U %usuario% -d basedatos_temporal -c "SELECT pg_terminate_backend(pg_stat_activity.pid) FROM pg_stat_activity WHERE pg_stat_activity.datname = 'basedatos_temporal';"
REM Eliminar la base de datos
psql -h %servidor% -p %puerto% -U %usuario% -c "DROP DATABASE basedatos_temporal;"
del %database_actualizada_tables_columns%
del %database_desactualizada_tables_columns%
echo SESION FINALIZADA.

endlocal
pause
goto main
exit