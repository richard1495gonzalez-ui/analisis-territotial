DROP DATABASE IF EXISTS analisis_territorial;
CREATE DATABASE analisis_territorial CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
USE analisis_territorial;

DROP TABLE IF EXISTS Municipio;
DROP TABLE IF EXISTS Departamento;
DROP TABLE IF EXISTS Region;

CREATE TABLE Region (
    Id_region INT AUTO_INCREMENT PRIMARY KEY,
    Nombre VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE Departamento (
    Id_departamento INT AUTO_INCREMENT PRIMARY KEY,
    Cod_DANE VARCHAR(10) NOT NULL UNIQUE,
    Nombre VARCHAR(100) NULL,
    Id_region INT NOT NULL,
    FOREIGN KEY (Id_region) REFERENCES Region(Id_region)
);

CREATE TABLE Municipio (
    Id_Municipio INT AUTO_INCREMENT PRIMARY KEY,
    Cod_DANE VARCHAR(10) NULL UNIQUE,
    Nombre VARCHAR(100) NULL,
    Id_departamento INT NULL,
    FOREIGN KEY (Id_departamento) REFERENCES Departamento(Id_departamento)
);
