//
//  SVShape.h
//  SmallVector
//
//  Abstract base for vector shapes (rect, oval, path). Draw with NSBezierPath; hit-test.
//

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>

#if defined(GNUSTEP) && !__has_feature(objc_arc)
#  define SV_RETAIN retain
#  define SV_ASSIGN assign
#else
#  define SV_RETAIN strong
#  define SV_ASSIGN weak
#endif

@interface SVShape : NSObject {
#if defined(GNUSTEP) && !__has_feature(objc_arc)
    NSRect _frame;
    NSColor *_fillColor;
    NSColor *_strokeColor;
    CGFloat _strokeWidth;
#endif
}

@property (nonatomic, assign) NSRect frame;
@property (nonatomic, SV_RETAIN) NSColor *fillColor;
@property (nonatomic, SV_RETAIN) NSColor *strokeColor;
@property (nonatomic, assign) CGFloat strokeWidth;

/// Draw the shape in the given rect (canvas coordinates). Subclasses override.
- (void)drawInRect:(NSRect)bounds;

/// Hit-test: does the point (in canvas coords) lie inside the shape?
- (BOOL)containsPoint:(NSPoint)point;

/// Move shape by delta (e.g. for drag).
- (void)moveByDelta:(NSPoint)delta;

/// Serialize to plist-friendly dictionary for save.
- (NSDictionary *)dictionaryRepresentation;

/// Load common properties from dict (frame, fillColor, strokeColor, strokeWidth). Subclasses call and then load their own.
- (void)loadFromDictionary:(NSDictionary *)dict;

/// Create shape from plist dictionary (class method on concrete subclass).
+ (instancetype)shapeFromDictionary:(NSDictionary *)dict;

@end
