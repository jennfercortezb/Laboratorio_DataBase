-- Práctica 2. Modelado de datos con el modelo entidad-relación
-- Actividad guiada: esquema relacional del sistema de ventas
-- (Cliente, Producto, Pedido, DetallePedido) obtenido del diagrama ER.
-- Ejecutar desde una base vacía:  psql -U postgres -f practica-02.sql

CREATE DATABASE practica2;

\c practica2

-- Entidad Cliente
CREATE TABLE cliente (
    id        SERIAL PRIMARY KEY,
    nombre    VARCHAR(50)  NOT NULL,
    correo    VARCHAR(100) UNIQUE,
    direccion VARCHAR(100)
);

-- Entidad Producto
CREATE TABLE producto (
    id     SERIAL PRIMARY KEY,
    nombre VARCHAR(100)  NOT NULL,
    precio NUMERIC(10,2) NOT NULL CHECK (precio >= 0)
);

-- Entidad Pedido: un cliente realiza muchos pedidos (1:N)
CREATE TABLE pedido (
    id         SERIAL PRIMARY KEY,
    cliente_id INT  NOT NULL REFERENCES cliente(id),
    fecha      DATE NOT NULL DEFAULT CURRENT_DATE
);

-- DetallePedido: resuelve la relación N:M entre Pedido y Producto
CREATE TABLE detalle_pedido (
    pedido_id   INT NOT NULL REFERENCES pedido(id),
    producto_id INT NOT NULL REFERENCES producto(id),
    cantidad    INT NOT NULL CHECK (cantidad > 0),
    PRIMARY KEY (pedido_id, producto_id)
);

-- Datos mínimos para comprobar que las relaciones funcionan
INSERT INTO cliente (nombre, correo, direccion) VALUES
    ('Ana López', 'ana@ejemplo.com', 'Av. Universidad 100'),
    ('Luis Pérez', 'luis@ejemplo.com', 'Calle Hidalgo 25');

INSERT INTO producto (nombre, precio) VALUES
    ('Teclado', 350.00),
    ('Mouse', 180.50),
    ('Monitor', 2500.00);

INSERT INTO pedido (cliente_id, fecha) VALUES
    (1, '2026-09-15'),
    (2, '2026-09-16');

INSERT INTO detalle_pedido (pedido_id, producto_id, cantidad) VALUES
    (1, 1, 1),
    (1, 2, 2),
    (2, 3, 1);

-- Prueba: cada pedido con su cliente y productos
SELECT p.id AS pedido, c.nombre AS cliente, pr.nombre AS producto, d.cantidad
FROM pedido p
JOIN cliente c         ON c.id = p.cliente_id
JOIN detalle_pedido d  ON d.pedido_id = p.id
JOIN producto pr       ON pr.id = d.producto_id
ORDER BY p.id, pr.nombre;

-- Prueba de integridad: un pedido con un cliente inexistente debe fallar
INSERT INTO pedido (cliente_id, fecha) VALUES (99, '2026-09-17');
