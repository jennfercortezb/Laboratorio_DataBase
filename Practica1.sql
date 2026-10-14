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