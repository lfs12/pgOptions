@echo off

setlocal enabledelayedexpansion
@echo off

@echo off
echo ------_----------_----------
echo ------_ POSTESAY _---------- 
echo DATABASE POSTGRESQL MIGRATION  
echo VERSION: 0.0.0.2                                                                  
echo.

rem Reescribir el contenido del archivo en una sola linea sin los comentarios
start write_one_line.bat
echo "El archivo migracion.sql se ha reescrito en una sola linea sin comentarios. El resultado se encuentra en migracion_una_linea.sql."

rem Preguntar al técnico las variables de configuración de la base de datos
set /p DB_HOST=Ingrese el nombre del servidor de la base de datos (HOST):
set /p DB_PORT=Ingrese el numero de puerto de la base de datos (PORT):
set /p DB_NAME=Ingrese el nombre de la base de datos (DB):
set /p DB_USER=Ingrese el nombre de usuario de la base de datos (USER):

rem Obtener la ruta de instalación de PostgreSQL
set /p POSTGRES_HOME=Ingrese la ruta de instalacion de PostgreSQL (por ejemplo, C:\Program Files\PostgreSQL\13):

set SCRIPT_FILE=migracion_una_linea.sql

rem Obtener la versión actual de PostgreSQL instalada
for /f "tokens=2 delims=." %%a in ('"%POSTGRES_HOME%\bin\psql.exe" --version') do set PG_VERSION=%%a

rem Leer el archivo de migración y ejecutar los comandos SQL en orden
for /f "tokens=*" %%a in (%SCRIPT_FILE%) do (
  set SQL_COMMAND=%%a
  if "!SQL_COMMAND:~0,2!"=="--" (
    echo Ignorando comentario: !SQL_COMMAND!
  ) else (
    echo Ejecutando comando: !SQL_COMMAND!
    "%POSTGRES_HOME%\bin\psql.exe" -h !DB_HOST! -p !DB_PORT! -U !DB_USER! -d !DB_NAME! -c "!SQL_COMMAND!"
  )
)
echo OPERACION DE MIGRACION TERMINADA!
pause
endlocal
