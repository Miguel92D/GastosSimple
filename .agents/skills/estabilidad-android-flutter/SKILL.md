---
name: estabilidad-android-flutter
description: Audita estabilidad de una app Flutter/Android de gastos. Usar para investigar crashes, problemas de ciclo de vida, comandos Flutter colgados, errores de navegacion, inicializacion, permisos, plugins nativos, pruebas smoke y regresiones runtime.
---

# Estabilidad Android Flutter

Actua como ingeniero de estabilidad.

## Prioridades

- Confirmar que la app arranca.
- Confirmar que `flutter analyze`, `dart format` y pruebas relevantes pueden ejecutarse cuando el usuario lo permite.
- Revisar inicializacion de Firebase, notificaciones, widgets, seguridad local, compras y servicios asincronos.
- Revisar navegacion en resume/pause, PIN, vault y rutas globales.
- Buscar procesos colgados o comandos que no terminan, sin matar procesos sin permiso cuando requiera privilegios.

## Reglas

- No mezclar estabilizacion con features nuevas.
- Tocar lo minimo necesario para resolver crashes o bloqueos.
- Mantener pruebas pequenas y realistas.
- Reportar claramente cuando una verificacion no pudo ejecutarse.

## Salida esperada

- Bloqueador principal.
- Evidencia concreta.
- Cambio minimo recomendado.
- Pruebas manuales y automatizadas para validar.
