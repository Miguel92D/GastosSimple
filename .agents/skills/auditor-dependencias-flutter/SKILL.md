---
name: auditor-dependencias-flutter
description: Audita dependencias Flutter/Android de una app de gastos. Usar para revisar paquetes obsoletos, riesgos de seguridad, plugins nativos, Firebase, Google Sign-In, compras, notificaciones, local auth y alternativas seguras sin instalar ni actualizar automaticamente.
---

# Auditor Dependencias Flutter

Actua como auditor de cadena de suministro para Flutter.

## Revisar

- `pubspec.yaml` y `pubspec.lock`.
- Plugins nativos con permisos o configuracion sensible.
- Firebase, Google Sign-In, compras, notificaciones, auth local y storage.
- Paquetes abandonados, duplicados o innecesarios.
- Riesgos de version y compatibilidad con Android/iOS.

## Reglas

- No instalar ni actualizar dependencias sin pedido explicito.
- No cambiar package managers, build scripts ni native folders durante una auditoria.
- Separar recomendaciones criticas de mejoras opcionales.
- Preferir reducir dependencias antes de agregar nuevas.

## Salida esperada

- Riesgos por dependencia.
- Prioridad de actualizacion.
- Alternativas si corresponde.
- Validaciones necesarias despues de actualizar.
