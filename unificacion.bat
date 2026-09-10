@echo off
:: ==============================================================================
:: AUTOMATIZACIÓN TOTAL: ENTORNO, DOCKER, JUPYTER Y MVC - ANÁLISIS TERRITORIAL
:: ==============================================================================

:: 1. Ubicación y Entorno Base
cd /d "C:\xampp\mysql\analisis_territorial"
set PATH=%PATH%;C:\Windows\system32;C:\Windows;C:\Windows\System32\Wbem;C:\Windows\System32\WindowsPowerShell\v1.0\
cls
echo ==============================================================================
echo        INICIANDO AUTOMATIZACION INTEGRAL: ANALISIS TERRITORIAL
echo ==============================================================================
echo.

:: 2. Generación de Estructura de Arquitectura (MVC + Notebooks + Datasets)
echo === [1/7] Comprobando y generando estructura del proyecto (MVC + Jupyter)...
if not exist "venv" mkdir "venv"
if not exist "notebooks" mkdir "notebooks"
if not exist "src" mkdir "src"
if not exist "src\model" mkdir "src\model"
if not exist "src\list" mkdir "src\list"
if not exist "src\controller" mkdir "src\controller"
if not exist "src\view" mkdir "src\view"
if not exist "src\parsistance" mkdir "src\parsistance"
if not exist "src\datasets" mkdir "src\datasets"

:: Crear archivo Jupyter inicial si no existe
if not exist "notebooks\ppythonPrueba.ipynb" (
    echo {"cells":[],"metadata":{},"nbformat":4,"nbformat_minor":2} > "notebooks\ppythonPrueba.ipynb"
)

if exist "src\model\model.py" goto check_list
echo    [+] Generando plantilla de Modelo...
echo import mysql.connector > src\model\model.py
echo. >> src\model\model.py
echo class Model: >> src\model\model.py
echo      def __init__(self, host="127.0.0.1", user="root", password="", database="analisis_territorial"): >> src\model\model.py
echo          self.host = host >> src\model\model.py
echo          self.user = user >> src\model\model.py
echo          self.password = password >> src\model\model.py
echo          self.database = database >> src\model\model.py
echo. >> src\model\model.py
echo      def get_duplicate_municipalities(self): >> src\model\model.py
echo          connection = mysql.connector.connect( >> src\model\model.py
echo              host=self.host, >> src\model\model.py
echo              user=self.user, >> src\model\model.py
echo              password=self.password, >> src\model\model.py
echo              database=self.database >> src\model\model.py
echo          ) >> src\model\model.py
echo          cursor = connection.cursor(dictionary=True) >> src\model\model.py
echo          query = """ >> src\model\model.py
echo          SELECT  >> src\model\model.py
echo              m.Nombre AS municipio, >> src\model\model.py
echo              GROUP_CONCAT( >> src\model\model.py
echo                  DISTINCT d.Nombre >> src\model\model.py
echo                  ORDER BY d.Nombre >> src\model\model.py
echo                  SEPARATOR ', ' >> src\model\model.py
echo              ) AS departamentos, >> src\model\model.py
echo              COUNT(*) AS cantidad >> src\model\model.py
echo          FROM municipio m >> src\model\model.py
echo          JOIN departamento d >> src\model\model.py
echo              ON m.Id_departamento = d.Id_departamento >> src\model\model.py
echo          GROUP BY m.Nombre >> src\model\model.py
echo          HAVING COUNT(*) ^> 1 >> src\model\model.py
echo          ORDER BY m.Nombre; >> src\model\model.py
echo          """ >> src\model\model.py
echo          cursor.execute(query) >> src\model\model.py
echo          results = cursor.fetchall() >> src\model\model.py
echo          cursor.close() >> src\model\model.py
echo          connection.close() >> src\model\model.py
echo          return results >> src\model\model.py

:check_list
if exist "src\list\list.py" goto check_controller
echo    [+] Generando plantilla de Vista...
echo class ListView: > src\list\list.py
echo      @staticmethod >> src\list\list.py
echo      def display_duplicates(duplicates): >> src\list\list.py
echo          print("\n=== MUNICIPIOS DUPLICADOS (CON MAS DE UN DEPARTAMENTO) ===") >> src\list\list.py
echo          print(f"{'Municipio':^<30} ^| {'Departamentos':^<70} ^| {'Cantidad':^<10}") >> src\list\list.py
echo          print("-" * 118) >> src\list\list.py
echo          for row in duplicates: >> src\list\list.py
echo              print(f"{row['municipio']:^<30} ^| {row['departamentos']:^<70} ^| {row['cantidad']:^<10}") >> src\list\list.py
echo          print(f"\nTotal de municipios repetidos encontrados: {len(duplicates)}\n") >> src\list\list.py

:check_controller
if exist "src\controller\controller.py" goto check_main
echo    [+] Generando plantilla de Controlador...
echo from src.model.model import Model > src\controller\controller.py
echo from src.list.list import ListView >> src\controller\controller.py
echo. >> src\controller\controller.py
echo class Controller: >> src\controller\controller.py
echo      def __init__(self): >> src\controller\controller.py
echo          self.model = Model() >> src\controller\controller.py
echo          self.view = ListView() >> src\controller\controller.py
echo. >> src\controller\controller.py
echo      def run(self): >> src\controller\controller.py
echo          try: >> src\controller\controller.py
echo              results = self.model.get_duplicate_municipalities() >> src\controller\controller.py
echo              self.view.display_duplicates(results) >> src\controller\controller.py
echo          except Exception as e: >> src\controller\controller.py
echo              print(f"Error al ejecutar el controlador: {e}") >> src\controller\controller.py

:check_main
if exist "main.py" goto end_structure
echo    [+] Generando archivo ejecutable principal main.py...
echo from src.controller.controller import Controller > main.py
echo. >> main.py
echo if __name__ == "__main__": >> main.py
echo      print("Iniciando la aplicacion Analisis Territorial...") >> main.py
echo      controller = Controller() >> main.py
echo      controller.run() >> main.py

:end_structure
echo.

:: 3. Gestión de Python, Entorno Virtual y Kernel de Jupyter
echo === [2/7] Gestionando Entorno Virtual (venv) y Dependencias...
if not exist "venv\Scripts\python.exe" (
    echo    [+] Creando entorno virtual venv...
    python -m venv venv
) else (
    echo    [i] Entorno virtual existente detectado.
)

echo    [+] Instalando dependencias (mysql-connector-python, pandas, jupyter, ipykernel)...
venv\Scripts\pip.exe install --upgrade pip
venv\Scripts\pip.exe install mysql-connector-python pandas jupyter ipykernel

echo    [+] Registrando entorno virtual como Kernel de Jupyter...
venv\Scripts\python.exe -m ipykernel install --user --name=venv --display-name "Python (venv)"
echo.

:: 4. Infraestructura Docker
echo === [3/7] Levantando infraestructura Docker...
netstat -o -an | findstr /R "\<3306\>" >nul 2>&1
if %errorlevel% equ 0 (
    echo    [!] ADVERTENCIA: El puerto 3306 esta en uso localmente.
)
echo    [+] Iniciando contenedores (docker compose up -d)...
docker compose up -d
echo.

:: 5. Copia de Archivos CSV y Bases de Datos
echo === [4/7] Configurando archivos de datos e importacion...
if not exist "C:\xampp\mysql\Taller_Municipios" (
    mkdir "C:\xampp\mysql\Taller_Municipios"
)
if exist "municipios.csv" (
    copy /Y "municipios.csv" "C:\xampp\mysql\Taller_Municipios\municipios.csv"
)
echo.

:: 6. Sincronización y Carga con MySQL
echo === [5/7] Esperando a que el servicio MySQL de Docker este listo...
:wait_mysql
"C:\xampp\mysql\bin\mysql.exe" -h 127.0.0.1 -P 3306 -u root -e "SELECT 1" >nul 2>&1
if %errorlevel% neq 0 (
    echo    [i] MySQL esta iniciando. Reintentando conexion en 2 segundos...
    timeout /t 2 >nul
    goto wait_mysql
)
echo    [+] MySQL se encuentra activo y respondiendo consultas!
echo.

echo    [+] Ejecutando Creacion de base de datos...
if exist "Crear base de datos.sql" (
    "C:\xampp\mysql\bin\mysql.exe" -h 127.0.0.1 -P 3306 -u root < "Crear base de datos.sql"
)

echo    [+] Ejecutando Cargue de datos...
if exist "Cargue de datos.sql" (
    "C:\xampp\mysql\bin\mysql.exe" -h 127.0.0.1 -P 3306 -u root --local-infile=1 < "Cargue de datos.sql"
)
echo.

:: 7. Pruebas de Consulta en Consola
echo === [6/7] Ejecutando Consultas.sql directamente en Consola...
echo ------------------------------------------------------------------------------
if exist "Consultas.sql" (
    "C:\xampp\mysql\bin\mysql.exe" -h 127.0.0.1 -P 3306 -u root < "Consultas.sql"
)
echo ------------------------------------------------------------------------------
echo.

:: 8. Apertura de Entornos y Ejecución Final de la Arquitectura
echo === [7/7] Apertura de herramientas y Ejecucion Final ===
echo    [+] Abriendo Visual Studio Code...
start "" code .

echo    [+] Ejecutando programa principal Python MVC desde el entorno virtual...
echo.
venv\Scripts\python.exe main.py
echo.
echo ==============================================================================
echo                    PROCESO COMPLETADO EXITOSAMENTE
echo ==============================================================================
pause