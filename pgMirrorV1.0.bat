@echo off
setlocal enabledelayedexpansion

REM Configuración DEFAULT
set "servidor=localhost"
set "puerto=5432"
set "usuario=postgres"
set "POSTGRES_HOME=C:\Program Files\PostgreSQL\15"
set "PGPASSWORD=caracas"

:MAIN
echo ------_----------_----------
echo ------_ pgReplica _----------
echo REPLICACION POSTGRESQL  
echo VERSION: 2.0
echo.
echo Configuracion Actual:
echo HOST Primario: %servidor%
echo PORT: %puerto%
echo USER: %usuario%
echo Ruta PostgreSQL: %POSTGRES_HOME%
echo PASSWORD: c*****s
echo.

set /p configurar=¿Desea configurar los valores? (s/n): 
if /i "%configurar%"=="s" (
    cls
    echo ------_----------_----------
    echo ------_ Configuracion _----------
    set /p servidor=Ingrese HOST Primario: 
    set /p puerto=Ingrese Puerto [5432]: 
    set /p usuario=Ingrese Usuario Replica [replicador]: 
    set /p POSTGRES_HOME=Ingrese Ruta PostgreSQL [C:\Program Files\PostgreSQL\15]: 
    set /p PGPASSWORD=Ingrese Contraseña: 
    if "!puerto!"=="" set puerto=5432
    if "!usuario!"=="" set usuario=replicador
    if "!POSTGRES_HOME!"=="" set POSTGRES_HOME=C:\Program Files\PostgreSQL\15
)

:MENU
cls
echo ------_----------_----------
echo ------_ pgReplica _----------
echo 1. Configurar Servidor Primario
echo 2. Configurar Servidor Replica
echo 3. Verificar Estado Replicacion
echo 4. Salir
set /p opcion=Seleccione opcion: 

if "%opcion%"=="1" goto CONFIG_PRIMARIO
if "%opcion%"=="2" goto CONFIG_REPLICA
if "%opcion%"=="3" goto VERIFICAR
if "%opcion%"=="4" exit
echo Opción inválida. Intente nuevamente.
goto menu
:CONFIG_PRIMARIO
echo Configurando Primario...
echo Modificando postgresql.conf...
powershell -Command "(Get-Content '%POSTGRES_HOME%\data\postgresql.conf') -replace '#wal_level = replica', 'wal_level = replica' | Set-Content '%POSTGRES_HOME%\data\postgresql.conf'"
powershell -Command "(Get-Content '%POSTGRES_HOME%\data\postgresql.conf') -replace '#max_wal_senders = 10', 'max_wal_senders = 5' | Set-Content '%POSTGRES_HOME%\data\postgresql.conf'"

echo Agregando regla pg_hba.conf...
echo host replication %usuario% %servidor%/32 md5 >> "%POSTGRES_HOME%\data\pg_hba.conf"

echo Creando usuario replicacion...
"%POSTGRES_HOME%\bin\psql" -U postgres -h %servidor% -p %puerto% -c "CREATE USER %usuario% WITH REPLICATION ENCRYPTED PASSWORD '%PGPASSWORD%';"

echo Reiniciando servicio...
net stop postgresql-x64-15
net start postgresql-x64-15
pause
goto MENU

:CONFIG_REPLICA
echo Configurando Replica...
echo Deteniendo PostgreSQL...
net stop postgresql-x64-15

echo Eliminando datos antiguos...
rmdir /S /Q "%POSTGRES_HOME%\data"

echo Realizando backup base...
"%POSTGRES_HOME%\bin\pg_basebackup" -h %servidor% -p %puerto% -U %usuario% -D "%POSTGRES_HOME%\data" -P -R -Xs -C -S replica_1

echo Creando standby.signal...
echo. > "%POSTGRES_HOME%\data\standby.signal"

echo Iniciando servicio...
net start postgresql-x64-15
pause
goto MENU

:VERIFICAR
echo Verificando replicacion...
"%POSTGRES_HOME%\bin\psql" -U postgres -h %servidor% -p %puerto% -c "SELECT client_addr, state, sync_state FROM pg_stat_replication;"
pause
goto MENU