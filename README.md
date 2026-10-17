# MicroProyectoSistemas-
#  Sliding Puzzle (15-Puzzle) - Flutter App

Aplicación web e interactiva del clásico juego del rompecabezas deslizante (Sliding Puzzle / 15-Puzzle), desarrollada en **Flutter** y **Dart** como microproyecto académico.

---

##  Características Principales

- **Múltiples Niveles de Dificultad:**
  -  **Fácil (3x3):** 8 fichas.
  -  **Medio (4x4):** 15 fichas (Clásico).
  -  **Difícil (5x5):** 24 fichas.
- **Garantía de Solubilidad:** Algoritmo matemático basado en la paridad de inversiones que asegura que el 100% de los tableros generados tengan solución.
- **Persistencia de Datos:** Guardado automático de récords (menor número de movimientos y mejor tiempo) mediante almacenamiento local.
- **Diseño Responsivo:** Interfaz adaptable a pantallas de escritorios, tablets y dispositivos móviles.
- **Despliegue Continuo (CI/CD):** Pipeline automatizado con GitHub Actions para despliegue en GitHub Pages.

---

##  Reparto de Trabajo (50% / 50%)

| Integrante | Responsabilidades y Módulos Desarrollados |
| :--- | :--- |
| **Andrés Benezra** | Lógica central del puzzle, algoritmo de solubilidad matemática, tablero dinámico responsivo, arquitectura de carpetas modular (`screens`, `widgets`, `utils`, `datos`) y configuración del pipeline CI/CD en GitHub Actions. |
| **Diego** | Diseño de menús principales, persistencia de datos con `shared_preferences`, gestión de mejores tiempos/puntajes altos y pantallas de instrucciones y créditos. |

---

##  Tecnologías Utilizadas

- **Lenguaje:** Dart
- **Framework:** Flutter (Web & Desktop)
- **Control de Versiones:** Git & GitHub
- **Persistencia:** `shared_preferences`
- **CI/CD:** GitHub Actions & GitHub Pages

---

## Instrucciones para Ejecutar el Proyecto Localmente

1. **Clonar el repositorio:**
   ```bash
   git clone [https://github.com/benezraandres-source/MicroProyectoSistemas-.git](https://github.com/benezraandres-source/MicroProyectoSistemas-.git)
