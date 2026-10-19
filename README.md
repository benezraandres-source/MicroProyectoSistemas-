# 15-Puzzle Flutter

Microproyecto de Sistemas de Información. El juego tiene tableros 3×3, 4×4 y 5×5, récords por dificultad y preferencias guardadas en el dispositivo.
**Juego Web:** [https://benezraandres-source.github.io/MicroProyectoSistemas-/](https://benezraandres-source.github.io/MicroProyectoSistemas-/)
**Repositorio de Código Fuente:** [https://github.com/benezraandres-source/MicroProyectoSistemas-](https://github.com/benezraandres-source/MicroProyectoSistemas-)
## Ejecutar

Se necesita **Flutter 3.47.7 con Dart 3.13.5**. Desde `flutter_application_1`:

```sh
flutter pub get
flutter run -d chrome
```

En esta computadora también se puede usar el SDK separado del proyecto, desde la raíz del repositorio:

```powershell
.\scripts\flutter.ps1 run -d chrome
```

El script y `.vscode/settings.json` apuntan a `C:\tools\flutter-puzzle-3.47.7\flutter`. Si se clona en otra computadora, hay que ajustar esa ruta o usar Flutter desde el PATH.

## Qué incluye

- Menú principal, pantalla de inicio, instrucciones y créditos.
- Dificultad guardada, tema claro/oscuro/automático y cuatro estilos de fichas.
- Tableros aleatorios resolubles y cronómetro desde el primer movimiento válido.
- Confirmación para reiniciar o salir de una partida empezada.
- Mejor tiempo y menor número de movimientos por dificultad, cada uno con su fecha.
- Borrado de marcadores con confirmación, sin borrar las preferencias.
- Instalación como PWA y uso sin conexión después de la primera carga completa.

Los récords de tiempo y movimientos son independientes: pueden venir de partidas distintas. Los datos se guardan con `shared_preferences` en el mismo navegador o dispositivo; no se sincronizan con otros equipos. El juego no tiene límite de tiempo ni condición de derrota. Sonidos y modo imagen son opcionales y no están incluidos.

## Código

`modelos/` contiene las reglas y los datos; `datos/`, el almacenamiento local; `estado/`, el controlador de preferencias y marcadores. Las pantallas están en `screens/` y los componentes compartidos en `widgets/`. La comprobación de paridad está en `utils/`.

El diálogo de victoria guarda el resultado y permite reintentar si falla el almacenamiento. El tablero se encarga de los movimientos, el cronómetro y el ciclo de la partida.

## Comprobar los cambios

Desde `flutter_application_1`:

```sh
flutter analyze
flutter test
flutter build web --release --no-web-resources-cdn --base-href /MicroProyectoSistemas-/
```

Luego, desde la raíz del repositorio:

```sh
python scripts/prepare_pwa.py
npm ci
npx playwright install chromium
npm run test:pwa
npm run preview
```

La vista previa se abre en `http://127.0.0.1:4173/MicroProyectoSistemas-/`. La prueba de navegador comprueba la instalación, los ajustes guardados y la recarga sin red, con el servidor apagado y la caché HTTP desactivada. Las capturas quedan en `test-results/`.

Para probar el modo offline hay que compilar y ejecutar `prepare_pwa.py`; `flutter run` por sí solo no genera la caché de la PWA. Las fuentes y CanvasKit se incluyen en el sitio, sin depender de un CDN.

## Publicación

[GitHub Pages](https://benezraandres-source.github.io/MicroProyectoSistemas-/)

El workflow `.github/workflows/flutter_web.yml` verifica `Diego`, los pull requests y `main`. Solo publica desde `main`, después de pasar análisis, pruebas y comprobaciones de la PWA. En Settings → Pages, la fuente debe ser **GitHub Actions**.

En Chrome o Edge se instala desde el menú del navegador. En Safari de iPhone/iPad, desde Compartir → Añadir a pantalla de inicio; esa instalación debe probarse en un dispositivo iOS.

Las fuentes Roboto conservan su licencia en `flutter_application_1/assets/fonts/roboto_license.txt`.
