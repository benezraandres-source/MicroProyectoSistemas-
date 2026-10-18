# 15-Puzzle Flutter

Rompecabezas deslizante académico para web y móvil. Tres dificultades (3×3, 4×4 y 5×5), tableros resolubles mediante paridad de inversiones y récords locales por dificultad.

## Requisitos y ejecución en Windows

Este proyecto usa **Flutter 3.47.7 / Dart 3.13.5**. La instalación local está separada en `C:\tools\flutter-puzzle-3.47.7\flutter`: no reemplaza otros SDK ni modifica el PATH global.

Desde la raíz del repositorio:

```powershell
.\scripts\flutter.ps1 pub get
.\scripts\flutter.ps1 run -d chrome
```

Si el script está bloqueado por la política de PowerShell, puedes invocarlo con `powershell -ExecutionPolicy Bypass -File .\scripts\flutter.ps1 pub get`, o ejecutar directamente el `flutter.bat` de esa instalación desde `flutter_application_1`.

En otro equipo, instala Flutter 3.47.7 desde el archivo oficial y utiliza los comandos normales desde `flutter_application_1`. El ajuste de VS Code de esta copia apunta al SDK local; adáptalo a tu instalación.

## Funcionalidad

- Splash con animación y botón Saltar; menú con Jugar, Marcadores, Configuración, Cómo jugar y Créditos.
- Primera selección de dificultad y reutilización del nivel guardado.
- Tema claro, oscuro o automático; fichas clásicas, coloridas, retro o minimalistas; animaciones configurables.
- Movimiento solo entre casillas adyacentes; cronómetro desde el primer movimiento válido y contador de movimientos.
- Partidas sin límite de tiempo ni condición artificial de derrota. Reiniciar y abandonar una partida iniciada requieren confirmación.
- Victoria con resumen, dificultad, aviso de récord y opciones de reiniciar o salir al menú.
- Récord de mejor tiempo y menor número de movimientos **independientes**, con fecha propia para cada marca. Empatar no reemplaza la fecha de un récord.
- Marcadores por dificultad, mensaje cuando no existen y borrado con confirmación que conserva los ajustes.
- Datos locales mediante `shared_preferences`: sobreviven a reinicios en el mismo navegador/dispositivo. No existe sincronización entre dispositivos. Borrar los datos del sitio elimina estos registros.
- Diseño adaptable; el cronómetro se pausa al pasar la app a segundo plano y se libera al abandonar el tablero.

## Organización

- `lib/modelos/`: configuración, marcadores y reglas de una partida.
- `lib/datos/`: lectura/escritura JSON en almacenamiento local.
- `lib/estado/`: controlador compartido con `ChangeNotifier`, sin librerías de estado externas.
- `lib/screens/`: pantallas y navegación.
- `lib/widgets/`: fichas y contenedores reutilizables.
- `lib/utils/`: validación matemática de resolubilidad.

Andrés Benezra desarrolló la lógica matemática y la base del tablero. La rama **Diego** integra menús, preferencias, marcadores, instrucciones, créditos y las correcciones necesarias para completar los flujos. El desarrollo y las revisiones deben reflejarse con commits de valor de ambos integrantes.

## Pruebas

```powershell
.\scripts\flutter.ps1 analyze
.\scripts\flutter.ps1 test
```

Las pruebas cubren paridad, generación de las tres dificultades, movimientos inválidos, victoria, persistencia de ajustes, marcas independientes, fallos de escritura, borrado confirmado y pantallas pequeñas.

## Compilación web y PWA sin conexión

```powershell
.\scripts\flutter.ps1 build web --release --no-web-resources-cdn --base-href /MicroProyectoSistemas-/
python scripts/prepare_pwa.py
npm ci
npx playwright install chromium
npm run test:pwa
npm run preview
```

Si Python no está en el PATH, usa el ejecutable de tu instalación. El generador usa únicamente la biblioteca estándar.

`prepare_pwa.py` inventaría los archivos realmente compilados y genera `build/web/sw.js` con una caché versionada, limitada a la ruta de esta aplicación. CanvasKit y las fuentes se sirven desde el propio sitio para que no dependan de un CDN. El worker se registra en HTTPS o localhost. Tras la primera carga completa y la confirmación «Listo para jugar sin conexión», la aplicación se puede volver a abrir sin red. No basta con ejecutar `flutter run` para comprobarlo: debe probarse la compilación final.

`npm run preview` abre un servidor local en `http://127.0.0.1:4173/MicroProyectoSistemas-/`.

`npm run test:pwa` levanta un servidor temporal en la subruta real, abre Chromium, comprueba el manifiesto, la instalabilidad en Chromium y el worker, verifica ajustes guardados con el plugin web, bloquea recursos externos, desactiva la caché HTTP, apaga el servidor y recarga con la red desconectada. Guarda capturas en `test-results/`.

En Chrome o Edge usa «Instalar aplicación» desde la barra de direcciones/menú. En iPhone/iPad usa Safari → Compartir → Añadir a pantalla de inicio. La experiencia de instalación física en iOS requiere comprobarse en ese dispositivo.

## GitHub Actions y Pages

El workflow está en `.github/workflows/flutter_web.yml`, en la raíz del repositorio. Usa Flutter 3.47.7 y ejecuta análisis, pruebas, build y comprobación offline con Chromium.

- Los pushes a `Diego` y los pull requests a `main` se verifican y generan artefactos.
- Solo `main` se publica en GitHub Pages, después de pasar las comprobaciones.
- El propietario debe seleccionar **Settings → Pages → Source → GitHub Actions**. El workflow no modifica esa configuración de la cuenta.
- Ruta prevista: `https://benezraandres-source.github.io/MicroProyectoSistemas-/`.

Si se cambia el nombre del repositorio, hay que ajustar `--base-href` en el workflow y la ruta usada por `scripts/pwa_smoke.mjs`.

## Aclaraciones del enunciado

El documento restringe inicialmente el almacenamiento al High Score, pero luego exige persistir también preferencias; aquí se implementan ambos requisitos explícitos. También menciona persistencia entre dispositivos «solo local»: se interpreta como persistencia por dispositivo, sin añadir cuentas ni backend. Los sonidos y el modo imagen son opcionales y no se incluyen. El despliegue se trata como requisito, aunque también aparezca en la sección de bonus.

Las fuentes Roboto incluidas conservan su licencia en `flutter_application_1/assets/fonts/roboto_license.txt`.
