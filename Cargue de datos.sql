USE analisis_territorial;

-- ============================================================
-- 1. CARGAR REGIONES
-- ============================================================

LOAD DATA LOCAL INFILE 'C:/xampp/mysql/Taller_Municipios/municipios.csv'
IGNORE INTO TABLE Region
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS
(
    @region,
    @cod_departamento,
    @departamento,
    @cod_municipio,
    @municipio
)
SET Nombre = TRIM(@region);

-- ============================================================
-- 2. ELIMINAR LAS DOS FILAS MAL INTERPRETADAS
-- ============================================================

DELETE FROM region
WHERE Nombre LIKE 'Región Caribe,88,%';

-- ============================================================
-- 3. CARGAR DEPARTAMENTOS
-- ============================================================

LOAD DATA LOCAL INFILE 'C:/xampp/mysql/Taller_Municipios/municipios.csv'
IGNORE INTO TABLE departamento
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS
(
    @region,
    @cod_departamento,
    @departamento,
    @cod_municipio,
    @municipio
)
SET
    Cod_DANE = TRIM(@cod_departamento),
    Nombre = TRIM(@departamento),
    Id_region = (
        SELECT Id_region
        FROM region
        WHERE Nombre = TRIM(@region)
        LIMIT 1
    );

SET GLOBAL local_infile = 1;

SET GLOBAL local_infile = ON;
SHOW GLOBAL VARIABLES LIKE 'local_infile';
-- ============================================================
-- 4. CARGAR MUNICIPIOS
-- ============================================================

LOAD DATA LOCAL INFILE 'C:/xampp/mysql/Taller_Municipios/municipios.csv'
IGNORE INTO TABLE Municipio
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS
(
    @region,
    @cod_departamento,
    @departamento,
    @cod_municipio,
    @municipio
)
SET
    Cod_DANE = TRIM(@cod_municipio),
    Nombre = TRIM(@municipio),
    Id_departamento = (
        SELECT Id_departamento
        FROM Departamento
        WHERE Cod_DANE = TRIM(@cod_departamento)
        LIMIT 1
    );

-- ============================================================
-- 5. SAN ANDRÉS
-- ============================================================

INSERT IGNORE INTO departamento
    (Cod_DANE, Nombre, Id_region)
SELECT
    '88',
    'Archipiélago de San Andrés, Providencia y Santa Catalina',
    Id_region
FROM region
WHERE Nombre = 'Región Caribe'
LIMIT 1;

-- ============================================================
-- 6. PROVIDENCIA
-- ============================================================

INSERT IGNORE INTO municipio
    (Cod_DANE, Nombre, Id_departamento)
SELECT
    '88.564',
    'Providencia',
    Id_departamento
FROM departamento
WHERE Cod_DANE = '88'
LIMIT 1;

-- ============================================================
-- 7. SAN ANDRÉS
-- ============================================================

INSERT IGNORE INTO municipio
    (Cod_DANE, Nombre, Id_departamento)
SELECT
    '88.001',
    'San Andrés',
    Id_departamento
FROM departamento
WHERE Cod_DANE = '88'
LIMIT 1;

-- ============================================================
-- 8. VERIFICACIÓN
-- ============================================================

SELECT COUNT(*) AS regiones
FROM region;

SELECT COUNT(*) AS departamentos
FROM departamento;

SELECT COUNT(*) AS municipios
FROM municipio;
