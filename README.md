# Análisis Territorial - Automatización MVC y Base de Datos

Este proyecto contiene una solución automatizada para configurar la estructura de software bajo el patrón MVC, iniciar una base de datos MySQL en un contenedor Docker, cargar y procesar información geográfica de municipios, ejecutar consultas y abrir las herramientas de desarrollo con un solo comando.

## Requisitos de Ejecución
Asegúrese de contar con los siguientes elementos instalados en su sistema:
- **Docker Desktop** (con soporte para Compose configurado y en ejecución).
- **Python 3** (agregado al PATH del sistema).
- **Visual Studio Code** (con el comando `code` disponible en las variables de entorno/PATH).
- **XAMPP** instalado en la ruta clásica `C:\xampp` (en específico el cliente `mysql.exe` ubicado en `C:\xampp\mysql\bin`).

---

## Instrucciones Paso a Paso para la Ejecución Automática

Siga cualquiera de los dos métodos descritos a continuación para levantar y ejecutar todo de manera totalmente automatizada:

### Método 1: Doble Clic en Windows (El más rápido)
1. Navegue con el Explorador de Archivos de Windows a la ruta del proyecto: `C:\xampp\mysql\analisis_territorial`.
2. Busque el archivo ejecutable por lotes de Windows llamado **`setup_and_run.bat`**.
3. Haga **doble clic** sobre él.
4. El script se ejecutará de forma autónoma realizando todas las tareas (crear carpetas, instalar librerías de Python, encender el contenedor de base de datos, poblar tablas instalando el CSV, mostrar resultados de las consultas en pantalla, abrir el proyecto en VS Code y finalmente ejecutar la aplicación MVC).

---

### Método 2: Desde la Shell de XAMPP o CMD
Si prefiere ejecutar y ver detalladamente la herramienta desde la Shell de XAMPP o la consola Command Prompt (`cmd`):

1. **Abra la Shell de XAMPP** (haciendo clic en el botón "Shell" que se encuentra a la derecha del Panel de Control de XAMPP) o abra el **CMD de Windows**.
2. Desplácese a la carpeta de trabajo:
   ```cmd
   cd C:\xampp\mysql\analisis_territorial
   ```
3. Ejecute el archivo de automatización escribiendo su nombre y presionando Enter:
   ```cmd
   setup_and_run.bat
   ```
4. Observe la consola cómo procesa y despliega concurrentemente la infraestructura y datos.

---

## Flujo de Trabajo que realiza el Script
El archivo batch realiza lo siguiente:
1. **Posicionamiento**: Se traslada a `C:\xampp\mysql\analisis_territorial`.
2. **Generación Arquitectural (MVC)**:
   - Crea la capeta de configuración `env`.
   - Crea el árbol de directorios `src\model`, `src\list` y `src\controller`.
   - Genera archivos base listos para programarse (`model.py`, `list.py`, `controller.py`, `main.py`) sólo si no existen previamente.
3. **Gestión del Entorno de Ejecución**:
   - Detecta si existe un entorno virtual de python (`venv`). Si no, lo crea de forma limpia.
   - Instala de manera desatendida el driver oficial `mysql-connector-python` dentro de `venv`.
4. **Infraestructura con Docker**:
   - Levanta el servicio MySQL configurado en el archivo `docker-compose.yml` ejecutando `docker compose up -d`.
   - Habilita la lectura de archivos locales (`--local-infile=1`).
5. **Carga y Preparación de Datos**:
   - Crea el directorio especial `C:\xampp\mysql\Taller_Municipios` y copia allí el dataset `municipios.csv` (cumpliendo con la ruta rígida exigida por la sentencia SQL para realizar la carga mediante `LOAD DATA LOCAL INFILE`).
   - Espera de manera estable hasta que el motor de MySQL de Docker esté totalmente reactivo.
   - Procesa secuencialmente los scripts: primero crea el esquema y tablas (`Crear base de datos.sql`), y después pobla y realiza limpiezas y verificaciones (`Cargue de datos.sql`).
6. **Consultas Directas**:
   - Ejecuta las sentencias analíticas de `Consultas.sql` mostrando el listado de municipios con duplicidades de departamento directamente en la ventana de consola cmd actual.
7. **Despliegue Final**:
   - Abre el entorno de edición completo integrado en **Visual Studio Code** apuntando a la raíz del proyecto.
   - Ejecuta e inicia el sistema en Python usando el binario virtualizado: `venv\Scripts\python.exe main.py`.
