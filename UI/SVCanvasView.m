//
//  SVCanvasView.m
//  SmallVector
//

#import "SVCanvasView.h"
#import "SVDocument.h"
#import "SVShape.h"
#import "SVRectShape.h"
#import "SVOvalShape.h"
#import "SVPathShape.h"

static const CGFloat kSelectionStrokeWidth = 2.0;

@interface SVCanvasView ()
@property (nonatomic, assign) NSPoint dragStartPoint;
@property (nonatomic, assign) BOOL isDragging;
@property (nonatomic, assign) BOOL isDrawingShape;
#if defined(GNUSTEP) && !__has_feature(objc_arc)
@property (nonatomic, retain) SVShape *previewShape;
@property (nonatomic, retain) NSBezierPath *previewPath;
#else
@property (nonatomic, strong) SVShape *previewShape;
@property (nonatomic, strong) NSBezierPath *previewPath;
#endif
@end

@implementation SVCanvasView

#if defined(GNUSTEP) && !__has_feature(objc_arc)
@synthesize document = _document;
@synthesize tool = _tool;
@synthesize fillColor = _fillColor;
@synthesize strokeColor = _strokeColor;
@synthesize strokeWidth = _strokeWidth;
@synthesize delegate = _delegate;
@synthesize dragStartPoint = _dragStartPoint;
@synthesize isDragging = _isDragging;
@synthesize isDrawingShape = _isDrawingShape;
@synthesize previewShape = _previewShape;
@synthesize previewPath = _previewPath;
#endif

- (instancetype)initWithFrame:(NSRect)frameRect {
    self = [super initWithFrame:frameRect];
    if (self) {
        _tool = SVToolSelect;
        _fillColor = [NSColor whiteColor];
        _strokeColor = [NSColor blackColor];
        _strokeWidth = 1.0;
        _isDragging = NO;
        _isDrawingShape = NO;
        _previewShape = nil;
        _previewPath = nil;
#if defined(GNUSTEP) && !__has_feature(objc_arc)
        [_fillColor retain];
        [_strokeColor retain];
#endif
    }
    return self;
}

#if defined(GNUSTEP) && !__has_feature(objc_arc)
- (void)dealloc {
    [_document release];
    [_fillColor release];
    [_strokeColor release];
    [_previewShape release];
    [_previewPath release];
    [super dealloc];
}
#endif

- (BOOL)acceptsFirstResponder {
    return YES;
}

- (void)drawRect:(NSRect)dirtyRect {
    (void)dirtyRect;
    NSRect bounds = [self bounds];
    [[NSColor whiteColor] setFill];
    NSRectFill(bounds);

    if (!_document) return;

    for (SVShape *shape in [_document shapes]) {
        [shape drawInRect:bounds];
    }

    if (_previewShape) {
        [_previewShape drawInRect:bounds];
    }
    if (_previewPath) {
        [_strokeColor setStroke];
        [_previewPath setLineWidth:_strokeWidth];
        [_previewPath stroke];
    }

    SVShape *sel = [_document selectedShape];
    if (sel) {
        NSRect r = [sel frame];
        [[NSColor keyboardFocusIndicatorColor] setStroke];
        NSBezierPath *outline = [NSBezierPath bezierPathWithRect:NSInsetRect(r, -kSelectionStrokeWidth/2, -kSelectionStrokeWidth/2)];
        [outline setLineWidth:kSelectionStrokeWidth];
        CGFloat dash[] = {4.0, 4.0};
        [outline setLineDash:dash count:2 phase:0];
        [outline stroke];
    }
}

- (void)setDocument:(SVDocument *)document {
#if defined(GNUSTEP) && !__has_feature(objc_arc)
    [_document release];
    _document = [document retain];
#else
    _document = document;
#endif
    if (document) {
        [self setFrameSize:[document artboardSize]];
    }
    [self setNeedsDisplay:YES];
}

- (void)notifyChange {
    [_delegate canvasViewDidChange:self];
}

- (void)mouseDown:(NSEvent *)event {
    NSPoint p = [self convertPoint:[event locationInWindow] fromView:nil];
    [[self window] makeFirstResponder:self];
    if (!_document) return;

    if (_tool == SVToolSelect) {
        SVShape *hit = [_document shapeAtPoint:p];
        [_document setSelectedShape:hit];
        _isDragging = (hit != nil);
        _dragStartPoint = p;
        [self setNeedsDisplay:YES];
        [self notifyChange];
        return;
    }

    if (_tool == SVToolRectangle || _tool == SVToolOval) {
        _isDrawingShape = YES;
        _dragStartPoint = p;
        _previewShape = (_tool == SVToolRectangle) ? [[SVRectShape alloc] init] : [[SVOvalShape alloc] init];
        [_previewShape setFrame:NSMakeRect(p.x, p.y, 0, 0)];
        [_previewShape setFillColor:_fillColor];
        [_previewShape setStrokeColor:_strokeColor];
        [_previewShape setStrokeWidth:_strokeWidth];
        [self setNeedsDisplay:YES];
        return;
    }

    if (_tool == SVToolPath) {
        _previewPath = [[NSBezierPath alloc] init];
        [_previewPath moveToPoint:p];
        [self setNeedsDisplay:YES];
        return;
    }
}

- (void)mouseDragged:(NSEvent *)event {
    NSPoint p = [self convertPoint:[event locationInWindow] fromView:nil];
    if (!_document) return;

    if (_tool == SVToolSelect && _isDragging && [_document selectedShape]) {
        NSPoint delta = NSMakePoint(p.x - _dragStartPoint.x, p.y - _dragStartPoint.y);
        [[_document selectedShape] moveByDelta:delta];
        _dragStartPoint = p;
        [self setNeedsDisplay:YES];
        [self notifyChange];
        return;
    }

    if ((_tool == SVToolRectangle || _tool == SVToolOval) && _isDrawingShape && _previewShape) {
        CGFloat x0 = _dragStartPoint.x, y0 = _dragStartPoint.y;
        CGFloat x1 = p.x, y1 = p.y;
        CGFloat x = (x0 < x1) ? x0 : x1;
        CGFloat y = (y0 < y1) ? y0 : y1;
        CGFloat w = (x0 < x1) ? (x1 - x0) : (x0 - x1);
        CGFloat h = (y0 < y1) ? (y1 - y0) : (y0 - y1);
        [_previewShape setFrame:NSMakeRect(x, y, w, h)];
        [self setNeedsDisplay:YES];
        return;
    }

    if (_tool == SVToolPath && _previewPath) {
        [_previewPath lineToPoint:p];
        [self setNeedsDisplay:YES];
        return;
    }
}

- (void)mouseUp:(NSEvent *)event {
    (void)event;
    if (_tool == SVToolSelect) {
        _isDragging = NO;
        return;
    }

    if ((_tool == SVToolRectangle || _tool == SVToolOval) && _isDrawingShape && _previewShape) {
        NSRect r = [_previewShape frame];
        if (r.size.width > 1 || r.size.height > 1) {
            SVShape *shape = (_tool == SVToolRectangle) ? [[SVRectShape alloc] init] : [[SVOvalShape alloc] init];
            [shape setFrame:r];
            [shape setFillColor:_fillColor];
            [shape setStrokeColor:_strokeColor];
            [shape setStrokeWidth:_strokeWidth];
            [_document addShape:shape];
#if defined(GNUSTEP) && !__has_feature(objc_arc)
            [shape release];
#endif
        }
#if defined(GNUSTEP) && !__has_feature(objc_arc)
        [_previewShape release];
#endif
        _previewShape = nil;
        _isDrawingShape = NO;
        [self setNeedsDisplay:YES];
        [self notifyChange];
        return;
    }

    if (_tool == SVToolPath && _previewPath) {
        if ([_previewPath elementCount] >= 2) {
            SVPathShape *shape = [[SVPathShape alloc] init];
            [shape setPath:_previewPath];
            [shape setFillColor:nil];
            [shape setStrokeColor:_strokeColor];
            [shape setStrokeWidth:_strokeWidth];
            NSRect bounds = [_previewPath bounds];
            [shape setFrame:bounds];
            [_document addShape:shape];
#if defined(GNUSTEP) && !__has_feature(objc_arc)
            [shape release];
#endif
        }
#if defined(GNUSTEP) && !__has_feature(objc_arc)
        [_previewPath release];
#endif
        _previewPath = nil;
        [self setNeedsDisplay:YES];
        [self notifyChange];
        return;
    }
}

- (void)keyDown:(NSEvent *)event {
    NSString *chars = [event characters];
    unichar c = ([chars length] > 0) ? [chars characterAtIndex:0] : 0;
    if (c == NSDeleteCharacter || c == NSBackspaceCharacter) {
        if (_document && [_document selectedShape]) {
            [_document removeSelectedShape];
            [self setNeedsDisplay:YES];
            [self notifyChange];
            return;
        }
    }
    [super keyDown:event];
}

@end
