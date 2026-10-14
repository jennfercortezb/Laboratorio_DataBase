-- Práctica 1. Introducción a las bases de datos
-- Actividad guiada: base practica1 con una tabla productos (id, nombre, precio),
-- al menos tres registros y una consulta.
-- Ejecutar desde una base vacía:  psql -U postgres -f practica-01.sql

CREATE DATABASE practica1;

\c practica1

CREATE TABLE productos (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(50),
    precio NUMERIC(10,2)
);

INSERT INTO productos (nombre, precio) VALUES
    ('Teclado', 350.00),
    ('Mouse', 180.50),
    ('Monitor', 2500.00);

SELECT * FROM productos;

-- Metadatos: descripción de la tabla (tipo y longitud de cada columna)
\d productos
