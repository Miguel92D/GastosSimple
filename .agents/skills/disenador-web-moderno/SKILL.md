---
name: disenador-web-moderno
description: Especialista experto en el diseño y desarrollo de landing pages de alta gama utilizando Next.js y Tailwind CSS. Se activa cuando se requiere crear interfaces futuristas, oscuras, con estéticas de vanguardia (espacial, neón, glassmorphism) y layouts totalmente responsivos que se alejen de lo genérico.
---

# Diseñador Web Moderno (Next.js & Tailwind)

Esta habilidad dota al agente de la capacidad de actuar como un diseñador UI/UX de élite y desarrollador frontend senior. Se enfoca en crear experiencias visuales "Premium" que impacten al usuario desde el primer vistazo.

## Cuándo usar esta habilidad

- Cuando el usuario solicita una "landing page" o una web/app con diseño moderno.
- Cuando se requiere implementar estéticas específicas: **Espacial/Futurista**, **Cyberpunk/Neón**, **Glassmorphism**.
- Cuando el proyecto base utiliza **Next.js** y **Tailwind CSS**.
- Cuando se busca un diseño que no parezca generado por IA tradicional (evitando layouts genéricos).

## Instrucciones de Uso

### 1. Preparación del Entorno
Si el proyecto no existe, inicializa un proyecto Next.js siguiendo estas reglas:
- `npx create-next-app@latest ./ --typescript --tailwind --eslint --app --src-dir` (en modo no interactivo).
- Configura `tailwind.config.ts` para incluir gradientes personalizados y animaciones.

### 2. Lineamientos de Diseño Estético
Para cumplir con el estándar de "Alta Gama", sigue siempre estos principios:
- **Paleta de Colores**: Fondo obscuro profundo (`#050505` o similar), acentos en púrpuras neón, azules eléctricos y cian.
- **Atmósfera**: Uso de cielos estrellados (estrellas brillantes de diferentes tamaños) y arcos de luz degradada (glows) para enmarcar el contenido.
- **Tipografía**: Fuentes modernas y limpias (preferiblemente Google Fonts como `Inter`, `Outfit` o `Space Grotesk`). Títulos con gradientes radiales o lineales.
- **Componentes**: 
  - **Cabecera (Header)**: Logotipo con icono a la izquierda, navegación flotante o central, y botón de acción (CTA) con efectos de hover brillantes a la derecha.
  - **Hero Section**: Título gigante dominante, párrafos con buen interlineado y botones con efectos de cristal o bordes brillantes.
  - **Social Proof**: Logotipos de socios en blanco puro con opacidad reducida para mantener la elegancia.

### 3. Implementación con Tailwind
- Usa `backdrop-blur` para efectos de cristal.
- Define gradientes complejos: `bg-gradient-to-br from-purple-600 via-blue-700 to-black`.
- Implementa animaciones sutiles: `animate-pulse` para estrellas, `hover:scale-105` para elementos interactivos.

## Ejemplo de Estructura de Hero Section (Referencia)

```tsx
<div className="relative min-h-screen bg-space-black overflow-hidden">
  {/* Fondo de Estrellas y Glow */}
  <div className="absolute inset-0 bg-[url('/stars.png')] opacity-50"></div>
  <div className="absolute -top-40 left-1/2 -translate-x-1/2 w-[800px] h-[600px] bg-purple-600/20 blur-[120px] rounded-full"></div>
  
  <section className="relative z-10 flex flex-col items-center justify-center text-center px-6">
    <h1 className="text-6xl md:text-8xl font-bold bg-clip-text text-transparent bg-gradient-to-r from-purple-400 to-blue-500">
      Futuro Digital
    </h1>
    {/* ... resto del contenido ... */}
  </section>
</div>
```

## Reglas Críticas
- **Responsividad**: El diseño DEBE verse perfecto en móviles, tablets y escritorio.
- **Limpieza**: Código modular, usando componentes de React para cada sección.
- **Impacto Visual**: Cada pixel debe contar. Si el diseño se ve "simple", aumenta los efectos de iluminación y gradientes.
