::[Bat To Exe Converter]
::
::YAwzoRdxOk+EWAnk
::fBw5plQjdG8=
::YAwzuBVtJxjWCl3EqQJgSA==
::ZR4luwNxJguZRRnk
::Yhs/ulQjdF+5
::cxAkpRVqdFKZSDk=
::cBs/ulQjdF+5
::ZR41oxFsdFKZSDk=
::eBoioBt6dFKZSDk=
::cRo6pxp7LAbNWATEpCI=
::egkzugNsPRvcWATEpCI=
::dAsiuh18IRvcCxnZtBJQ
::cRYluBh/LU+EWAnk
::YxY4rhs+aU+JeA==
::cxY6rQJ7JhzQF1fEqQJQ
::ZQ05rAF9IBncCkqN+0xwdVs0
::ZQ05rAF9IAHYFVzEqQJQ
::eg0/rx1wNQPfEVWB+kM9LVsJDGQ=
::fBEirQZwNQPfEVWB+kM9LVsJDGQ=
::cRolqwZ3JBvQF1fEqQJQ
::dhA7uBVwLU+EWDk=
::YQ03rBFzNR3SWATElA==
::dhAmsQZ3MwfNWATElA==
::ZQ0/vhVqMQ3MEVWAtB9wSA==
::Zg8zqx1/OA3MEVWAtB9wSA==
::dhA7pRFwIByZRRnk
::Zh4grVQjdCyDJGyX8VAjFDcESALWLjj6UaYgzO3o5P6IsnExBMYDSIj06oCnD84v+kLLZYIk2XQUndMJbA==
::YB416Ek+ZG8=
::
::
::978f952a14a936cc963da21a135fa983
@ECHO OFF
REM BFCPEOPTIONSTART
REM Advanced BAT to EXE Converter www.BatToExeConverter.com
REM BFCPEEXE=C:\Users\Lodfare\Desktop\PgOPTION\pgOption_V0.1.exe
REM BFCPEICON=C:\Users\Lodfare\Pictures\pgOP.ico
REM BFCPEICONINDEX=-1
REM BFCPEEMBEDDISPLAY=0
REM BFCPEEMBEDDELETE=1
REM BFCPEADMINEXE=0
REM BFCPEINVISEXE=0
REM BFCPEVERINCLUDE=1
REM BFCPEVERVERSION=1.0.0.0
REM BFCPEVERPRODUCT=PgOption
REM BFCPEVERDESC=Migrations databases Postgresql
REM BFCPEVERCOMPANY=Spartan Techs, C.A.
REM BFCPEVERCOPYRIGHT=Copyright 2024
REM BFCPEWINDOWCENTER=1
REM BFCPEDISABLEQE=0
REM BFCPEWINDOWHEIGHT=25
REM BFCPEWINDOWWIDTH=80
REM BFCPEWTITLE=PgOption
REM BFCPEOPTIONEND
@echo off

REM Configuración DEFAULT
set "servidor=localhost"
set "puerto=5432"
set "usuario=postgres"
set "POSTGRES_HOME=C:\Program Files\PostgreSQL\15"
set "PGPASSWORD=caracas"

REM Crear carpeta "db_updates" si no existe
if not exist "db_updates" (
    mkdir "db_updates"
    echo Carpeta "db_updates" creada.
)

REM Crear carpeta "db_backups" si no existe
if not exist "db_backups" (
    mkdir "db_backups"
    echo Carpeta "db_backups" creada.
)

echo ------_----------_----------
echo ------_ pgOptions _---------- 
echo DATABASE POSTGRESQL MIGRATION  
echo VERSION: 1.0                                                                  
echo.
echo Configuracion:
echo HOST: %servidor%
echo PORT: %puerto%
echo USER: %usuario%
echo ROUTE POSTGRESQL: %POSTGRES_HOME%
echo PASSWORD: c*****s
set /p configurar=¿Desea configurar los valores? (s/n):
if /i "%configurar%"=="s" (
cls
echo ------_----------_----------
echo ------_ pgOptions _---------- 
echo DATABASE POSTGRESQL MIGRATION  
echo VERSION: 1.0                                                                  
echo.
  REM Asignar valores por entrada de usuario
  set /p servidor=Ingrese el servidor -host-: 
  set /p puerto=Ingrese el puerto -port-: 
  set /p usuario=Ingrese el usuario -user-: 
  set /p POSTGRES_HOME=Ingrese la ruta de PostgreSQL -route-: 
  set /p PGPASSWORD=Ingrese la contraseña:
  pause
)  

:menu
cls
echo ------_----------_----------
echo ------_ pgOptions _---------- 
echo DATABASE POSTGRESQL MIGRATION  
echo VERSION: 1.0                                                                  
echo.
echo Seleccione una opción:
echo 1. Mostrar todas las bases de datos disponibles en el servidor
echo 2. Realizar una copia de seguridad de todas las bases de datos
echo 3. Realizar una copia de seguridad de una base de datos específica
echo 4. Actualizar una base de datos utilizando un archivo SQL
echo 5. Importar una base de datos desde un archivo backup SQL
echo 6. Restaurar una base de datos apartir de una copia de seguridad
echo 7. Salir
set /p opcion=Ingrese la opción deseada:

if "%opcion%"=="1" goto opcion1
if "%opcion%"=="2" goto opcion2
if "%opcion%"=="3" goto opcion3
if "%opcion%"=="4" goto opcion4
if "%opcion%"=="5" goto opcion5
if "%opcion%"=="6" goto opcion6
if "%opcion%"=="7" goto opcion7

echo Opción inválida. Intente nuevamente.
goto menu

REM Opción 1: Mostrar todas las bases de datos disponibles en el servidor
:opcion1
cls
echo MOSTRANDO LISTA DE BASES DE DATOS EN EL SERVIDOR %servidor% ...
"%POSTGRES_HOME%\bin\psql.exe" -h %servidor% -p %puerto% -U %usuario% -c "\l"
pause
goto menu

REM Opción 2: Realizar una copia de seguridad de todas las bases de datos
:opcion2
cls
echo REALIZANDO UNA COPIA DE SEGURIDAD DE TODAS LAS BASES DE DATOS EN EL SERVIDOR %servidor% ... 
set "archivo_salida=todas_las_bases_de_datos.sql"
"%POSTGRES_HOME%\bin\pg_dumpall.exe" -h %servidor% -p %puerto% -U %usuario% -f %archivo_salida%
echo La copia de seguridad se ha realizado con éxito en %archivo_salida%
pause
goto menu

REM Opción 3: Realizar una copia de seguridad de una base de datos específica
:opcion3
cls
echo REALIZANDO UNA COPIA DE SEGURIDAD EN UNA BASE DE DATOS ESPECIFICA...
set /p nombre_base_datos=Ingrese el nombre de la base de datos a respaldar ('b' para volver):
if /i "%nombre_base_datos%"=="b" (
goto menu
)
set "archivo_salida=%nombre_base_datos%.sql"
"%POSTGRES_HOME%\bin\pg_dump.exe" -h %servidor% -p %puerto% -U %usuario% -F c -b -v -f %archivo_salida% %nombre_base_datos%
echo La copia de seguridad se ha realizado con éxito en %archivo_salida%
pause
goto menu

REM Opción 4: Actualizar una base de datos utilizando un archivo SQL
:opcion4
cls
setlocal EnableDelayedExpansion
echo ACTUALIZACION DE UNA BASE DE DATOS
echo -----SCRIPTS DISPONIBLES---------
set /a count=0
for %%f in (db_updates\*.sql) do (
  set /a count+=1
  echo !count!: %%f
)
echo ---------------------------------
set /p choice=Ingrese el numero del archivo que desea utilizar ('b' para volver):
if /i "%choice%"=="b" (
goto menu
)
set /a index=0
for %%f in (db_updates\*.sql) do (
  set /a index+=1
  if !index! == %choice% (
    set archivo=%%f
    goto ejecutar_actualizacion
  )
)
echo Opcion invalida
:ejecutar_actualizacion
set /p nombre_base_datos=Ingrese el nombre de la base de datos que desea actualizar ('b' para volver):
if /i "%nombre_base_datos%"=="b" (
goto menu
)
"%POSTGRES_HOME%\bin\psql.exe" -h %servidor% -p %puerto% -U %usuario% -d %nombre_base_datos% -f "%archivo%"
echo La actualización se ha realizado con éxito.
set /p reload_op=REALIZAR OTRA ACTUALIZACION? (s/n):
if /i "%reload_op%"=="s" (
goto opcion4
)
pause
goto menu

REM Opción 5: Importar una base de datos desde un archivo backup SQL
:opcion5
cls
echo IMPORTACION DE UNA BASE DE DATOS DESDE UN ARCHIVO 'backup SQL'
set /p nombre_base_datos=Ingrese el nombre de la base de datos a importar ('b' para volver):
if /i "%nombre_base_datos%"=="b" (
goto menu
)
"%POSTGRES_HOME%\bin\createdb.exe" -h %servidor% -p %puerto% -U %usuario% %nombre_base_datos%
echo La base de datos %nombre_base_datos% se ha creado con éxito.
echo Elija una ruta del archivo backup SQL a importar:
setlocal EnableDelayedExpansion

set /a count=0
for %%f in (db_backups\*.sql) do (
  set /a count+=1
  echo !count!: %%f
)
echo ---------------------------------
set /p choice=Ingrese el numero del archivo que desea utilizar ('b' para volver):
if /i "%choice%"=="b" (
goto menu
)
set /a index=0
for %%f in (db_backups\*.sql) do (
  set /a index+=1
  if !index! == %choice% (
    set archivo=%%f
    goto ejecutar_importacion
  )
)
echo Opcion invalida
:ejecutar_importacion
echo ARCHIVO ---ES %archivo%
"%POSTGRES_HOME%\bin\pg_restore.exe" --verbose --clean --no-acl --no-owner -h %servidor% -p %puerto% -U %usuario% -d %nombre_base_datos% "%archivo%"
echo La importación se ha realizado con éxito.
pause
goto menu

REM Opción 6: Restaurar una base de datos a partir de una copia de seguridad
:opcion6
cls
echo RESTAURAR UNA BASE DE DATOS A PARTIR DE UNA COPIA DE SEGURIDAD
set /p nombre_base_datos=Ingrese el nombre de la base de datos que desea restaurar ('b' para volver):
if /i "%nombre_base_datos%"=="b" (
goto menu
)

echo Elija una ruta del archivo backup SQL a restaurar:
setlocal EnableDelayedExpansion

set /a count=0
for %%f in (db_backups\*.sql) do (
  set /a count+=1
  echo !count!: %%f
)
echo ---------------------------------
set /p choice=Ingrese el numero del archivo que desea utilizar ('b' para volver):
if /i "%choice%"=="b" (
goto menu
)
set /a index=0
for %%f in (db_backups\*.sql) do (
  set /a index+=1
  if !index! == %choice% (
    set archivo_backup=%%f
    goto ejecutar_restauracion
  )
)
echo Opcion invalida
:ejecutar_restauracion

REM Guardar copia de seguridad antes de la restauración
echo REALIZANDO COPIA DE SEGURIDAD DE LA BASE DE DATOS '%nombre_base_datos%'...
for /f "tokens=1-3 delims=/ " %%d in ('date /t') do set fecha=%%f%%e%%d
for /f "tokens=1-3 delims=: " %%t in ('time /t') do set hora=%%t%%u%%v
set nombre_copia="%nombre_base_datos%_%fecha%_%hora%.sql"
"%POSTGRES_HOME%\bin\pg_dump.exe" -h %servidor% -p %puerto% -U %usuario% -F c -b -v -f %nombre_copia% %nombre_base_datos%
move nombre_copia db_backups
echo COPIA DE SEGURIDAD REALIZADA CON EXITO! Archivo salida: 'db_backups/%nombre_copia%'
echo ELIMINANDO BASE DE DATOS EXISTENTE...
"%POSTGRES_HOME%\bin\dropdb.exe" -h %servidor% -p %puerto% -U %usuario% %nombre_base_datos%
echo BASE DE DATOS ELIMINADA!
echo Creando Base de datos de restauracion...
"%POSTGRES_HOME%\bin\createdb.exe" -h %servidor% -p %puerto% -U %usuario% %nombre_base_datos%
echo Base de datos creada!
echo EJECUTANDO RESTAURACION...
"%POSTGRES_HOME%\bin\pg_restore.exe" --verbose --clean --no-acl --no-owner -h %servidor% -p %puerto% -U %usuario% -d %nombre_base_datos% "%archivo_backup%"
echo La restauración se ha realizado con éxito.
pause
goto menu


:opcion7
echo SESION TERMINADA
pause

