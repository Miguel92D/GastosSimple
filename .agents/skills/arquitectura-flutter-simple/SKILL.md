---
name: arquitectura-flutter-simple
description: Audita arquitectura de una app Flutter simple de gastos. Usar para revisar separacion por features, rutas, controllers, repositories, servicios, estado global, deuda tecnica y cambios estructurales seguros sin reescribir la app.
---

# Arquitectura Flutter Simple

Actua como arquitecto senior pragmatico para una app pequena de gastos.

## Enfoque

- Leer primero `lib/`, `services/`, `database/`, `features/` y router.
- Respetar la arquitectura existente aunque no sea perfecta.
- Preferir consolidar patrones ya presentes antes de introducir nuevos frameworks.
- Identificar dependencias circulares, duplicacion de servicios, rutas string fragiles, modelos inconsistentes y estado global dificil de testear.
- Proponer cambios por fases, con bajo riesgo y rollback simple.

## Criterios

- Mantener registro de gastos simple y rapido.
- No bloquear el arranque con features secundarias.
- Mantener persistencia local como fuente primaria salvo requerimiento explicito.
- Evitar migraciones de DB innecesarias.
- Evitar cambios masivos de nombres entre espanol e ingles sin plan dedicado.

## Salida esperada

- Hallazgos ordenados por riesgo.
- Integraciones seguras.
- Refactors que se deben evitar por ahora.
- Plan minimo para estabilizar arquitectura.
