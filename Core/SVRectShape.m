//
//  SVRectShape.m
//  SmallVector
//

#import "SVRectShape.h"

@implementation SVRectShape

- (void)drawInRect:(NSRect)bounds {
    (void)bounds;
    NSBezierPath *path = [NSBezierPath bezierPathWithRect:_frame];
    if (_fillColor) {
        [_fillColor setFill];
        [path fill];
    }
    if (_strokeColor && _strokeWidth > 0) {
        [_strokeColor setStroke];
        [path setLineWidth:_strokeWidth];
        [path stroke];
    }
}

- (NSDictionary *)dictionaryRepresentation {
    NSMutableDictionary *d = [NSMutableDictionary dictionaryWithDictionary:[super dictionaryRepresentation]];
    [d setObject:@"rect" forKey:@"type"];
    return d;
}

+ (instancetype)shapeFromDictionary:(NSDictionary *)dict {
    SVRectShape *shape = [[SVRectShape alloc] init];
    [shape loadFromDictionary:dict];
    return [shape autorelease];
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
#endif
        _fillColor = [c retain];
    }
    NSArray *stroke = [dict objectForKey:@"strokeColor"];
    if ([stroke count] >= 4) {
        NSColor *c = [NSColor colorWithCalibratedRed:[[stroke objectAtIndex:0] floatValue]
                                              green:[[stroke objectAtIndex:1] floatValue]
                                               blue:[[stroke objectAtIndex:2] floatValue]
                                              alpha:[[stroke objectAtIndex:3] floatValue]];
#if defined(GNUSTEP) && !__has_feature(objc_arc)
        [_strokeColor release];
#endif
        _strokeColor = [c retain];
    }
    NSNumber *w = [dict objectForKey:@"strokeWidth"];
    if (w) _strokeWidth = [w floatValue];
}

@end
