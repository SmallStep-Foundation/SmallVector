//
//  SVCanvasView.h
//  SmallVector
//
//  NSView that draws SVDocument shapes and handles selection, tools, mouse/keyboard.
//

#import "SVShape.h"

#if defined(GNUSTEP) && !__has_feature(objc_arc)
#  define SV_RETAIN retain
#  define SV_ASSIGN assign
#else
#  define SV_RETAIN strong
#  define SV_ASSIGN weak
#endif

@class SVDocument;

@class SVCanvasView;

@protocol SVCanvasViewDelegate <NSObject>
@optional
- (void)canvasViewDidChange:(SVCanvasView *)canvasView;
@end

typedef NS_ENUM(NSInteger, SVTool) {
    SVToolSelect = 0,
    SVToolRectangle,
    SVToolOval,
    SVToolPath
};

@interface SVCanvasView : NSView {
#if defined(GNUSTEP) && !__has_feature(objc_arc)
    SVDocument *_document;
    SVTool _tool;
    NSColor *_fillColor;
    NSColor *_strokeColor;
    CGFloat _strokeWidth;
    id _delegate;
    NSPoint _dragStartPoint;
    BOOL _isDragging;
    BOOL _isDrawingShape;
    SVShape *_previewShape;
    NSBezierPath *_previewPath;
#endif
}

@property (nonatomic, SV_RETAIN) SVDocument *document;
@property (nonatomic, assign) SVTool tool;
@property (nonatomic, SV_RETAIN) NSColor *fillColor;
@property (nonatomic, SV_RETAIN) NSColor *strokeColor;
@property (nonatomic, assign) CGFloat strokeWidth;
#if defined(GNUSTEP) && !__has_feature(objc_arc)
@property (nonatomic, assign) id<SVCanvasViewDelegate> delegate;
#else
@property (nonatomic, weak) id<SVCanvasViewDelegate> delegate;
#endif

@end
