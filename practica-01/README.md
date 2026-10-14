# Práctica 1 – Introducción a las bases de datos

## Objetivo
Comprender qué es una base de datos y un SGBD, distinguir entre datos y metadatos, y reconocer los principales modelos de bases de datos (relacional y NoSQL).

## Actividad guiada
Se creó la base `practica1` con la tabla `productos` (`id`, `nombre`, `precio`), se insertaron tres productos y se consultó la tabla. Script: [`practica-01.sql`](practica-01.sql).

### Decisiones
- `id` es `SERIAL PRIMARY KEY` para que PostgreSQL genere el identificador y garantice que cada producto sea único.
- `precio` es `NUMERIC(10,2)` y no `REAL`/`FLOAT`, porque los importes de dinero necesitan exactitud decimal.
- Al final se ejecuta `\d productos` para mostrar los **metadatos** de la tabla (tipo, longitud y restricciones de cada columna), que son "datos sobre los datos".

### Pruebas
La salida completa está en [`evidencia/salida-psql.txt`](evidencia/salida-psql.txt):

```
 id | nombre  | precio
----+---------+---------
  1 | Teclado |  350.00
  2 | Mouse   |  180.50
  3 | Monitor | 2500.00
(3 filas)
```

## Reto
Tabla comparativa de SGBD relacionales (MySQL, SQLite, Oracle) y NoSQL (MongoDB, Redis, Cassandra) con tres características de cada uno: almacenamiento y modelo, consistencia y transacciones, y escalabilidad y uso típico. Documento: [`evidencia/reto-practica-01.pdf`](evidencia/reto-practica-01.pdf).

## Errores encontrados
- El metacomando `\c practica1` solo funciona en `psql`; en la herramienta de consultas de pgAdmin no existe y hay que cambiar de base desde el panel.
- Si el script se ejecuta dos veces, `CREATE DATABASE practica1` falla porque la base ya existe; antes hay que ejecutar `DROP DATABASE practica1;`.

## Conclusión
Una base de datos administrada por un SGBD guarda los datos junto con su descripción (metadatos) y controla el tipo de cada valor, algo que un archivo plano o una hoja de cálculo no garantizan. La comparación del reto muestra que no hay un sistema mejor en general: los relacionales priorizan la consistencia y las relaciones, y los NoSQL la flexibilidad y la escalabilidad.
