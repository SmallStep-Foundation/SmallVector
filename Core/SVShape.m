//
//  SVShape.m
//  SmallVector
//

#import "SVShape.h"

@implementation SVShape

#if defined(GNUSTEP) && !__has_feature(objc_arc)
@synthesize frame = _frame;
@synthesize fillColor = _fillColor;
@synthesize strokeColor = _strokeColor;
@synthesize strokeWidth = _strokeWidth;
#endif

- (instancetype)init {
    self = [super init];
    if (self) {
        _frame = NSZeroRect;
        _fillColor = [NSColor whiteColor];
        _strokeColor = [NSColor blackColor];
        _strokeWidth = 1.0;
#if defined(GNUSTEP) && !__has_feature(objc_arc)
        [_fillColor retain];
        [_strokeColor retain];
#endif
    }
    return self;
}

- (void)drawInRect:(NSRect)bounds {
    (void)bounds;
    // Subclasses override
}

- (BOOL)containsPoint:(NSPoint)point {
    (void)point;
    return NSMouseInRect(point, _frame, NO);
}

- (void)moveByDelta:(NSPoint)delta {
    _frame.origin.x += delta.x;
    _frame.origin.y += delta.y;
}

- (NSDictionary *)dictionaryRepresentation {
    NSMutableDictionary *d = [NSMutableDictionary dictionary];
    [d setObject:NSStringFromRect(NSRectToCGRect(_frame)) forKey:@"frame"];
    if (_fillColor) {
        CGFloat r, g, b, a;
        [[_fillColor colorUsingColorSpaceName:NSDeviceRGBColorSpace] getRed:&r green:&g blue:&b alpha:&a];
        [d setObject:[NSArray arrayWithObjects:
            [NSNumber numberWithDouble:(double)r],
            [NSNumber numberWithDouble:(double)g],
            [NSNumber numberWithDouble:(double)b],
            [NSNumber numberWithDouble:(double)a], nil] forKey:@"fillColor"];
    }
    if (_strokeColor) {
        CGFloat r, g, b, a;
        [[_strokeColor colorUsingColorSpaceName:NSDeviceRGBColorSpace] getRed:&r green:&g blue:&b alpha:&a];
        [d setObject:[NSArray arrayWithObjects:
            [NSNumber numberWithDouble:(double)r],
            [NSNumber numberWithDouble:(double)g],
            [NSNumber numberWithDouble:(double)b],
            [NSNumber numberWithDouble:(double)a], nil] forKey:@"strokeColor"];
    }
    [d setObject:[NSNumber numberWithDouble:(double)_strokeWidth] forKey:@"strokeWidth"];
    return d;
}

- (void)loadFromDictionary:(NSDictionary *)dict {
    NSString *frameStr = [dict objectForKey:@"frame"];
    if (frameStr) _frame = NSRectFromString(frameStr);
    NSArray *fill = [dict objectForKey:@"fillColor"];
    if ([fill count] >= 4) {
        NSColor *c = [NSColor colorWithCalibratedRed:[[fill objectAtIndex:0] floatValue]
                                              green:[[fill objectAtIndex:1] floatValue]
                                               blue:[[fill objectAtIndex:2] floatValue]
                                              alpha:[[fill objectAtIndex:3] floatValue]];
#if defined(GNUSTEP) && !__has_feature(objc_arc)
        [_fillColor release];
        _fillColor = [c retain];
#else
        _fillColor = c;
#endif
    }
    NSArray *stroke = [dict objectForKey:@"strokeColor"];
    if ([stroke count] >= 4) {
        NSColor *c = [NSColor colorWithCalibratedRed:[[stroke objectAtIndex:0] floatValue]
                                              green:[[stroke objectAtIndex:1] floatValue]
                                               blue:[[stroke objectAtIndex:2] floatValue]
                                              alpha:[[stroke objectAtIndex:3] floatValue]];
#if defined(GNUSTEP) && !__has_feature(objc_arc)
        [_strokeColor release];
        _strokeColor = [c retain];
#else
        _strokeColor = c;
#endif
    }
    NSNumber *w = [dict objectForKey:@"strokeWidth"];
    if (w) _strokeWidth = [w floatValue];
}

#if defined(GNUSTEP) && !__has_feature(objc_arc)
- (void)dealloc {
    [_fillColor release];
    [_strokeColor release];
    [super dealloc];
}
#endif

@end
