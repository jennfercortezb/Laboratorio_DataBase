# Práctica 5 – Manipulación de datos con SQL (DML)

## Objetivo
Insertar, consultar, actualizar y eliminar datos con DML, y usar operadores, funciones de agregación y cláusulas de filtrado (`WHERE`, `GROUP BY`, `HAVING`, `ORDER BY`).

Script: [`practica-05.sql`](practica-05.sql). Continúa la base `empresa` de la práctica 4, así que primero se ejecuta `practica-04.sql`.

## Preparación
- Se crearon las tablas `cliente`, `producto`, `pedido` y `detalle_pedido` con las definiciones de la guía.
- Se agregó a `empleado` la columna `depto_id` (clave foránea a `departamento`) para poder agrupar salarios por departamento. Se usó `ADD COLUMN IF NOT EXISTS`, que es la misma instrucción que pide la práctica 6.

## Procedimiento: empleado y departamento

| Paso | Sentencia | Resultado |
|---|---|---|
| Poblar | 4 departamentos y 8 empleados | `INSERT 0 4`, `INSERT 0 8` |
| `WHERE` | Salario ≥ 40,000 | 5 empleados |
| `AND` | Analistas con salario > 43,000 | 1 empleado |
| `OR` | Vendedores o reclutadores | 3 empleados |
| `ORDER BY … LIMIT 3` | Tres salarios más altos | 65,000 · 52,000 · 48,000 |
| `AVG` | Salario promedio | 1 valor |
| `GROUP BY … HAVING` | Departamentos con más de 100,000 en salarios | Ventas: 123,000 |
| `UPDATE` | +5 % a los analistas | 42,000 → 44,100 y 45,000 → 47,250 |
| `DELETE` | Empleado con `id = 3` | `DELETE 1` |

Antes del `UPDATE` y del `DELETE` se ejecutó un `SELECT` con el mismo `WHERE` para ver exactamente qué filas se iban a modificar.

## Actividad guiada: clientes y pedidos

Se registraron 6 clientes (uno de ellos sin pedidos), 5 productos y 7 pedidos con su detalle, en fechas de 2025 y 2026.

1. **Pedidos con fecha y nombre del cliente:** `JOIN` entre `pedido` y `cliente` → 7 pedidos.
2. **Clientes sin pedidos:** `NOT EXISTS` → Diego Salinas.
3. **Total por cliente con `HAVING` > $1,000:** el importe se calcula como `cantidad × precio` del detalle.

   | Cliente | Pedidos | Total |
   |---|---|---|
   | María Garza | 2 | 6,301.00 |
   | Luis Pérez | 1 | 2,500.00 |
   | Ana López | 2 | 2,190.50 |
   | Rosa Cantú | 1 | 1,250.00 |

   José Martínez no aparece porque su total (722.00) no supera el importe.

## Reto: tienda en línea

Se creó la tabla `inventario` (`producto_id`, `stock`), con la misma definición que usa la práctica 7, y se le dio un stock inicial de 100 unidades por producto.

1. **Productos más vendidos:** Memoria USB (10 unidades), Mouse (7), y Teclado, Monitor y Audífonos (3 cada uno).
2. **Cliente con mayor gasto:** María Garza, con $6,301.00.
3. **Actualización del inventario:** un `UPDATE … FROM` descuenta lo vendido de cada producto (`UPDATE 5`). Por ejemplo, Memoria USB pasa de 100 a 90 y Mouse de 100 a 93.

## Decisiones
- **Clientes sin pedidos con `NOT EXISTS`** en lugar de `NOT IN`: si la subconsulta llegara a tener un `NULL`, `NOT IN` no devolvería nada.
- **"Total de pedidos por cliente" como importe en pesos** (`SUM(cantidad × precio)`), porque la guía pide filtrar por "un importe determinado"; también se muestra cuántos pedidos tiene cada cliente.
- **Pedidos en dos años distintos** para poder resolver el reto de la práctica 6 (combinar pedidos de dos años con `UNION`).
- **El inventario se actualiza con una sola sentencia** que agrupa las ventas por producto, en lugar de un `UPDATE` por cada producto.

## Pruebas
Las capturas de las consultas están en [`evidencia/`](evidencia/).

## Errores encontrados
- La consulta de ejemplo de la guía `GROUP BY depto_id` falla si `empleado` no tiene la columna `depto_id`; por eso se agregó al inicio de esta práctica.
- `WHERE` no puede usar funciones de agregación (`WHERE SUM(...) > 1000` da error); el filtro sobre grupos va en `HAVING`.
- Si el script se ejecuta dos veces, los datos se duplican y el `DELETE` de `id = 3` ya no encuentra la fila; para repetir la práctica hay que volver a crear la base con `practica-04.sql`.

## Conclusión
El DML permite pasar de tener tablas vacías a responder preguntas del negocio, como quién compra más o qué producto se vende más. `WHERE` filtra filas y `HAVING` filtra grupos. Revisar con un `SELECT` antes de cada `UPDATE` o `DELETE` evita modificar o borrar datos por error.
