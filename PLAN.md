# SmallVector — Implementation Plan

A simple **vector editor** (early Sketch–style) in Objective-C and GNUStep, following patterns from sibling apps and using **SmallStepLib**.

---

## 1. Goals and scope

- **Early Sketch–style**: Canvas with vector shapes (rectangles, ovals, paths), selection, move/delete, fill/stroke colors. No layers, no groups, no text in v1.
- **Platform**: GNUStep (Linux) first; structure should allow macOS later via SmallStepLib.
- **Reuse**: Same app bootstrap and UI patterns as SmallPaint, SmallMinesweeper; use SmallStepLib for lifecycle, menus, window style, and file dialogs. Do **not** use SmallStepLib’s `CanvasView` (it is bitmap-based); implement a dedicated vector canvas in SmallVector.

---

## 2. Reference: how other apps are implemented

| App             | Entry      | Delegate              | Main window              | SmallStepLib usage                          |
|-----------------|-----------|------------------------|---------------------------|---------------------------------------------|
| **SmallMinesweeper** | `main.m` → `SSHostApplication runWithDelegate:` | `AppDelegate` &lt;SSAppDelegate&gt; | `MinesweeperWindow` (content = custom view) | SSMainMenu, SSWindowStyle                   |
| **SmallPaint**  | Same      | Same                   | `PaintWindow` (scroll + CanvasView + tool strip) | SSMainMenu, SSWindowStyle, SSFileDialog, CanvasView |
| **SmallNote**   | Same      | `SNAppDelegate`        | `MainWindow`              | SSHostApplication, custom include path to SmallStep |

**Pattern to follow for SmallVector:**

1. **main.m**  
   - `NSAutoreleasePool` (GNUStep non-ARC).  
   - `id<SSAppDelegate> delegate = [[SVAppDelegate alloc] init]`.  
   - `[SSHostApplication runWithDelegate:delegate]`.

2. **App delegate**  
   - Conform to `SSAppDelegate`.  
   - `applicationWillFinishLaunching` → build menu.  
   - `applicationDidFinishLaunching` → create main window, `makeKeyAndOrderFront:`, `activateIgnoringOtherApps:`.  
   - `applicationShouldTerminateAfterLastWindowClosed:` → return `YES`.  
   - Menu built with `SSMainMenu`: `setAppName:`, `buildMenuWithItems:quitTitle:quitKeyEquivalent:`, `install`.  
   - Menu items: New, Open…, Save, Save As…, Quit; actions implemented in the window or delegate and wired to `SSMainMenuItem itemWithTitle:action:keyEquivalent:modifierMask:target:`.

3. **Main window**  
   - `NSWindow` created with `[SSWindowStyle standardWindowMask]`, `NSBackingStoreBuffered`, `setReleasedWhenClosed:NO`.  
   - Content: toolbar/tool strip (optional) + main content view.  
   - File operations via `SSFileDialog` `openDialog` / `saveDialog`, `setAllowedFileTypes:`, `showModal`, then use returned URLs.

4. **Build**  
   - GNUmakefile: `include common.make` and `application.make`.  
   - `APP_NAME = SmallVector`.  
   - List all `.m` in `SmallVector_OBJC_FILES`, headers in `SmallVector_HEADER_FILES`.  
   - Include dirs: `-I. -IApp -IUI -ICore` and `-I../SmallStepLib/SmallStep/Core` (and `Platform/Linux` if needed).  
   - Link SmallStep as in SmallMinesweeper/SmallPaint: detect `SmallStep.framework`, set `SMALLSTEP_LIB_PATH` and `SMALLSTEP_LDFLAGS`, `LDFLAGS` with `-Wl,--allow-shlib-undefined`, `ADDITIONAL_LDFLAGS` and `TOOL_LIBS` with `-lSmallStep`.  
   - Do **not** depend on `CanvasView` for the vector canvas; SmallVector implements its own view and model.

---

## 3. SmallStepLib usage in SmallVector

- **SSHostApplication** + **SSAppDelegate**: app lifecycle and entry point.
- **SSMainMenu** + **SSMainMenuItem**: application menu (File: New, Open, Save, Save As; Quit).
- **SSWindowStyle**: `standardWindowMask` for the main window.
- **SSFileDialog**: open/save document (e.g. `.smallvector` or a simple export format).
- **SSFileSystem** (optional): default document directory for open/save.
- **Do not use** SmallStepLib’s **CanvasView**: it is for bitmap drawing (pencil/eraser). The vector editor uses its own **vector document model** and **vector canvas view** implemented in SmallVector.

---

## 4. Architecture of SmallVector

### 4.1 Directory layout

```
SmallVector/
├── GNUmakefile
├── main.m
├── App/
│   ├── SVAppDelegate.h
│   └── SVAppDelegate.m
├── Core/
│   ├── SVDocument.h/m        // Vector document model (list of shapes)
│   ├── SVShape.h/m           // Abstract shape (rect, oval, path)
│   ├── SVRectShape.h/m       // Rectangle
│   ├── SVOvalShape.h/m       // Oval/ellipse
│   └── SVPathShape.h/m       // Freeform path (NSBezierPath)
└── UI/
    ├── SVMainWindow.h/m      // Main window (tool strip + canvas)
    └── SVCanvasView.h/m      // NSView that draws shapes and handles selection/drawing
```

### 4.2 Core: document and shapes

- **SVDocument**  
  - Mutable array of shapes (e.g. `NSMutableArray<id<SVShape>>` or base type `SVShape`).  
  - Optional: artboard size (e.g. `NSSize`) for new document and export.  
  - Methods: `addShape:`, `removeShape:`, `shapeAtPoint:`, `selectedShape` / `setSelectedShape:`, and document dirty flag for window title.  
  - Serialization: simple custom format (e.g. plist or line-based) for save/load; one file per document.

- **SVShape** (abstract or protocol)  
  - Properties: frame/bounds, fill color, stroke color, stroke width.  
  - `drawInRect:` or `drawInContext:` using **NSBezierPath** (GNUStep and AppKit provide this).  
  - `containsPoint:` for hit-testing.  
  - Subclasses: **SVRectShape**, **SVOvalShape**, **SVPathShape** (wrapping `NSBezierPath`).  
  - Shapes are in **canvas coordinates** (origin bottom-left if matching AppKit).

- **SVPathShape**  
  - Holds an `NSBezierPath`; supports open/closed path, stroke and fill.  
  - For “early Sketch” v1, this can be a single path created by a pen tool (mouse down → move → mouse up); no bezier handles yet.

### 4.3 UI: canvas view and main window

- **SVCanvasView** (NSView)  
  - Owns or is bound to an **SVDocument**.  
  - `drawRect:`: clear background (e.g. checker or white), then iterate shapes and call `[shape drawInRect:]` (or equivalent).  
  - Draw selection: if `document.selectedShape` is set, draw a highlight (e.g. stroke or handles) around it.  
  - Coordinate system: same as document (e.g. flip if needed so Y-up matches AppKit).  
  - Mouse:  
    - **Select tool**: mouse down → hit-test via `[document shapeAtPoint:]` → set `selectedShape`, `setNeedsDisplay:YES`.  
    - **Rectangle/Oval tools**: mouse down = first corner/centre, drag = current size, mouse up = commit new shape to document.  
    - **Path tool**: mouse down = start path, drag = lineTo, mouse up = end path (or close on double-click).  
    - **Move**: with selection, drag moves `selectedShape` (update frame/path).  
  - Keyboard: Delete key → remove `selectedShape`, mark document dirty.  
  - Optional: paste (e.g. duplicate selected shape).  
  - Use **NSBezierPath** for all vector drawing; no bitmap buffer.

- **SVMainWindow**  
  - Created in `applicationDidFinishLaunching`.  
  - Content: top tool strip (buttons: Select, Rectangle, Oval, Path; fill/stroke color swatches or “Color…” like SmallPaint).  
  - Below: `NSScrollView` with **SVCanvasView** as document view.  
  - Canvas view’s frame can match document artboard size (e.g. 800×600 for new doc).  
  - Implements New / Open / Save / Save As (or forwards to a controller); uses **SSFileDialog** for open/save; updates window title and dirty state.  
  - New: create new **SVDocument**, set artboard size, assign to canvas view.  
  - Open: run open dialog, read file into **SVDocument**, assign to canvas view.  
  - Save / Save As: serialize **SVDocument** to file (and set path for next Save).

### 4.4 File format (simple)

- Use a trivial format for v1: e.g. **plist** with one array of shape dictionaries.  
  - Each dict: `type` (rect/oval/path), `frame` (rect), `fillColor` (color data), `strokeColor`, `strokeWidth`, and for path `pathData` (e.g. encoded NSBezierPath or list of points).  
- Alternative: simple text format (one line per shape with type and numbers) for readability and git-friendly diffs.  
- Extension: e.g. `.smallvector` or `.svvec`.  
- Register in **SSFileDialog** via `setAllowedFileTypes:@[ @"smallvector" ]` (or chosen extension).

### 4.5 Menus and actions

- **File → New**: same as SmallPaint’s New — new document, clear selection, reset title to “Untitled”.  
- **File → Open…**: SSFileDialog open, then load document and set to canvas.  
- **File → Save**: if path set, write document to path; else run Save As.  
- **File → Save As…**: SSFileDialog save, then write and set path.  
- **File → Quit**: standard Quit (SSMainMenu wires to `terminate:` on NSApp).  
- Optional later: Edit → Duplicate, Delete (can mirror keyboard Delete).

---

## 5. Implementation order

1. **Skeleton app**  
   - `main.m`, `SVAppDelegate`, `GNUmakefile` (link SmallStepLib, no CanvasView).  
   - Menu with New, Open, Save, Save As, Quit.  
   - `SVMainWindow` with fixed-size content view (no canvas yet).  
   - Build and run; confirm menu and window appear.

2. **Core model**  
   - `SVShape` protocol or base class with `drawInRect:`, `containsPoint:`, frame, fill/stroke.  
   - `SVRectShape`, `SVOvalShape` (and optionally `SVPathShape` stub).  
   - `SVDocument`: add/remove shapes, `shapeAtPoint:`, `selectedShape`, dirty flag.

3. **Canvas view**  
   - `SVCanvasView` with a fixed `SVDocument` (e.g. one rect + one oval).  
   - `drawRect:` clears and draws all shapes with NSBezierPath; draw selection outline.  
   - Integrate into `SVMainWindow` inside `NSScrollView`.

4. **Selection and Select tool**  
   - Mouse down on canvas: hit-test, set selection, redraw.  
   - Tool mode: add a “tool” property (select / rect / oval / path) and switch via toolbar.

5. **Rectangle and Oval tools**  
   - Mouse down → start shape at point; mouse drag → resize; mouse up → add to document.  
   - During drag, draw preview (e.g. temporary shape or overlay).

6. **Move and Delete**  
   - With Select tool, drag selected shape (update frame); Delete key removes selected shape.

7. **Path tool (simple)**  
   - Mouse down = start path; drag = line segments; mouse up = finish. Store as `SVPathShape` with NSBezierPath.

8. **New / Open / Save / Save As**  
   - Wire to SSFileDialog; implement serialize/deserialize for `SVDocument` (plist or custom).  
   - Update window title and dirty state like SmallPaint.

9. **Polish**  
   - Fill/stroke color UI (e.g. color panel + swatch like SmallPaint).  
   - Default artboard size for New.  
   - GNUStep-specific tweaks (e.g. key equivalents, focus).

---

## 6. Technical notes

- **GNUStep and ARC**: Follow same pattern as SmallMinesweeper/SmallPaint: `#if defined(GNUSTEP) && !__has_feature(objc_arc)` for `retain`/`release`/`autorelease` and `dealloc`.  
- **NSBezierPath**: Use for rectangles (`bezierPathWithRect:`), ovals (`bezierPathWithOvalInRect:`), and freeform path (`bezierPath`, `moveToPoint:`, `lineToPoint:`, `closePath`). Available in GNUStep AppKit.  
- **Coordinates**: AppKit/GNUStep use bottom-left origin; keep document and canvas coordinates consistent (e.g. canvas bounds = document size, no extra flip unless needed).  
- **SmallStepLib path**: In GNUmakefile use `../SmallStepLib` (sibling of SmallVector); build and install SmallStepLib first, then build SmallVector.

---

## 7. Out of scope for v1

- Layers, groups, z-order (beyond array order).  
- Text tool.  
- Export to SVG/PDF (can be a later step).  
- CanvasView or any bitmap-based drawing from SmallStepLib.

---

## 8. Summary

- Reuse **SmallStepLib** for app lifecycle, menus, window style, and file dialogs; do **not** use its bitmap CanvasView.  
- Implement a **vector document model** (SVDocument + SVShape subclasses) and a **vector canvas view** (SVCanvasView) that draws with **NSBezierPath** and handles selection and simple tools (Select, Rectangle, Oval, Path).  
- Follow the same **main → SSHostApplication → SSAppDelegate → main window** and **GNUmakefile** patterns as SmallPaint and SmallMinesweeper.  
- Keep the first version minimal (early Sketch–style: shapes, selection, move, delete, save/load one file format).
