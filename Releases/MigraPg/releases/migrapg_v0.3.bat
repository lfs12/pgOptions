@echo off

set "config_file=config\config.txt"
set "servidor=Nulo"
set "puerto=Nulo"
set "usuario=Nulo"
set "PGPASSWORD=caracas"
set "db=Nulo"
set "POSTGRES_HOME=Nulo"

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
)

REM Imprimir los valores de configuración
:main
cls
echo ------_----------_----------
echo ------_ MIGRAPG _----------
echo DATABASE POSTGRESQL MIGRATION
echo VERSION: 0.3
echo.
echo Configuracion:
echo HOST: %servidor%
echo PORT: %puerto%
echo USER: %usuario%
echo ROUTE POSTGRESQL: %POSTGRES_HOME%
echo DB: %db%
echo PASSWORD: ********
set /p configurar=¿Desea configurar los valores? (s/n o salir 'b'):
if /i "%configurar%"=="b" exit
if /i "%configurar%"=="s" (
cls
echo ------_----------_----------
echo ------_ MIGRAPG _----------
echo DATABASE POSTGRESQL MIGRATION
echo VERSION: 0.3                                                                
echo.
  REM Asignar valores por entrada de usuario
  echo Presiona 'Enter' si requiere no modificar el valor.
  echo.
  set /p servidor=Ingrese el servidor -host-: 
  set /p puerto=Ingrese el puerto -port-: 
  set /p usuario=Ingrese el usuario -user-: 
  set /p POSTGRES_HOME=Ingrese la ruta de PostgreSQL -route-: 
  set /p db=Ingrese el nombre de la base de datos -db-:
  set /p PGPASSWORD=Ingrese la contraseña:
  pause
)
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
echo PRIMERA ETAPA DE ACTUALIZACION COMPLETADA ---ENTER PARA CONTINUAR--
pause
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
psql -h %host% -U %user% -w -c "SELECT table_name, column_name, data_type,  COALESCE(character_maximum_length, 0) FROM information_schema.columns WHERE table_schema = 'public';" -d %database_desactualizada% > %database_desactualizada%_tables_columns.txt

rem Base de datos Actualizada 
set database_actualizada=basedatos_temporal
psql -h %host% -U %user% -w -c "SELECT table_name, column_name, data_type,  COALESCE(character_maximum_length, 0) FROM information_schema.columns WHERE table_schema = 'public';" -d %database_actualizada% > %database_actualizada%_tables_columns.txt
echo ARCHIVOS GENERADOS EXITOSAMENTE.

set "database_actualizada_tables_columns=%database_actualizada%_tables_columns.txt"
set "database_desactualizada_tables_columns=%database_desactualizada%_tables_columns.txt"

rem Comparacion de esquemas y actualizacion
color 6
echo INICIANDO LA COMPARACION DE ESQUEMAS ESCRITOS EN LOS ARCHIVOS TEMPORALES...

set "total=0"
for /f "tokens=1,2,3,4 delims=|" %%a in ('findstr /C:"|" "%database_actualizada_tables_columns%"') do (
    set /a "total+=1"
)

set "progress=0"
set "add_col=0"
set "add_type_dat=0"
set "add_lenght_val=0"
set "item=Comparando esquema..."

for /f "tokens=1,2,3,4 delims=|" %%a in ('findstr /C:"|" "%database_actualizada_tables_columns%"') do (
    findstr /C:"%%b" "%database_desactualizada_tables_columns%" > nul
    if errorlevel 1 (
        set "item=La columna %%b de la tabla %%a no existe en la base de datos desactualizada."
        psql -h %host% -U %user% -w -d %database_desactualizada% -c "ALTER TABLE %%a ADD COLUMN %%b %%c;"
        set /a "add_col+=1"
    ) else (
        set "item='La columna %%b de la tabla %%a existe en ambas bases de datos'"
        for /f "tokens=1,2,3,4 delims=|" %%e in ('findstr /C:"%%b" "%database_desactualizada_tables_columns%"') do (
            if "%%c" neq "%%g" (
                set "item=El tipo de dato de la columna %%b de la tabla %%a es diferente en ambas bases de datos"
                psql -h %host% -U %user% -w -d %database_desactualizada% -c "ALTER TABLE %%a ALTER COLUMN %%b TYPE %%c;"
                set /a "add_type_dat+=1"
            )
            if "%%d" neq "%%h" (
                set "item=La longitud de la columna %%b de la tabla %%a es diferente en ambas bases de datos"
                psql -h %host% -U %user% -w -d %database_desactualizada% -c "ALTER TABLE %%a ALTER COLUMN %%b TYPE %%c(%%d);"
                set /a "add_lenght_val+=1"
            )
        )
    )
    cls
    set /a "progress+=1"
    set /a "percentage=progress*100/total"
    echo !item!
    echo Columnas agregadas: !add_col!
    echo Tipo de datos modificados: !add_type_dat!
    echo Longitud de valores modificados: !add_lenght_val!
    echo Progreso: !percentage!%%
)
color 6
cls
echo Columnas agregadas: !add_col!
echo Tipo de datos modificados: !add_type_dat!
echo Longitud de valores modificados: !add_lenght_val!
echo Progreso: !percentage!%%
echo COMPARACION DE ESQUEMAS COMPLETADO.
color F
echo SEGUNDA ETAPA DE ACTUALIZACION COMPLETADA EXITOSAMENTE.
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
pause


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