# Laboratorio de Bases de Datos

Prácticas del Laboratorio de Bases de Datos (PostgreSQL).

**Alumna:** Jennifer Aracely Cortez Bautista · **Grupo:** 034
**Docente:** Gustavo Adolfo Rodríguez Martínez

## Estructura

Cada práctica tiene su propia carpeta:

| Archivo | Contenido |
|---|---|
| `practica-XX.sql` | Script completo; se ejecuta desde una base vacía |
| `README.md` | Bitácora: objetivo, decisiones, pruebas, errores y conclusión |
| `evidencia/` | Salida de `psql` al ejecutar el script y documentos de los retos |

## Prácticas

| # | Tema | Carpeta |
|---|---|---|
| 1 | Introducción a las bases de datos | [practica-01](practica-01/) |
| 2 | Modelo entidad-relación | [practica-02](practica-02/) |
| 3 | Normalización y claves | [practica-03](practica-03/) |
| 4 | SQL y DDL | [practica-04](practica-04/) |

## Cómo ejecutar un script

```bash
psql -U postgres -f practica-01/practica-01.sql
```

Cada script crea su propia base (`practica1`, `practica2`, …). Si ya existe, se elimina antes con `DROP DATABASE practicaN;`.

La evidencia de cada práctica se generó con:

```bash
psql -U postgres -e -f practica-XX/practica-XX.sql > practica-XX/evidencia/salida-psql.txt
```
