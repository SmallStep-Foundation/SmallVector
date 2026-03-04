//
//  SVMainWindow.m
//  SmallVector
//

#import "SVMainWindow.h"
#import "SVCanvasView.h"
#import "SVDocument.h"
#import "SSWindowStyle.h"
#import "SSFileDialog.h"

static const CGFloat kToolStripHeight = 36.0;
static const CGFloat kMargin = 8.0;

@interface ColorSwatchView : NSView {
#if defined(GNUSTEP) && !__has_feature(objc_arc)
    NSColor *_fillColor;
#endif
}
#if defined(GNUSTEP) && !__has_feature(objc_arc)
@property (nonatomic, retain) NSColor *fillColor;
#else
@property (nonatomic, strong) NSColor *fillColor;
#endif
@end
@implementation ColorSwatchView

#if defined(GNUSTEP) && !__has_feature(objc_arc)
@synthesize fillColor = _fillColor;
#endif

- (void)drawRect:(NSRect)dirtyRect {
    (void)dirtyRect;
    NSColor *c = _fillColor ?: [NSColor blackColor];
    [c setFill];
    NSRectFill([self bounds]);
    [[NSColor grayColor] setStroke];
    NSFrameRect([self bounds]);
}
@end

@interface SVMainWindow () <SVCanvasViewDelegate>
#if defined(GNUSTEP) && !__has_feature(objc_arc)
@property (nonatomic, retain) NSScrollView *scrollView;
@property (nonatomic, retain) SVCanvasView *canvasView;
@property (nonatomic, retain) SVDocument *document;
@property (nonatomic, retain) NSView *toolStrip;
@property (nonatomic, retain) NSButton *selectButton;
@property (nonatomic, retain) NSButton *rectButton;
@property (nonatomic, retain) NSButton *ovalButton;
@property (nonatomic, retain) NSButton *pathButton;
@property (nonatomic, retain) ColorSwatchView *fillSwatch;
@property (nonatomic, retain) ColorSwatchView *strokeSwatch;
@property (nonatomic, retain) NSButton *fillColorButton;
@property (nonatomic, retain) NSButton *strokeColorButton;
@property (nonatomic, copy) NSString *documentPath;
@end
#else
@property (nonatomic, strong) NSScrollView *scrollView;
@property (nonatomic, strong) SVCanvasView *canvasView;
@property (nonatomic, strong) SVDocument *document;
@property (nonatomic, strong) NSView *toolStrip;
@property (nonatomic, strong) NSButton *selectButton;
@property (nonatomic, strong) NSButton *rectButton;
@property (nonatomic, strong) NSButton *ovalButton;
@property (nonatomic, strong) NSButton *pathButton;
@property (nonatomic, strong) ColorSwatchView *fillSwatch;
@property (nonatomic, strong) ColorSwatchView *strokeSwatch;
@property (nonatomic, strong) NSButton *fillColorButton;
@property (nonatomic, strong) NSButton *strokeColorButton;
@property (nonatomic, copy) NSString *documentPath;
@end
#endif

@implementation SVMainWindow

#if defined(GNUSTEP) && !__has_feature(objc_arc)
@synthesize scrollView = _scrollView;
@synthesize canvasView = _canvasView;
@synthesize document = _document;
@synthesize toolStrip = _toolStrip;
@synthesize selectButton = _selectButton;
@synthesize rectButton = _rectButton;
@synthesize ovalButton = _ovalButton;
@synthesize pathButton = _pathButton;
@synthesize fillSwatch = _fillSwatch;
@synthesize strokeSwatch = _strokeSwatch;
@synthesize fillColorButton = _fillColorButton;
@synthesize strokeColorButton = _strokeColorButton;
@synthesize documentPath = _documentPath;
#endif

- (instancetype)init {
    NSUInteger style = [SSWindowStyle standardWindowMask];
    NSRect frame = NSMakeRect(100, 100, 800, 640);
    self = [super initWithContentRect:frame
                            styleMask:style
                              backing:NSBackingStoreBuffered
                                defer:NO];
    if (self) {
        [self setTitle:@"Untitled - SmallVector"];
        [self setReleasedWhenClosed:NO];
        _documentPath = nil;
        _document = [[SVDocument alloc] init];
        [self buildContent];
    }
    return self;
}

#if defined(GNUSTEP) && !__has_feature(objc_arc)
- (void)dealloc {
    [_scrollView release];
    [_canvasView release];
    [_document release];
    [_toolStrip release];
    [_selectButton release];
    [_rectButton release];
    [_ovalButton release];
    [_pathButton release];
    [_fillSwatch release];
    [_strokeSwatch release];
    [_fillColorButton release];
    [_strokeColorButton release];
    [_documentPath release];
    [super dealloc];
}
#endif

- (void)buildContent {
    NSView *content = [self contentView];
    NSRect contentBounds = [content bounds];
    CGFloat stripY = contentBounds.size.height - kToolStripHeight - kMargin;

    _toolStrip = [[NSView alloc] initWithFrame:NSMakeRect(0, stripY, contentBounds.size.width, kToolStripHeight)];
    [_toolStrip setAutoresizingMask:NSViewWidthSizable | NSViewMinYMargin];
    [content addSubview:_toolStrip];

    CGFloat x = kMargin;
    _selectButton = [[NSButton alloc] initWithFrame:NSMakeRect(x, 4, 60, 28)];
    [_selectButton setTitle:@"Select"];
    [_selectButton setButtonType:NSMomentaryPushInButton];
    [_selectButton setBezelStyle:NSRoundedBezelStyle];
    [_selectButton setTarget:self];
    [_selectButton setAction:@selector(selectTool:)];
    [_selectButton setTag:SVToolSelect];
    [_toolStrip addSubview:_selectButton];
    x += 68;

    _rectButton = [[NSButton alloc] initWithFrame:NSMakeRect(x, 4, 70, 28)];
    [_rectButton setTitle:@"Rectangle"];
    [_rectButton setButtonType:NSMomentaryPushInButton];
    [_rectButton setBezelStyle:NSRoundedBezelStyle];
    [_rectButton setTarget:self];
    [_rectButton setAction:@selector(selectTool:)];
    [_rectButton setTag:SVToolRectangle];
    [_toolStrip addSubview:_rectButton];
    x += 78;

    _ovalButton = [[NSButton alloc] initWithFrame:NSMakeRect(x, 4, 50, 28)];
    [_ovalButton setTitle:@"Oval"];
    [_ovalButton setButtonType:NSMomentaryPushInButton];
    [_ovalButton setBezelStyle:NSRoundedBezelStyle];
    [_ovalButton setTarget:self];
    [_ovalButton setAction:@selector(selectTool:)];
    [_ovalButton setTag:SVToolOval];
    [_toolStrip addSubview:_ovalButton];
    x += 58;

    _pathButton = [[NSButton alloc] initWithFrame:NSMakeRect(x, 4, 50, 28)];
    [_pathButton setTitle:@"Path"];
    [_pathButton setButtonType:NSMomentaryPushInButton];
    [_pathButton setBezelStyle:NSRoundedBezelStyle];
    [_pathButton setTarget:self];
    [_pathButton setAction:@selector(selectTool:)];
    [_pathButton setTag:SVToolPath];
    [_toolStrip addSubview:_pathButton];
    x += 58;

    _fillSwatch = [[ColorSwatchView alloc] initWithFrame:NSMakeRect(x, 6, 22, 22)];
    [_fillSwatch setFillColor:[NSColor whiteColor]];
    [_toolStrip addSubview:_fillSwatch];
    _fillColorButton = [[NSButton alloc] initWithFrame:NSMakeRect(x + 26, 4, 52, 28)];
    [_fillColorButton setTitle:@"Fill…"];
    [_fillColorButton setButtonType:NSMomentaryPushInButton];
    [_fillColorButton setBezelStyle:NSRoundedBezelStyle];
    [_fillColorButton setTarget:self];
    [_fillColorButton setAction:@selector(chooseFillColor:)];
    [_toolStrip addSubview:_fillColorButton];
    x += 86;

    _strokeSwatch = [[ColorSwatchView alloc] initWithFrame:NSMakeRect(x, 6, 22, 22)];
    [_strokeSwatch setFillColor:[NSColor blackColor]];
    [_toolStrip addSubview:_strokeSwatch];
    _strokeColorButton = [[NSButton alloc] initWithFrame:NSMakeRect(x + 26, 4, 58, 28)];
    [_strokeColorButton setTitle:@"Stroke…"];
    [_strokeColorButton setButtonType:NSMomentaryPushInButton];
    [_strokeColorButton setBezelStyle:NSRoundedBezelStyle];
    [_strokeColorButton setTarget:self];
    [_strokeColorButton setAction:@selector(chooseStrokeColor:)];
    [_toolStrip addSubview:_strokeColorButton];

    NSRect scrollFrame = NSMakeRect(0, 0, contentBounds.size.width, stripY);
    _scrollView = [[NSScrollView alloc] initWithFrame:scrollFrame];
    [_scrollView setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
    [_scrollView setHasVerticalScroller:YES];
    [_scrollView setHasHorizontalScroller:YES];
    [_scrollView setBorderType:NSBezelBorder];
    [_scrollView setAutohidesScrollers:YES];

    _canvasView = [[SVCanvasView alloc] initWithFrame:NSZeroRect];
    [_canvasView setDocument:_document];
    [_canvasView setDelegate:self];
    [_canvasView setFillColor:[NSColor whiteColor]];
    [_canvasView setStrokeColor:[NSColor blackColor]];
    [_scrollView setDocumentView:_canvasView];
    [content addSubview:_scrollView];

#if defined(GNUSTEP) && !__has_feature(objc_arc)
    [_scrollView release];
    [_canvasView release];
    [_toolStrip release];
    [_selectButton release];
    [_rectButton release];
    [_ovalButton release];
    [_pathButton release];
    [_fillSwatch release];
    [_strokeSwatch release];
    [_fillColorButton release];
    [_strokeColorButton release];
#endif
}

- (void)selectTool:(id)sender {
    NSInteger tag = [sender tag];
    [_canvasView setTool:(SVTool)tag];
}

- (void)chooseFillColor:(id)sender {
    (void)sender;
    NSColorPanel *panel = [NSColorPanel sharedColorPanel];
    [panel setColor:[_canvasView fillColor]];
    [panel setTarget:self];
    [panel setAction:@selector(fillColorPanelChanged:)];
    [panel orderFront:nil];
}

- (void)fillColorPanelChanged:(id)sender {
    if ([sender isKindOfClass:[NSColorPanel class]]) {
        NSColor *c = [(NSColorPanel *)sender color];
        [_canvasView setFillColor:c];
        [_fillSwatch setFillColor:c];
        [_fillSwatch setNeedsDisplay:YES];
    }
}

- (void)chooseStrokeColor:(id)sender {
    (void)sender;
    NSColorPanel *panel = [NSColorPanel sharedColorPanel];
    [panel setColor:[_canvasView strokeColor]];
    [panel setTarget:self];
    [panel setAction:@selector(strokeColorPanelChanged:)];
    [panel orderFront:nil];
}

- (void)strokeColorPanelChanged:(id)sender {
    if ([sender isKindOfClass:[NSColorPanel class]]) {
        NSColor *c = [(NSColorPanel *)sender color];
        [_canvasView setStrokeColor:c];
        [_strokeSwatch setFillColor:c];
        [_strokeSwatch setNeedsDisplay:YES];
    }
}

- (void)canvasViewDidChange:(SVCanvasView *)canvasView {
    (void)canvasView;
    [self updateTitle];
}

- (void)updateTitle {
    NSString *name = _documentPath ? [_documentPath lastPathComponent] : @"Untitled";
    if ([_document dirty]) name = [name stringByAppendingString:@" *"];
    [self setTitle:[NSString stringWithFormat:@"%@ - SmallVector", name]];
}

- (void)newDocument {
    SVDocument *doc = [[SVDocument alloc] init];
#if defined(GNUSTEP) && !__has_feature(objc_arc)
    [_document release];
#endif
    _document = doc;
    [_canvasView setDocument:_document];
    _documentPath = nil;
    [self setTitle:@"Untitled - SmallVector"];
}

- (void)openDocument {
    SSFileDialog *dialog = [SSFileDialog openDialog];
    [dialog setAllowedFileTypes:[NSArray arrayWithObject:@"smallvector"]];
    NSArray *urls = [dialog showModal];
    if (!urls || [urls count] == 0) return;
    NSURL *url = [urls objectAtIndex:0];
    NSString *path = [url path];
    if (!path.length) return;
    NSError *err = nil;
    SVDocument *doc = [[SVDocument alloc] init];
    if ([doc readFromFile:path error:&err]) {
#if defined(GNUSTEP) && !__has_feature(objc_arc)
        [_document release];
#endif
        _document = doc;
        [_canvasView setDocument:_document];
#if defined(GNUSTEP) && !__has_feature(objc_arc)
        [_documentPath release];
        _documentPath = [path copy];
#else
        _documentPath = [path copy];
#endif
        [self updateTitle];
    } else {
#if defined(GNUSTEP) && !__has_feature(objc_arc)
        [doc release];
#endif
    }
}

- (void)saveDocument {
    if (_documentPath.length) {
        NSError *err = nil;
        if ([_document writeToFile:_documentPath error:&err]) {
            [_document setDirty:NO];
            [self updateTitle];
        }
        return;
    }
    [self saveDocumentAs];
}

- (void)saveDocumentAs {
    SSFileDialog *dialog = [SSFileDialog saveDialog];
    [dialog setAllowedFileTypes:[NSArray arrayWithObject:@"smallvector"]];
    NSArray *urls = [dialog showModal];
    if (!urls || [urls count] == 0) return;
    NSURL *url = [urls objectAtIndex:0];
    NSString *path = [url path];
    if (!path.length) return;
    if (![[path pathExtension] length])
        path = [path stringByAppendingPathExtension:@"smallvector"];
    NSError *err = nil;
    if ([_document writeToFile:path error:&err]) {
#if defined(GNUSTEP) && !__has_feature(objc_arc)
        [_documentPath release];
        _documentPath = [path copy];
#else
        _documentPath = [path copy];
#endif
        [_document setDirty:NO];
        [self updateTitle];
    }
}

@end
