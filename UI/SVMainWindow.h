//
//  SVMainWindow.h
//  SmallVector
//
//  Main window: tool strip, canvas in scroll view. Handles New/Open/Save via SSFileDialog.
//

#import <AppKit/AppKit.h>

@class SVDocument, SVCanvasView, ColorSwatchView;

@interface SVMainWindow : NSWindow {
#if defined(GNUSTEP) && !__has_feature(objc_arc)
    NSScrollView *_scrollView;
    SVCanvasView *_canvasView;
    SVDocument *_document;
    NSView *_toolStrip;
    NSButton *_selectButton;
    NSButton *_rectButton;
    NSButton *_ovalButton;
    NSButton *_pathButton;
    ColorSwatchView *_fillSwatch;
    ColorSwatchView *_strokeSwatch;
    NSButton *_fillColorButton;
    NSButton *_strokeColorButton;
    NSString *_documentPath;
#endif
}

- (void)newDocument;
- (void)openDocument;
- (void)saveDocument;
- (void)saveDocumentAs;

@end
