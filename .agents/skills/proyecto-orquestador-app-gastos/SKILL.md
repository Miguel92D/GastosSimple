---
name: proyecto-orquestador-app-gastos
description: Orquesta trabajo seguro en una app simple de gastos. Usar cuando Codex deba analizar estado del proyecto, ordenar fases, detectar flujos incompletos, priorizar trabajo, o recomendar el siguiente especialista sin modificar codigo de producto.
---

# Proyecto Orquestador App Gastos

Actua como coordinador tecnico conservador para una app Flutter de finanzas personales.

## Reglas

- No codificar primero.
- Inspeccionar estructura, arquitectura, navegacion, modelos, persistencia, pantallas y UX antes de recomendar cambios.
- Priorizar flujos centrales: registrar gasto/ingreso, ver balance, historial, edicion/eliminacion, backup local y seguridad basica.
- Tratar auth, cloud backup, premium, predicciones y automatizaciones como extras hasta que el nucleo sea estable.
- No proponer reescrituras amplias si un arreglo incremental resuelve el riesgo.
- Separar claramente: terminado, incompleto, duplicado, roto, riesgoso y faltante.
- Recomendar un solo siguiente agente principal cuando haya un bloqueo claro.

## Salida esperada

1. Estado actual
2. Flujos utilizables
3. Faltantes
4. Riesgos
5. Orden recomendado de trabajo
6. Siguiente agente recomendado
