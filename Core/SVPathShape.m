//
//  SVPathShape.m
//  SmallVector
//

#import "SVPathShape.h"

@implementation SVPathShape

#if defined(GNUSTEP) && !__has_feature(objc_arc)
@synthesize path = _path;
#endif

- (instancetype)init {
    self = [super init];
    if (self) {
        _path = [[NSBezierPath alloc] init];
    }
    return self;
}

- (void)drawInRect:(NSRect)bounds {
    (void)bounds;
    if (!_path) return;
    if (_fillColor) {
        [_fillColor setFill];
        [_path fill];
    }
    if (_strokeColor && _strokeWidth > 0) {
        [_strokeColor setStroke];
        [_path setLineWidth:_strokeWidth];
        [_path stroke];
    }
}

- (BOOL)containsPoint:(NSPoint)point {
    if (!_path) return NO;
    return [_path containsPoint:point];
}

- (void)moveByDelta:(NSPoint)delta {
    [super moveByDelta:delta];
    if (_path) {
        NSAffineTransform *t = [NSAffineTransform transform];
        [t translateXBy:delta.x yBy:delta.y];
        [_path transformUsingAffineTransform:t];
    }
}

- (NSDictionary *)dictionaryRepresentation {
    NSMutableDictionary *d = [NSMutableDictionary dictionaryWithDictionary:[super dictionaryRepresentation]];
    [d setObject:@"path" forKey:@"type"];
    if (_path) {
        NSMutableArray *points = [NSMutableArray array];
        NSInteger count = [_path elementCount];
        NSPoint pts[3];
        NSInteger i;
        for (i = 0; i < count; i++) {
            NSBezierPathElement kind = [_path elementAtIndex:i associatedPoints:pts];
            if (kind == NSMoveToBezierPathElement || kind == NSLineToBezierPathElement) {
                [points addObject:[NSArray arrayWithObjects:
                    [NSNumber numberWithDouble:(double)pts[0].x],
                    [NSNumber numberWithDouble:(double)pts[0].y], nil]];
            } else if (kind == NSCurveToBezierPathElement) {
                [points addObject:[NSArray arrayWithObjects:
                    [NSNumber numberWithDouble:(double)pts[2].x],
                    [NSNumber numberWithDouble:(double)pts[2].y], nil]];
            }
        }
        [d setObject:points forKey:@"points"];
    }
    return d;
}

+ (instancetype)shapeFromDictionary:(NSDictionary *)dict {
    SVPathShape *shape = [[SVPathShape alloc] init];
    [shape loadFromDictionary:dict];
    return [shape autorelease];
}

- (void)loadFromDictionary:(NSDictionary *)dict {
    [super loadFromDictionary:dict];
    NSArray *points = [dict objectForKey:@"points"];
    if ([points count] > 0) {
        NSBezierPath *p = [NSBezierPath bezierPath];
        NSInteger i;
        for (i = 0; i < [points count]; i++) {
            NSArray *pt = [points objectAtIndex:i];
            if ([pt count] >= 2) {
                NSPoint np = NSMakePoint([[pt objectAtIndex:0] floatValue], [[pt objectAtIndex:1] floatValue]);
                if (i == 0)
                    [p moveToPoint:np];
                else
                    [p lineToPoint:np];
            }
        }
#if defined(GNUSTEP) && !__has_feature(objc_arc)
        [_path release];
#endif
        _path = [p retain];
    }
}

#if defined(GNUSTEP) && !__has_feature(objc_arc)
- (void)dealloc {
    [_path release];
    [super dealloc];
}
#endif

@end
