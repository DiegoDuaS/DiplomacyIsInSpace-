# Assets

Todo el arte del juego es original y se dibuja en Libresprite. La lista completa (qué dibujar, tamaño y prioridad) está en `lista-de-assets.xlsx`.

```
assets/src/        archivos fuente .aseprite (lo que se edita)
assets/sprites/    PNG exportados (lo que carga el juego)
assets/audio/      sonidos (opcional)
```

## Cómo se carga

Cada sprite es una **tira horizontal**: los frames van uno al lado del otro, todos del mismo tamaño. El tamaño de un frame y la cantidad de frames están en [`src/data/sprites.lua`](../src/data/sprites.lua). Si el PNG no existe, el juego sigue usando sus formas planas; si existe pero mide otra cosa, el juego avisa con un mensaje que dice qué tamaño esperaba.

Ejemplo: `ui_icons_skill` son 3 iconos de 16x16, así que `assets/sprites/ui_icons_skill.png` mide **48x16**.

## Reglas

- **Tamaño real:** el juego se dibuja a 640x400. Cada sprite se dibuja con el tamaño de la lista, sin agrandarlo ni reducirlo al exportar.
- **Una paleta** para todos los archivos (`assets/src/diplomacy.gpl`).
- **Sin suavizado:** solo píxeles totalmente opacos o totalmente transparentes.
- **Fondo transparente**, salvo los fondos de pantalla (640x400).
- **Nombres** en minúsculas con guiones bajos, iguales a los de la lista.

## Exportar desde Libresprite

`Archivo → Exportar hoja de sprites` → tipo **Tira horizontal**, salida **solo PNG**, escala **100 %**. Guardar en `assets/sprites/<nombre>.png`. El `.aseprite` va en `assets/src/`.
