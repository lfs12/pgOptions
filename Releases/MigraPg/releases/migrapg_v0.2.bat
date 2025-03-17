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
echo VERSION: 0.2
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
echo VERSION: 0.2                                                                
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

REM Actualizar la base de datos 1 con las diferencias encontradas
pg_restore -U %usuario% -d %target_db% %updated_db%
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
endlocal
pause
goto main
exit