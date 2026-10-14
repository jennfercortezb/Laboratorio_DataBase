-- Práctica 5. Manipulación de datos con SQL (DML)
-- Continúa la base empresa de la práctica 4 (ejecutar antes practica-04.sql).
-- Ejecutar:  psql -U postgres -f practica-05.sql

\c empresa

-- =====================================================================
-- PREPARACIÓN: tablas de la tienda (definiciones de la guía)
-- =====================================================================

CREATE TABLE IF NOT EXISTS cliente (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL,
    direccion VARCHAR(100)
);

CREATE TABLE IF NOT EXISTS producto (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    precio NUMERIC(10,2)
);

CREATE TABLE IF NOT EXISTS pedido (
    id SERIAL PRIMARY KEY,
    cliente_id INT NOT NULL REFERENCES cliente(id),
    fecha DATE NOT NULL
);

CREATE TABLE IF NOT EXISTS detalle_pedido (
    pedido_id INT NOT NULL REFERENCES pedido(id),
    producto_id INT NOT NULL REFERENCES producto(id),
    cantidad INT NOT NULL,
    PRIMARY KEY(pedido_id, producto_id)
);

-- Para agrupar salarios por departamento, el empleado necesita su departamento
-- (la práctica 6 usa esta misma columna).
ALTER TABLE empleado ADD COLUMN IF NOT EXISTS depto_id INT REFERENCES departamento(id);

-- =====================================================================
-- PROCEDIMIENTO: empleado y departamento
-- =====================================================================

-- 1. Poblar datos
INSERT INTO departamento (nombre) VALUES ('Ventas'), ('Finanzas'), ('RRHH'), ('Sistemas');

INSERT INTO empleado (nombre, puesto, salario, fecha_contratacion, depto_id) VALUES
    ('Carlos Méndez',  'Gerente',      65000, '2019-03-01', 1),
    ('Laura Garza',    'Analista',     42000, '2021-06-15', 2),
    ('Pedro Salas',    'Vendedor',     28000, '2023-01-10', 1),
    ('Sofía Ramos',    'Analista',     45000, '2020-09-01', 2),
    ('Miguel Treviño', 'Reclutador',   31000, '2022-02-20', 3),
    ('Elena Cantú',    'Desarrollador', 52000, '2021-11-05', 4),
    ('Jorge Villarreal', 'Desarrollador', 48000, '2024-04-01', 4),
    ('Ana Torres',     'Vendedor',     30000, '2025-08-18', 1);

-- 2. Consultas con WHERE, AND y OR
SELECT nombre, salario FROM empleado WHERE salario >= 40000;

SELECT nombre, puesto, salario
FROM empleado
WHERE puesto = 'Analista' AND salario > 43000;

SELECT nombre, puesto
FROM empleado
WHERE puesto = 'Vendedor' OR puesto = 'Reclutador';

-- 3. Ordenar y limitar: los tres salarios más altos
SELECT nombre, salario FROM empleado ORDER BY salario DESC LIMIT 3;

-- 4. Funciones de agregación
SELECT AVG(salario) AS promedio FROM empleado;

SELECT d.nombre AS departamento, COUNT(*) AS empleados, SUM(e.salario) AS total_salarios
FROM empleado e
JOIN departamento d ON d.id = e.depto_id
GROUP BY d.nombre
HAVING SUM(e.salario) > 100000;

-- 5. UPDATE: primero se revisan las filas afectadas, luego se actualiza y se verifica
SELECT nombre, salario FROM empleado WHERE puesto = 'Analista';
UPDATE empleado SET salario = salario * 1.05 WHERE puesto = 'Analista';
SELECT nombre, salario FROM empleado WHERE puesto = 'Analista';

-- 6. DELETE: siempre con WHERE y revisando antes qué se va a borrar
SELECT id, nombre FROM empleado WHERE id = 3;
DELETE FROM empleado WHERE id = 3;
SELECT id, nombre FROM empleado ORDER BY id;

-- =====================================================================
-- ACTIVIDAD GUIADA: clientes y pedidos
-- =====================================================================

INSERT INTO cliente (nombre, direccion) VALUES
    ('Ana López',     'Av. Universidad 100, Monterrey'),
    ('Luis Pérez',    'Calle Hidalgo 25, Saltillo'),
    ('María Garza',   'Av. Constitución 300, Monterrey'),
    ('José Martínez', 'Calle Morelos 12, San Nicolás'),
    ('Rosa Cantú',    'Av. Juárez 45, Guadalupe'),
    ('Diego Salinas', 'Calle Zaragoza 8, Apodaca');   -- cliente sin pedidos

INSERT INTO producto (nombre, precio) VALUES
    ('Teclado',     350.00),
    ('Mouse',       180.50),
    ('Monitor',    2500.00),
    ('Audífonos',   650.00),
    ('Memoria USB', 120.00);

-- Pedidos de 2025 y 2026 (la práctica 6 los combina por año con UNION)
INSERT INTO pedido (cliente_id, fecha) VALUES
    (1, '2025-11-20'),
    (2, '2025-12-05'),
    (1, '2026-01-15'),
    (3, '2026-02-10'),
    (4, '2026-03-22'),
    (5, '2026-04-08'),
    (3, '2026-05-30');

INSERT INTO detalle_pedido (pedido_id, producto_id, cantidad) VALUES
    (1, 1, 1), (1, 2, 1),
    (2, 3, 1),
    (3, 4, 2), (3, 5, 3),
    (4, 3, 2), (4, 1, 2),
    (5, 2, 4),
    (6, 5, 5), (6, 4, 1),
    (7, 2, 2), (7, 5, 2);

-- 1. Pedidos con la fecha y el nombre del cliente
SELECT p.id AS pedido, p.fecha, c.nombre AS cliente
FROM pedido p
JOIN cliente c ON c.id = p.cliente_id
ORDER BY p.fecha;

-- 2. Clientes sin pedidos
SELECT c.nombre
FROM cliente c
WHERE NOT EXISTS (SELECT 1 FROM pedido p WHERE p.cliente_id = c.id);

-- 3. Total comprado por cliente, solo los que superan $1,000
SELECT c.nombre AS cliente,
       COUNT(DISTINCT p.id)           AS pedidos,
       SUM(d.cantidad * pr.precio)    AS total
FROM cliente c
JOIN pedido p          ON p.cliente_id = c.id
JOIN detalle_pedido d  ON d.pedido_id  = p.id
JOIN producto pr       ON pr.id        = d.producto_id
GROUP BY c.nombre
HAVING SUM(d.cantidad * pr.precio) > 1000
ORDER BY total DESC;

-- =====================================================================
-- RETO: tienda en línea
-- =====================================================================

-- Inventario por producto (misma definición que usa la práctica 7)
CREATE TABLE IF NOT EXISTS inventario (
    producto_id INT PRIMARY KEY REFERENCES producto(id),
    stock INT NOT NULL
);

INSERT INTO inventario (producto_id, stock)
SELECT id, 100 FROM producto;

-- 1. Productos más vendidos
SELECT pr.nombre, SUM(d.cantidad) AS unidades_vendidas
FROM detalle_pedido d
JOIN producto pr ON pr.id = d.producto_id
GROUP BY pr.nombre
ORDER BY unidades_vendidas DESC;

-- 2. Cliente con mayor gasto
SELECT c.nombre, SUM(d.cantidad * pr.precio) AS gasto_total
FROM cliente c
JOIN pedido p          ON p.cliente_id = c.id
JOIN detalle_pedido d  ON d.pedido_id  = p.id
JOIN producto pr       ON pr.id        = d.producto_id
GROUP BY c.nombre
ORDER BY gasto_total DESC
LIMIT 1;

-- 3. Actualizar el inventario: se descuentan las unidades vendidas
SELECT pr.nombre, i.stock FROM inventario i JOIN producto pr ON pr.id = i.producto_id ORDER BY pr.id;

UPDATE inventario i
SET stock = i.stock - v.vendidas
FROM (SELECT producto_id, SUM(cantidad) AS vendidas
      FROM detalle_pedido
      GROUP BY producto_id) v
WHERE i.producto_id = v.producto_id;

SELECT pr.nombre, i.stock FROM inventario i JOIN producto pr ON pr.id = i.producto_id ORDER BY pr.id;
