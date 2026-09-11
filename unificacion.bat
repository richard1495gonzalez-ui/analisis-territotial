@echo off
setlocal EnableDelayedExpansion
:: ==============================================================================
:: AUTOMATIZACION TOTAL: ENTORNO, DOCKER, JUPYTER Y MVC - ANALISIS TERRITORIAL
:: Version portable: funciona en cualquier PC, en cualquier carpeta, sin XAMPP.
:: Requisitos en la maquina donde se ejecute: Docker Desktop y Python 3.
:: ==============================================================================

:: 0. Ubicarse SIEMPRE en la carpeta donde esta este .bat (portable a cualquier PC)
cd /d "%~dp0"
set PATH=%PATH%;C:\Windows\system32;C:\Windows;C:\Windows\System32\Wbem;C:\Windows\System32\WindowsPowerShell\v1.0\
cls
echo ==============================================================================
echo        INICIANDO AUTOMATIZACION INTEGRAL: ANALISIS TERRITORIAL
echo        Carpeta de trabajo: %cd%
echo ==============================================================================
echo.

:: ------------------------------------------------------------------------------
:: [0/8] Verificacion de requisitos (Docker y Python)
:: ------------------------------------------------------------------------------
echo === [0/8] Verificando requisitos del sistema...

where docker >nul 2>&1
if errorlevel 1 (
    echo.
    echo [ERROR] No se encontro Docker en este equipo.
    echo         Instala Docker Desktop desde https://www.docker.com/products/docker-desktop/
    echo         y vuelve a ejecutar este archivo.
    echo.
    pause
    exit /b 1
)

set "DC=docker compose"
%DC% version >nul 2>&1
if errorlevel 1 (
    set "DC=docker-compose"
    %DC% version >nul 2>&1
    if errorlevel 1 (
        echo [ERROR] Docker esta instalado pero no se encontro "docker compose".
        echo         Actualiza Docker Desktop a una version reciente.
        pause
        exit /b 1
    )
)

echo    [+] Comprobando que Docker Desktop este encendido...
set /a _tries=0
:check_docker_running
docker info >nul 2>&1
if errorlevel 1 (
    set /a _tries+=1
    if !_tries! geq 30 (
        echo.
        echo [ERROR] Docker Desktop no esta corriendo despues de esperar 60 segundos.
        echo         Abre Docker Desktop manualmente, espera a que diga "Running"
        echo         y vuelve a ejecutar este .bat
        echo.
        pause
        exit /b 1
    )
    echo    [i] Docker Desktop se esta iniciando, esperando... ^(!_tries!/30^)
    timeout /t 2 >nul
    goto check_docker_running
)
echo    [+] Docker OK.

set "PY=python"
where python >nul 2>&1
if errorlevel 1 (
    where py >nul 2>&1
    if errorlevel 1 (
        echo.
        echo [ERROR] No se encontro Python en este equipo.
        echo         Instala Python 3 desde https://www.python.org/downloads/
        echo         marcando la opcion "Add python.exe to PATH" durante la instalacion.
        echo.
        pause
        exit /b 1
    )
    set "PY=py"
)
echo    [+] Python OK.
echo.

:: ------------------------------------------------------------------------------
:: [1/8] Generacion de Estructura de Arquitectura (MVC + Notebooks + Datasets)
:: ------------------------------------------------------------------------------
echo === [1/8] Comprobando y generando estructura del proyecto (MVC + Jupyter)...
if not exist "venv" mkdir "venv"
if not exist "notebooks" mkdir "notebooks"
if not exist "src" mkdir "src"
if not exist "src\model" mkdir "src\model"
if not exist "src\list" mkdir "src\list"
if not exist "src\controller" mkdir "src\controller"
if not exist "src\view" mkdir "src\view"
if not exist "src\parsistance" mkdir "src\parsistance"
if not exist "src\datasets" mkdir "src\datasets"
if not exist ".docker" mkdir ".docker"

if not exist "notebooks\ppythonPrueba.ipynb" (
    echo {"cells":[],"metadata":{},"nbformat":4,"nbformat_minor":2} > "notebooks\ppythonPrueba.ipynb"
)

if exist "src\model\model.py" goto check_list
echo    [+] Generando plantilla de Modelo...
> src\model\model.py         echo import mysql.connector
>> src\model\model.py        echo.
>> src\model\model.py        echo class Model:
>> src\model\model.py        echo     def __init__(self, host="127.0.0.1", user="root", password="", database="analisis_territorial"):
>> src\model\model.py        echo         self.host = host
>> src\model\model.py        echo         self.user = user
>> src\model\model.py        echo         self.password = password
>> src\model\model.py        echo         self.database = database
>> src\model\model.py        echo.
>> src\model\model.py        echo     def get_duplicate_municipalities(self):
>> src\model\model.py        echo         connection = mysql.connector.connect(
>> src\model\model.py        echo             host=self.host,
>> src\model\model.py        echo             user=self.user,
>> src\model\model.py        echo             password=self.password,
>> src\model\model.py        echo             database=self.database
>> src\model\model.py        echo         )
>> src\model\model.py        echo         cursor = connection.cursor(dictionary=True)
>> src\model\model.py        echo         query = """
>> src\model\model.py        echo         SELECT
>> src\model\model.py        echo             m.Nombre AS municipio,
>> src\model\model.py        echo             GROUP_CONCAT(
>> src\model\model.py        echo                 DISTINCT d.Nombre
>> src\model\model.py        echo                 ORDER BY d.Nombre
>> src\model\model.py        echo                 SEPARATOR ', '
>> src\model\model.py        echo             ) AS departamentos,
>> src\model\model.py        echo             COUNT(*) AS cantidad
>> src\model\model.py        echo         FROM municipio m
>> src\model\model.py        echo         JOIN departamento d
>> src\model\model.py        echo             ON m.Id_departamento = d.Id_departamento
>> src\model\model.py        echo         GROUP BY m.Nombre
>> src\model\model.py        echo         HAVING COUNT(*) ^> 1
>> src\model\model.py        echo         ORDER BY m.Nombre;
>> src\model\model.py        echo         """
>> src\model\model.py        echo         cursor.execute(query)
>> src\model\model.py        echo         results = cursor.fetchall()
>> src\model\model.py        echo         cursor.close()
>> src\model\model.py        echo         connection.close()
>> src\model\model.py        echo         return results

:check_list
if exist "src\list\list.py" goto check_controller
echo    [+] Generando plantilla de Vista...
> src\list\list.py           echo class ListView:
>> src\list\list.py          echo     @staticmethod
>> src\list\list.py          echo     def display_duplicates(duplicates):
>> src\list\list.py          echo         print("\n=== MUNICIPIOS DUPLICADOS (CON MAS DE UN DEPARTAMENTO) ===")
>> src\list\list.py          echo         print(f"{'Municipio':<30} ^| {'Departamentos':<70} ^| {'Cantidad':<10}")
>> src\list\list.py          echo         print("-" * 118)
>> src\list\list.py          echo         for row in duplicates:
>> src\list\list.py          echo             print(f"{row['municipio']:<30} ^| {row['departamentos']:<70} ^| {row['cantidad']:<10}")
>> src\list\list.py          echo         print(f"\nTotal de municipios repetidos encontrados: {len(duplicates)}\n")

:check_controller
if exist "src\controller\controller.py" goto check_main
echo    [+] Generando plantilla de Controlador...
> src\controller\controller.py  echo from src.model.model import Model
>> src\controller\controller.py echo from src.list.list import ListView
>> src\controller\controller.py echo.
>> src\controller\controller.py echo class Controller:
>> src\controller\controller.py echo     def __init__(self):
>> src\controller\controller.py echo         self.model = Model()
>> src\controller\controller.py echo         self.view = ListView()
>> src\controller\controller.py echo.
>> src\controller\controller.py echo     def run(self):
>> src\controller\controller.py echo         try:
>> src\controller\controller.py echo             results = self.model.get_duplicate_municipalities()
>> src\controller\controller.py echo             self.view.display_duplicates(results)
>> src\controller\controller.py echo         except Exception as e:
>> src\controller\controller.py echo             print(f"Error al ejecutar el controlador: {e}")

:check_main
if exist "main.py" goto end_structure
echo    [+] Generando archivo ejecutable principal main.py...
> main.py   echo from src.controller.controller import Controller
>> main.py  echo.
>> main.py  echo if __name__ == "__main__":
>> main.py  echo     print("Iniciando la aplicacion Analisis Territorial...")
>> main.py  echo     controller = Controller()
>> main.py  echo     controller.run()

:end_structure
echo.

:: ------------------------------------------------------------------------------
:: [2/8] Entorno Virtual de Python y dependencias
:: ------------------------------------------------------------------------------
echo === [2/8] Gestionando Entorno Virtual (venv) y Dependencias...
if not exist "venv\Scripts\python.exe" (
    echo    [+] Creando entorno virtual venv...
    %PY% -m venv venv
) else (
    echo    [i] Entorno virtual existente detectado.
)

echo    [+] Instalando dependencias (mysql-connector-python, pandas, jupyter, ipykernel)...
echo        Esto puede tardar varios minutos la primera vez. Se mostrara el avance real:
venv\Scripts\python.exe -m pip install --upgrade pip
venv\Scripts\pip.exe install mysql-connector-python pandas jupyter ipykernel
if errorlevel 1 (
    echo [ERROR] Fallo la instalacion de dependencias de Python. Revisa tu conexion a internet.
    pause
    exit /b 1
)

echo    [+] Registrando entorno virtual como Kernel de Jupyter...
venv\Scripts\python.exe -m ipykernel install --user --name=venv --display-name "Python (venv)" >nul 2>&1
echo.

:: ------------------------------------------------------------------------------
:: [3/8] Infraestructura Docker (docker-compose.yml con puerto auto-detectado)
:: ------------------------------------------------------------------------------
echo === [3/8] Preparando infraestructura Docker...

set "MYSQL_HOST_PORT="
set "_prevport="
if exist ".docker\mysql_port.txt" (
    for /f "usebackq delims=" %%L in (".docker\mysql_port.txt") do set "_prevport=%%L"
)

if defined _prevport (
    echo    [i] Ultimo puerto que funciono: !_prevport!. Probando primero con ese...
    call :try_mysql_port "!_prevport!"
)
if not defined MYSQL_HOST_PORT call :try_mysql_port 3306
if not defined MYSQL_HOST_PORT call :try_mysql_port 3307
if not defined MYSQL_HOST_PORT call :try_mysql_port 3308
if not defined MYSQL_HOST_PORT call :try_mysql_port 3309
if not defined MYSQL_HOST_PORT call :try_mysql_port 3310

if not defined MYSQL_HOST_PORT (
    echo.
    echo [ERROR] No se pudo levantar el contenedor de MySQL en ninguno de los
    echo         puertos probados ^(3306, 3307, 3308, 3309, 3310^). Revisa si tienes
    echo         demasiados servicios usando esos puertos, o consulta el mensaje
    echo         de Docker mostrado arriba.
    echo.
    pause
    exit /b 1
)

echo    [+] MySQL quedo publicado en el puerto !MYSQL_HOST_PORT! del equipo.
> ".docker\mysql_port.txt" echo !MYSQL_HOST_PORT!
echo.

:: ------------------------------------------------------------------------------
:: [4/8] Espera de MySQL
:: ------------------------------------------------------------------------------
echo === [4/8] Esperando a que el servicio MySQL de Docker este listo...
call :wait_for_db
if errorlevel 1 (
    echo.
    echo    [i] MySQL no respondio a tiempo. Revisando si es un volumen de datos
    echo        incompatible ^(config antigua de lower_case_table_names^)...
    %DC% logs db 2>nul | findstr /i "lower_case_table_names" >nul
    if not errorlevel 1 (
        echo    [i] Confirmado: el volumen de datos quedo de una corrida anterior con
        echo        una configuracion incompatible. Se eliminara y se recreara limpio
        echo        ^(no se pierde nada, el CSV se recarga siempre^)...
        %DC% down -v
        %DC% up -d
        if errorlevel 1 (
            echo [ERROR] No se pudo volver a levantar el contenedor tras limpiar el volumen.
            pause
            exit /b 1
        )
        call :wait_for_db
        if errorlevel 1 (
            echo [ERROR] MySQL sigue sin responder incluso con el volumen limpio.
            echo         Salida de "docker compose logs db":
            echo ------------------------------------------------------------------------------
            %DC% logs db --tail=80
            echo ------------------------------------------------------------------------------
            pause
            exit /b 1
        )
    ) else (
        echo [ERROR] MySQL no respondio despues de 2 minutos. Salida de
        echo         "docker compose logs db" ^(causa real del fallo^):
        echo ------------------------------------------------------------------------------
        %DC% logs db --tail=80
        echo ------------------------------------------------------------------------------
        pause
        exit /b 1
    )
)
echo    [+] MySQL se encuentra activo y respondiendo consultas!
echo.

:: ------------------------------------------------------------------------------
:: [5/8] Creacion de la base de datos (Crear base de datos.sql, sin modificar)
:: ------------------------------------------------------------------------------
echo === [5/8] Ejecutando Creacion de base de datos...
if not exist "Crear base de datos.sql" (
    echo [ERROR] No se encontro "Crear base de datos.sql" en esta carpeta.
    pause
    exit /b 1
)
call :run_sql_retry "Crear base de datos.sql" "" "Crear base de datos.sql"
if errorlevel 1 exit /b 1
echo.

:: ------------------------------------------------------------------------------
:: [6/8] Cargue de datos (usa una copia temporal con la ruta del CSV adaptada
::        al contenedor, el archivo original "Cargue de datos.sql" NO se toca)
:: ------------------------------------------------------------------------------
echo === [6/8] Ejecutando Cargue de datos...
if not exist "Cargue de datos.sql" (
    echo [ERROR] No se encontro "Cargue de datos.sql" en esta carpeta.
    pause
    exit /b 1
)

> ".docker\patch_csv_path.ps1" echo $origen = 'C:/xampp/mysql/Taller_Municipios/municipios.csv'
>> ".docker\patch_csv_path.ps1" echo $destino = '/csv-data/municipios.csv'
>> ".docker\patch_csv_path.ps1" echo $c = Get-Content -Raw -Encoding UTF8 'Cargue de datos.sql'
>> ".docker\patch_csv_path.ps1" echo $c = $c.Replace($origen, $destino)
>> ".docker\patch_csv_path.ps1" echo $utf8 = New-Object System.Text.UTF8Encoding $false
>> ".docker\patch_csv_path.ps1" echo [System.IO.File]::WriteAllText('.docker\Cargue_docker.sql', $c, $utf8)

powershell -NoProfile -ExecutionPolicy Bypass -File ".docker\patch_csv_path.ps1"
if errorlevel 1 (
    echo [ERROR] No se pudo preparar "Cargue de datos.sql" para su ejecucion.
    pause
    exit /b 1
)

call :run_sql_retry ".docker\Cargue_docker.sql" "--local-infile=1" "Cargue de datos.sql"
if errorlevel 1 exit /b 1
echo.

:: ------------------------------------------------------------------------------
:: [7/8] Consultas.sql directamente en consola
:: ------------------------------------------------------------------------------
echo === [7/8] Ejecutando Consultas.sql ...
echo ------------------------------------------------------------------------------
if exist "Consultas.sql" (
    call :run_sql_retry "Consultas.sql" "analisis_territorial" "Consultas.sql"
    if errorlevel 1 exit /b 1
)
echo ------------------------------------------------------------------------------
echo.

:: ------------------------------------------------------------------------------
:: [8/8] Apertura de herramientas y ejecucion final de la app MVC
:: ------------------------------------------------------------------------------
echo === [8/8] Apertura de herramientas y Ejecucion Final ===
where code >nul 2>&1
if errorlevel 1 (
    echo    [i] Visual Studio Code ^(comando "code"^) no esta disponible en el PATH, se omite.
) else (
    echo    [+] Abriendo Visual Studio Code...
    start "" code .
)

echo    [+] Ejecutando programa principal Python MVC desde el entorno virtual...
echo.
venv\Scripts\python.exe main.py
echo.
echo ==============================================================================
echo                    PROCESO COMPLETADO EXITOSAMENTE
echo ==============================================================================
echo.

:: ------------------------------------------------------------------------------
:: Menu de consultas adicionales (para no tener que repetir todo el proceso)
:: ------------------------------------------------------------------------------
:menu
echo --------------------------------------------------------------
echo  ¿Que deseas hacer ahora?
echo   [1] Volver a ejecutar Consultas.sql
echo   [2] Escribir una consulta SQL personalizada
echo   [3] Abrir una consola interactiva de MySQL
echo   [4] Salir
echo --------------------------------------------------------------
set /p "_opt=Elige una opcion (1-4): "

if "%_opt%"=="1" (
    call :run_sql_retry "Consultas.sql" "analisis_territorial" "Consultas.sql"
    echo.
    goto menu
)
if "%_opt%"=="2" (
    set "_q="
    set /p "_q=Escribe tu consulta SQL: "
    if not "!_q!"=="" (
        %DC% exec -T db mysql -uroot analisis_territorial -e "!_q!"
    )
    echo.
    goto menu
)
if "%_opt%"=="3" (
    echo Escribe "exit" o "\q" para salir de la consola de MySQL y volver al menu.
    %DC% exec -it db mysql -uroot analisis_territorial
    echo.
    goto menu
)
if "%_opt%"=="4" (
    goto fin
)
echo Opcion no valida.
goto menu

:fin
echo.
echo Hasta luego.
endlocal
pause
exit /b 0

:: ==============================================================================
:: SUBRUTINAS
:: ==============================================================================

:: Recibe un numero de puerto, reescribe docker-compose.yml con ese puerto,
:: y trata de levantar el contenedor. Si funciona, expone MYSQL_HOST_PORT
:: al script que hizo el "call". Si falla, no define nada (se sigue probando).
:try_mysql_port
set "_port=%~1"
if "%_port%"=="" exit /b 0
echo    [i] Probando puerto %_port% para MySQL...

> docker-compose.yml echo services:
>> docker-compose.yml echo   db:
>> docker-compose.yml echo     image: mysql:8.0
>> docker-compose.yml echo     container_name: mysql_analisis_territorial
>> docker-compose.yml echo     restart: unless-stopped
>> docker-compose.yml echo     environment:
>> docker-compose.yml echo       MYSQL_ALLOW_EMPTY_PASSWORD: "yes"
>> docker-compose.yml echo       MYSQL_DATABASE: analisis_territorial
>> docker-compose.yml echo     command: --local-infile=1 --lower-case-table-names=1
>> docker-compose.yml echo     ports:
>> docker-compose.yml echo       - "%_port%:3306"
>> docker-compose.yml echo     volumes:
>> docker-compose.yml echo       - .:/csv-data:ro
>> docker-compose.yml echo       - mysql_data_analisis_territorial:/var/lib/mysql
>> docker-compose.yml echo volumes:
>> docker-compose.yml echo   mysql_data_analisis_territorial:

%DC% down >nul 2>&1
echo        (si es la primera vez, Docker descargara la imagen de MySQL, puede tardar)
%DC% up -d
if errorlevel 1 (
    echo    [i] El puerto %_port% no esta disponible, se probara con otro...
    exit /b 1
)

:: Verificacion real (no una bandera de "una sola vez"): si ya existe un
:: volumen de datos viejo, inicializado ANTES de tener --lower-case-table-names=1,
:: MySQL entra en bucle de reinicio con "Different lower_case_table_names
:: settings for server ('1') and data dictionary ('0')". Lo detectamos mirando
:: el estado real del contenedor y, si esta pasando, borramos el volumen y
:: reintentamos una vez con datos limpios (no se pierde nada: el CSV se
:: recarga siempre en cada corrida).
set "_restarting="
for /l %%N in (1,1,8) do (
    timeout /t 2 >nul
    for /f "usebackq delims=" %%S in (`docker inspect -f "{{.State.Restarting}}" mysql_analisis_territorial 2^>nul`) do set "_restarting=%%S"
    if /i "!_restarting!"=="true" goto _incompatible_volume
)
goto _volume_ok

:_incompatible_volume
echo    [i] Se detecto un volumen de datos de MySQL con una configuracion
echo        incompatible ^(probablemente de una corrida anterior^). Reiniciando
echo        el volumen de datos con la configuracion correcta...
%DC% down -v
%DC% up -d
if errorlevel 1 (
    echo    [i] El puerto %_port% no esta disponible, se probara con otro...
    exit /b 1
)
set "_restarting="
for /l %%N in (1,1,8) do (
    timeout /t 2 >nul
    for /f "usebackq delims=" %%S in (`docker inspect -f "{{.State.Restarting}}" mysql_analisis_territorial 2^>nul`) do set "_restarting=%%S"
    if /i "!_restarting!"=="true" goto _still_incompatible
)
goto _volume_ok

:_still_incompatible
echo    [ERROR] MySQL sigue sin poder arrancar incluso con el volumen
echo            limpio. Salida de "docker compose logs db":
echo ------------------------------------------------------------------------------
%DC% logs db --tail=80
echo ------------------------------------------------------------------------------
exit /b 1

:_volume_ok

set "MYSQL_HOST_PORT=%_port%"
exit /b 0

:: Espera a que MySQL responda. Usa "call" recursivo en vez de "goto" para
:: evitar un bug conocido de cmd.exe: un "goto" hacia atras justo despues de
:: un comando con redireccion "<" a veces falla con "no se encuentra la
:: etiqueta", aunque la etiqueta exista. "call" recursivo no tiene ese problema.
:wait_for_db
if "%~1"=="" (set /a _attempt=1) else (set /a _attempt=%~1)

%DC% exec -T db mysql -uroot -e "SELECT 1;" >nul 2>&1
if not errorlevel 1 exit /b 0

if %_attempt% geq 60 (
    echo [ERROR] MySQL no respondio despues de 2 minutos. Revisa "docker compose logs db".
    pause
    exit /b 1
)
echo    [i] MySQL esta iniciando. Reintentando conexion en 2 segundos...
timeout /t 2 >nul
set /a _next=%_attempt%+1
call :wait_for_db %_next%
exit /b %errorlevel%

:: Ejecuta un archivo .sql contra el contenedor, reintentando si MySQL esta
:: en medio de su reinicio interno de primer arranque (ERROR 2002) o algun
:: otro fallo transitorio. Parametros:
::   %1 = ruta del archivo .sql a ejecutar (con comillas)
::   %2 = argumentos extra para el cliente mysql (puede ir vacio "")
::   %3 = nombre a mostrar en el mensaje de error
::   %4 = numero de intento actual (uso interno, se omite en la llamada inicial)
:run_sql_retry
set "_sqlfile=%~1"
set "_extra=%~2"
set "_label=%~3"
if "%~4"=="" (set /a _attempt=1) else (set /a _attempt=%~4)

%DC% exec -T db mysql -uroot %_extra% < "%_sqlfile%"
if not errorlevel 1 exit /b 0

if %_attempt% geq 20 (
    echo [ERROR] No se pudo ejecutar "%_label%" tras varios intentos.
    echo         Revisa "docker compose logs db".
    pause
    exit /b 1
)
echo    [i] MySQL todavia se esta reiniciando internamente. Reintentando en 2 segundos...
timeout /t 2 >nul
set /a _next=%_attempt%+1
call :run_sql_retry "%_sqlfile%" "%_extra%" "%_label%" %_next%
exit /b %errorlevel%
