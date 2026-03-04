//
//  SVOvalShape.m
//  SmallVector
//

#import "SVOvalShape.h"

@implementation SVOvalShape

- (void)drawInRect:(NSRect)bounds {
    (void)bounds;
    NSBezierPath *path = [NSBezierPath bezierPathWithOvalInRect:_frame];
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
    [d setObject:@"oval" forKey:@"type"];
    return d;
}

+ (instancetype)shapeFromDictionary:(NSDictionary *)dict {
    SVOvalShape *shape = [[SVOvalShape alloc] init];
    [shape loadFromDictionary:dict];
    return [shape autorelease];
}

@end
