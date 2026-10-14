-- Práctica 4. Introducción a SQL y lenguaje de definición de datos (DDL)
-- Actividad guiada: base empresa con empleado y departamento, ALTER TABLE
-- para agregar fecha_contratacion y eliminación de una tabla de prueba.
-- Reto: base biblioteca con las tablas normalizadas de la práctica 2.
-- Ejecutar desde una base vacía:  psql -U postgres -f practica-04.sql
-- La base empresa se sigue usando en las prácticas 5 a 12.

-- =====================================================================
-- ACTIVIDAD GUIADA: base empresa
-- =====================================================================

CREATE DATABASE empresa;

\c empresa

CREATE TABLE departamento (
    id     SERIAL PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE empleado (
    id      SERIAL PRIMARY KEY,
    nombre  VARCHAR(50)   NOT NULL,
    puesto  VARCHAR(50)   NOT NULL,
    salario NUMERIC(10,2) NOT NULL CHECK (salario > 0)
);

-- ALTER TABLE: se agrega la fecha de contratación
ALTER TABLE empleado ADD COLUMN fecha_contratacion DATE;

\d empleado

-- ---------------------------------------------------------------------
-- Tabla de prueba para explorar los tipos de datos
-- ---------------------------------------------------------------------
CREATE TABLE prueba_tipos (
    entero  INTEGER,
    numero  NUMERIC(6,2),
    fecha   DATE,
    cadena  VARCHAR(10)
);

-- Valores válidos
INSERT INTO prueba_tipos VALUES (25, 1234.56, '2026-10-13', 'hola');

-- Valores inválidos: cada INSERT debe fallar por la validación de tipos
INSERT INTO prueba_tipos (entero) VALUES ('veinte');          -- no es un entero
INSERT INTO prueba_tipos (numero) VALUES (123456.78);        -- excede NUMERIC(6,2)
INSERT INTO prueba_tipos (fecha) VALUES ('2026-02-30');       -- fecha inexistente
INSERT INTO prueba_tipos (cadena) VALUES ('texto demasiado largo'); -- más de 10 caracteres

-- PostgreSQL redondea los decimales a la escala definida
INSERT INTO prueba_tipos (numero) VALUES (10.567);
SELECT * FROM prueba_tipos;

-- DROP TABLE: se elimina la tabla de prueba
DROP TABLE prueba_tipos;

-- Comprobación: solo quedan las tablas de la empresa
\dt

-- =====================================================================
-- RETO: base biblioteca (tablas normalizadas de la práctica 2)
-- =====================================================================

CREATE DATABASE biblioteca;

\c biblioteca

CREATE TABLE autor (
    id_autor     SERIAL PRIMARY KEY,
    nombre       VARCHAR(100) NOT NULL,
    nacionalidad VARCHAR(50)
);

CREATE TABLE libro (
    id_libro         SERIAL PRIMARY KEY,
    titulo           VARCHAR(150) NOT NULL,
    anio_publicacion INT CHECK (anio_publicacion > 0)
);

-- Relación N:M: un libro puede tener varios autores y un autor varios libros
CREATE TABLE libro_autor (
    id_libro INT NOT NULL REFERENCES libro(id_libro),
    id_autor INT NOT NULL REFERENCES autor(id_autor),
    PRIMARY KEY (id_libro, id_autor)
);

CREATE TABLE usuario (
    id_usuario SERIAL PRIMARY KEY,
    nombre     VARCHAR(100) NOT NULL,
    direccion  VARCHAR(150)
);

-- Relación 1:N: un usuario realiza muchos préstamos; un libro se presta muchas veces
CREATE TABLE prestamo (
    id_prestamo      SERIAL PRIMARY KEY,
    fecha_prestamo   DATE NOT NULL DEFAULT CURRENT_DATE,
    fecha_devolucion DATE,
    id_usuario       INT NOT NULL REFERENCES usuario(id_usuario),
    id_libro         INT NOT NULL REFERENCES libro(id_libro),
    CHECK (fecha_devolucion IS NULL OR fecha_devolucion >= fecha_prestamo)
);

\dt

-- Prueba rápida de las relaciones
INSERT INTO autor (nombre, nacionalidad) VALUES
    ('Gabriel García Márquez', 'Colombiana'),
    ('J. R. R. Tolkien', 'Británica');
INSERT INTO libro (titulo, anio_publicacion) VALUES
    ('Cien años de soledad', 1967),
    ('El señor de los anillos', 1954);
INSERT INTO libro_autor VALUES (1, 1), (2, 2);
INSERT INTO usuario (nombre, direccion) VALUES ('Ana Torres', 'Av. Universidad 100');
INSERT INTO prestamo (fecha_prestamo, fecha_devolucion, id_usuario, id_libro)
    VALUES ('2026-10-01', '2026-10-15', 1, 1);

SELECT u.nombre AS usuario, l.titulo, a.nombre AS autor, p.fecha_prestamo, p.fecha_devolucion
FROM prestamo p
JOIN usuario u      ON u.id_usuario = p.id_usuario
JOIN libro l        ON l.id_libro   = p.id_libro
JOIN libro_autor la ON la.id_libro  = l.id_libro
JOIN autor a        ON a.id_autor   = la.id_autor;

-- La devolución no puede ser anterior al préstamo: debe fallar
INSERT INTO prestamo (fecha_prestamo, fecha_devolucion, id_usuario, id_libro)
    VALUES ('2026-10-10', '2026-10-01', 1, 2);
