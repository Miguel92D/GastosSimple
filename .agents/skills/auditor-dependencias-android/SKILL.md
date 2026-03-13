---
name: auditor-dependencias-android
description: Actúa como un Especialista en Seguridad de la Cadena de Suministro de Software. Analiza todas las dependencias y librerías del proyecto para detectar versiones obsoletas, vulnerabilidades conocidas (CVEs), paquetes abandonados o potencialmente maliciosos. Proporciona un informe detallado con alternativas seguras y recomendaciones de actualización.
---

# Auditor de Dependencias y Seguridad de la Cadena de Suministro

Esta habilidad permite al agente realizar un escaneo y análisis exhaustivo de todas las librerías de terceros utilizadas en la aplicación Android (Flutter/Nativo). Su objetivo es mitigar riesgos introducidos por código externo.

## Cuándo usar esta habilidad

- Al realizar una auditoría de seguridad preventiva integral.
- Antes de publicar la aplicación para asegurar que no hay vulnerabilidades de seguridad conocidas en las librerías incluidas.
- Cuando se desea actualizar el stack tecnológico de forma segura y controlada.
- Si se detecta un comportamiento anómalo que podría originarse en una dependencia de terceros.
- Para verificar el cumplimiento de licencias y el estado de mantenimiento de los paquetes.

## Instrucciones de uso

### 1. Inventario de Dependencias
- Listar todas las dependencias directas e indirectas (transitivas).
- Revisar archivos clave: `pubspec.yaml`, `pubspec.lock`, `build.gradle` (nivel app y proyecto) y `settings.gradle`.

### 2. Detección de Versiones Obsoletas
- Comparar las versiones declaradas con las versiones estables más recientes disponibles en repositorios oficiales como Pub.dev para Flutter o Maven Central/Google Maven para dependencias nativas Android.

### 3. Análisis de Vulnerabilidades (CVEs)
- Verificar si las versiones en uso tienen registros en bases de datos de vulnerabilidades conocidas como el National Vulnerability Database (NVD) de NIST, GitHub Security Advisories o la base de datos de Safety.

### 4. Evaluación de Riesgos de la Cadena de Suministro
- Identificar paquetes que parecen abandonados (falta de commits o actualizaciones en los últimos 12-24 meses).
- Detectar dependencias maliciosas o con reputación dudosa.
- Identificar dependencias con licencias que podrían comprometer el proyecto.

## Informe de Seguridad de Dependencias (Formato de Salida)

Para cada análisis, el agente debe proporcionar un informe que contenga:

1. **Catálogo de Dependencias**: Resumen de librerías utilizadas por categorías.
2. **Vulnerabilidades Detectadas**:
   - Nombre de la librería y versión afectada.
   - Identificador de la vulnerabilidad (CVE / GHSA).
   - Nivel de riesgo (Bajo / Medio / Alto / Crítico).
   - Descripción del impacto potencial.
3. **Plan de Remediación**:
   - Versión actual vs. Versión segura recomendada.
   - Sugerencia de librerías alternativas si la actual está abandonada o es insegura.

## Reglas Críticas
- **Idioma**: Todas las instrucciones, análisis y reportes deben estar en **Español**.
- **Precaución con Cambios**: Al recomendar actualizaciones, advierte siempre sobre posibles cambios que rompan el código (breaking changes).
- **Verificación**: Utiliza herramientas automáticas si están disponibles (ej. `flutter pub deps`) pero realiza una verificación lógica de la salud de la dependencia.
