-- Práctica 3. Normalización y claves
-- Parte A (actividad guiada): normalizar Inventario hasta 3FN.
-- Parte B (reto): normalizar Cursos hasta 3FN.
-- En ambas partes se conserva la tabla original con datos de ejemplo y se migran
-- los datos a las tablas normalizadas con INSERT ... SELECT, para comprobar que
-- no se pierde información.
-- Ejecutar desde una base vacía:  psql -U postgres -f practica-03.sql

CREATE DATABASE practica3;

\c practica3

-- =====================================================================
-- PARTE A. Inventario
-- =====================================================================

-- Tabla original (sin normalizar)
CREATE TABLE inventario_original (
    id                INT PRIMARY KEY,
    producto          VARCHAR(50),
    almacen           VARCHAR(50),
    cantidad          INT,
    direccion_almacen VARCHAR(100),
    ciudad_almacen    VARCHAR(50)
);

INSERT INTO inventario_original VALUES
    (1, 'Teclado', 'Almacén Norte', 40, 'Av. Universidad 100', 'Monterrey'),
    (2, 'Mouse',   'Almacén Norte', 75, 'Av. Universidad 100', 'Monterrey'),
    (3, 'Teclado', 'Almacén Sur',   15, 'Calle Hidalgo 25',    'Saltillo'),
    (4, 'Monitor', 'Almacén Sur',    8, 'Calle Hidalgo 25',    'Saltillo'),
    (5, 'Monitor', 'Almacén Norte', 12, 'Av. Universidad 100', 'Monterrey');

-- Redundancia: la dirección y la ciudad del almacén se repiten en cada fila.
-- Dependencia transitiva: id -> almacen -> (direccion_almacen, ciudad_almacen)
SELECT almacen, direccion_almacen, ciudad_almacen, COUNT(*) AS veces_repetido
FROM inventario_original
GROUP BY almacen, direccion_almacen, ciudad_almacen;

-- 3FN: cada hecho se guarda una sola vez
CREATE TABLE almacen (
    almacen_id SERIAL PRIMARY KEY,
    nombre     VARCHAR(50)  NOT NULL UNIQUE,
    direccion  VARCHAR(100) NOT NULL,
    ciudad     VARCHAR(50)  NOT NULL
);

CREATE TABLE producto (
    producto_id SERIAL PRIMARY KEY,
    nombre      VARCHAR(50) NOT NULL UNIQUE
);

-- La cantidad depende del producto Y del almacén (clave compuesta)
CREATE TABLE inventario (
    producto_id INT NOT NULL REFERENCES producto(producto_id),
    almacen_id  INT NOT NULL REFERENCES almacen(almacen_id),
    cantidad    INT NOT NULL CHECK (cantidad >= 0),
    PRIMARY KEY (producto_id, almacen_id)
);

-- Migración de datos
INSERT INTO almacen (nombre, direccion, ciudad)
SELECT DISTINCT almacen, direccion_almacen, ciudad_almacen FROM inventario_original;

INSERT INTO producto (nombre)
SELECT DISTINCT producto FROM inventario_original;

INSERT INTO inventario (producto_id, almacen_id, cantidad)
SELECT p.producto_id, a.almacen_id, o.cantidad
FROM inventario_original o
JOIN producto p ON p.nombre = o.producto
JOIN almacen  a ON a.nombre = o.almacen;

-- Prueba: reconstruir la tabla original desde las tablas normalizadas
SELECT p.nombre AS producto, a.nombre AS almacen, i.cantidad, a.direccion, a.ciudad
FROM inventario i
JOIN producto p ON p.producto_id = i.producto_id
JOIN almacen  a ON a.almacen_id  = i.almacen_id
ORDER BY a.nombre, p.nombre;

-- Prueba de anomalía de actualización resuelta: cambiar la dirección
-- del almacén se hace en UNA sola fila.
UPDATE almacen SET direccion = 'Av. Universidad 200' WHERE nombre = 'Almacén Norte';
SELECT nombre, direccion FROM almacen ORDER BY nombre;

-- =====================================================================
-- PARTE B. Cursos (reto)
-- =====================================================================

-- Tabla original: una fila por cada estudiante inscrito en un curso.
-- curso_id se repite, por eso la clave real es (curso_id, estudiante_email).
CREATE TABLE cursos_original (
    curso_id         INT,
    curso_nombre     VARCHAR(50),
    profesor         VARCHAR(50),
    profesor_email   VARCHAR(50),
    estudiante       VARCHAR(50),
    estudiante_email VARCHAR(50),
    PRIMARY KEY (curso_id, estudiante_email)
);

INSERT INTO cursos_original VALUES
    (1, 'Bases de Datos', 'Carlos Méndez', 'cmendez@escuela.edu', 'Ana Torres',   'atorres@alumno.edu'),
    (1, 'Bases de Datos', 'Carlos Méndez', 'cmendez@escuela.edu', 'Pedro Salas',  'psalas@alumno.edu'),
    (2, 'Física',         'Laura Garza',   'lgarza@escuela.edu',  'Ana Torres',   'atorres@alumno.edu'),
    (2, 'Física',         'Laura Garza',   'lgarza@escuela.edu',  'Sofía Ramos',  'sramos@alumno.edu'),
    (3, 'Programación',   'Carlos Méndez', 'cmendez@escuela.edu', 'Pedro Salas',  'psalas@alumno.edu');

-- 1FN: la tabla ya tiene valores atómicos y una clave primaria (compuesta).
-- 2FN: hay dependencias parciales de la clave:
--      curso_id         -> curso_nombre, profesor, profesor_email
--      estudiante_email -> estudiante
-- 3FN: hay una dependencia transitiva:
--      curso_id -> profesor_email -> profesor

CREATE TABLE profesores (
    profesor_id    SERIAL PRIMARY KEY,
    profesor       VARCHAR(50) NOT NULL,
    profesor_email VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE estudiantes (
    estudiante_id    SERIAL PRIMARY KEY,
    estudiante       VARCHAR(50) NOT NULL,
    estudiante_email VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE cursos (
    curso_id     INT PRIMARY KEY,
    curso_nombre VARCHAR(50) NOT NULL,
    profesor_id  INT NOT NULL REFERENCES profesores(profesor_id)
);

-- Relación N:M entre cursos y estudiantes
CREATE TABLE inscripciones (
    curso_id      INT NOT NULL REFERENCES cursos(curso_id),
    estudiante_id INT NOT NULL REFERENCES estudiantes(estudiante_id),
    PRIMARY KEY (curso_id, estudiante_id)
);

-- Migración de datos
INSERT INTO profesores (profesor, profesor_email)
SELECT DISTINCT profesor, profesor_email FROM cursos_original;

INSERT INTO estudiantes (estudiante, estudiante_email)
SELECT DISTINCT estudiante, estudiante_email FROM cursos_original;

INSERT INTO cursos (curso_id, curso_nombre, profesor_id)
SELECT DISTINCT o.curso_id, o.curso_nombre, p.profesor_id
FROM cursos_original o
JOIN profesores p ON p.profesor_email = o.profesor_email;

INSERT INTO inscripciones (curso_id, estudiante_id)
SELECT o.curso_id, e.estudiante_id
FROM cursos_original o
JOIN estudiantes e ON e.estudiante_email = o.estudiante_email;

-- Prueba: reconstruir la tabla original desde las tablas normalizadas
SELECT c.curso_id, c.curso_nombre, p.profesor, p.profesor_email, e.estudiante, e.estudiante_email
FROM inscripciones i
JOIN cursos      c ON c.curso_id      = i.curso_id
JOIN profesores  p ON p.profesor_id   = c.profesor_id
JOIN estudiantes e ON e.estudiante_id = i.estudiante_id
ORDER BY c.curso_id, e.estudiante;

-- Prueba de integridad: inscribir a un estudiante inexistente debe fallar
INSERT INTO inscripciones (curso_id, estudiante_id) VALUES (1, 99);
