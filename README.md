# SmallVector

A simple **vector editor** (early Sketch–style) for GNUStep. Create and edit vector shapes (rectangles, ovals, paths), select and move them, change fill and stroke colors, and save/load documents.

## Requirements

- **SmallStepLib** must be built and installed first (same pattern as SmallPaint, SmallMinesweeper):
  ```bash
  cd ../SmallStepLib && make && make install
  ```
- GNUStep (base + gui)

## Build and run

```bash
make
openapp ./SmallVector.app
```

Or run the app bundle in the usual way for your GNUStep installation.

## Usage

- **Tools** (tool strip): Select, Rectangle, Oval, Path.
- **Select**: Click a shape to select it; drag to move; press Delete/Backspace to remove.
- **Rectangle / Oval**: Drag on the canvas to create a shape.
- **Path**: Click to start a path, drag to add line segments, release to finish.
- **Fill… / Stroke…**: Set fill and stroke colors via the color panel.
- **File**: New, Open…, Save, Save As… (`.smallvector` plist format).

## Layout

- `main.m` – entry point, `SSHostApplication runWithDelegate:`  
- `App/` – `SVAppDelegate` (menu, main window)  
- `Core/` – `SVDocument`, `SVShape`, `SVRectShape`, `SVOvalShape`, `SVPathShape`  
- `UI/` – `SVMainWindow` (tool strip, scroll view), `SVCanvasView` (drawing, tools, selection)

See **PLAN.md** for the full implementation plan.
