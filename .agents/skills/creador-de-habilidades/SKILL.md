---
name: creador-de-habilidades
description: Utiliza esta habilidad cuando necesites crear una nueva capacidad (skill) para el agente dentro del espacio de trabajo. Esta habilidad proporciona el marco y las instrucciones necesarias para estructurar correctamente una nueva habilidad en español, asegurando que el agente pueda reconocerla y activarla según sea necesario.
---

# Creador de Habilidades

Esta habilidad permite al agente expandir sus capacidades creando nuevas habilidades personalizadas. Una "habilidad" es un conjunto de instrucciones, scripts y recursos que extienden lo que el asistente puede hacer.

## Cuándo usar esta habilidad

- Cuando el usuario solicita una funcionalidad nueva y compleja que se beneficiaría de un conjunto dedicado de instrucciones.
- Cuando se identifica una tarea repetitiva que requiere un proceso específico (ej. "Generar informes de gastos mensuales").
- Cuando se desea estandarizar la forma en que el agente interactúa con una parte específica del código o infraestructura.
- Siempre que el usuario diga "Crea una habilidad para [tarea]".

## Cómo crear una nueva habilidad

Para crear una nueva habilidad, sigue estos pasos:

1. **Determinar el Identificador**: Elige un nombre descriptivo en minúsculas y separado por guiones (ej. `gestion-de-metas`).
2. **Crear el Directorio**: Crea una nueva carpeta en `.agents/skills/<identificador>/`.
3. **Crear el Archivo Maestro**: Crea el archivo `SKILL.md` dentro de esa carpeta.
4. **Definir el Metadato (Frontmatter)**: El archivo `SKILL.md` DEBE comenzar con el siguiente bloque YAML:
   ```yaml
   ---
   name: <identificador>
   description: Una descripción extremadamente detallada de QUÉ hace la habilidad y CUÁNDO debe ser activada por el agente. El asistente usa esta descripción para decidir si usa la habilidad.
   ---
   ```
5. **Escribir las Instrucciones**:
   - Usa un encabezado `# <Título de la Habilidad>`.
   - Incluye secciones con encabezados `##` para:
     - `## Descripción`: Propósito general.
     - `## Cuándo usar esta habilidad`: Lista de escenarios de activación.
     - `## Instrucciones de uso`: Pasos detallados para el agente.
     - `## Recursos y Scripts`: Si la habilidad depende de archivos en `scripts/` o `resources/`.

6. **Implementar Recursos Adicionales**:
   - Si la habilidad requiere scripts de ayuda, colócalos en `.agents/skills/<identificador>/scripts/`.
   - Si requiere archivos de configuración o plantillas, colócalos en `.agents/skills/<identificador>/resources/`.

## Ejemplo de Estructura de SKILL.md

```markdown
---
name: ejemplo-de-habilidad
description: Instrucciones para procesar datos de prueba. Se activa cuando el usuario menciona 'procesar datos de ejemplo'.
---

# Ejemplo de Habilidad

Instrucciones para manejar datos de prueba de manera segura.

## Cuándo usar esta habilidad
- Al recibir archivos CSV en la carpeta /test-data.
- Cuando el usuario pide un análisis de 'mock data'.

## Instrucciones de uso
1. Verifica que el archivo existe.
2. Usa el script en `scripts/parse.py` para limpiar los nulos.
3. Devuelve un resumen formateado en Markdown.
```

## Reglas Críticas
- **Idioma**: Todas las instrucciones de la nueva habilidad deben estar en **Español**.
- **Precisión**: La `description` en el YAML debe ser clara para que otros agentes (tú mismo en el futuro) sepan cuándo usarla sin ambigüedades.
- **Rutas**: Siempre usa rutas absolutas o relativas al directorio raíz del proyecto.
