//
//  SVDocument.m
//  SmallVector
//

#import "SVDocument.h"
#import "SVShape.h"
#import "SVRectShape.h"
#import "SVOvalShape.h"
#import "SVPathShape.h"
#if defined(GNUSTEP)
#import <errno.h>
#import <string.h>
#endif

static const CGFloat kDefaultArtboardWidth = 800.0;
static const CGFloat kDefaultArtboardHeight = 600.0;

@implementation SVDocument
#if !defined(GNUSTEP) || __has_feature(objc_arc)
{
    NSMutableArray *_shapes;
}
#endif

#if defined(GNUSTEP) && !__has_feature(objc_arc)
@synthesize artboardSize = _artboardSize;
@synthesize dirty = _dirty;
@synthesize selectedShape = _selectedShape;
#endif

- (instancetype)init {
    self = [super init];
    if (self) {
        _shapes = [[NSMutableArray alloc] init];
        _artboardSize = NSMakeSize(kDefaultArtboardWidth, kDefaultArtboardHeight);
        _dirty = NO;
        _selectedShape = nil;
    }
    return self;
}

- (NSArray *)shapes {
    return _shapes;
}

- (void)addShape:(SVShape *)shape {
    [_shapes addObject:shape];
    _dirty = YES;
}

- (void)removeShape:(SVShape *)shape {
    if (_selectedShape == shape) _selectedShape = nil;
    [_shapes removeObject:shape];
    _dirty = YES;
}

- (void)removeSelectedShape {
    if (_selectedShape) {
        [self removeShape:_selectedShape];
    }
}

- (SVShape *)shapeAtPoint:(NSPoint)point {
    NSInteger i;
    for (i = [_shapes count] - 1; i >= 0; i--) {
        SVShape *s = [_shapes objectAtIndex:i];
        if ([s containsPoint:point]) return s;
    }
    return nil;
}

- (BOOL)writeToFile:(NSString *)path error:(NSError **)outError {
    NSMutableArray *arr = [NSMutableArray array];
    for (SVShape *shape in _shapes) {
        [arr addObject:[shape dictionaryRepresentation]];
    }
    NSDictionary *root = [NSDictionary dictionaryWithObjectsAndKeys:
        arr, @"shapes",
        [NSNumber numberWithDouble:(double)_artboardSize.width], @"width",
        [NSNumber numberWithDouble:(double)_artboardSize.height], @"height",
        nil];
    NSData *data = [NSPropertyListSerialization dataWithPropertyList:root
                                                              format:NSPropertyListXMLFormat_v1_0
                                                             options:0
                                                               error:outError];
    if (!data) return NO;
#if defined(GNUSTEP)
    return [data writeToFile:path atomically:YES];
#else
    return [data writeToFile:path options:NSDataWritingAtomic error:outError];
#endif
}

#pragma mark - SVG export

static NSString *SVHexColor(NSColor *color) {
    if (!color) return @"none";
    NSColor *rgb = [color colorUsingColorSpaceName:NSDeviceRGBColorSpace];
    if (!rgb) return @"none";
    CGFloat r, g, b, a;
    [rgb getRed:&r green:&g blue:&b alpha:&a];
    if (a < 0.01) return @"none";
    return [NSString stringWithFormat:@"#%02x%02x%02x",
        (int)(r * 255.0 + 0.5), (int)(g * 255.0 + 0.5), (int)(b * 255.0 + 0.5)];
}

static NSString *SVCommonAttrs(SVShape *shape) {
    return [NSString stringWithFormat:@"fill=\"%@\" stroke=\"%@\" stroke-width=\"%g\"",
        SVHexColor([shape fillColor]), SVHexColor([shape strokeColor]), [shape strokeWidth]];
}

- (NSString *)svgElementForShape:(SVShape *)shape {
    if ([shape isKindOfClass:[SVRectShape class]]) {
        NSRect f = [shape frame];
        return [NSString stringWithFormat:@"<rect x=\"%g\" y=\"%g\" width=\"%g\" height=\"%g\" %@/>",
            f.origin.x, f.origin.y, f.size.width, f.size.height, SVCommonAttrs(shape)];
    }
    if ([shape isKindOfClass:[SVOvalShape class]]) {
        NSRect f = [shape frame];
        return [NSString stringWithFormat:@"<ellipse cx=\"%g\" cy=\"%g\" rx=\"%g\" ry=\"%g\" %@/>",
            f.origin.x + f.size.width / 2.0, f.origin.y + f.size.height / 2.0,
            f.size.width / 2.0, f.size.height / 2.0, SVCommonAttrs(shape)];
    }
    if ([shape isKindOfClass:[SVPathShape class]]) {
        SVPathShape *p = (SVPathShape *)shape;
        NSBezierPath *bp = [p path];
        NSMutableString *d = [NSMutableString string];
        NSInteger count = bp ? [bp elementCount] : 0;
        NSInteger i;
        for (i = 0; i < count; i++) {
            NSPoint pts[3];
            NSBezierPathElement kind = [bp elementAtIndex:i associatedPoints:pts];
            switch (kind) {
                case NSMoveToBezierPathElement:
                    [d appendFormat:@"M %g %g ", pts[0].x, pts[0].y];
                    break;
                case NSLineToBezierPathElement:
                    [d appendFormat:@"L %g %g ", pts[0].x, pts[0].y];
                    break;
                case NSCurveToBezierPathElement:
                    [d appendFormat:@"C %g %g %g %g %g %g ",
                        pts[0].x, pts[0].y, pts[1].x, pts[1].y, pts[2].x, pts[2].y];
                    break;
                case NSClosePathBezierPathElement:
                    [d appendString:@"Z "];
                    break;
                default:
                    break;
            }
        }
        return [NSString stringWithFormat:@"<path d=\"%@\" %@/>", d, SVCommonAttrs(shape)];
    }
    return @"";
}

- (NSString *)svgString {
    NSMutableString *s = [NSMutableString string];
    [s appendString:@"<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"];
    [s appendFormat:@"<svg xmlns=\"http://www.w3.org/2000/svg\" width=\"%g\" height=\"%g\" viewBox=\"0 0 %g %g\">\n",
        _artboardSize.width, _artboardSize.height, _artboardSize.width, _artboardSize.height];
    for (SVShape *shape in _shapes) {
        NSString *el = [self svgElementForShape:shape];
        if ([el length])
            [s appendFormat:@"  %@\n", el];
    }
    [s appendString:@"</svg>\n"];
    return s;
}

- (BOOL)writeSVGToPath:(NSString *)path error:(NSError **)outError {
    NSData *data = [[self svgString] dataUsingEncoding:NSUTF8StringEncoding];
    BOOL ok = data != nil && [data writeToFile:path atomically:YES];
    if (!ok && outError)
        *outError = [NSError errorWithDomain:NSCocoaErrorDomain code:NSFileWriteUnknownError userInfo:nil];
    return ok;
}

- (BOOL)readFromFile:(NSString *)path error:(NSError **)outError {
#if defined(GNUSTEP)
    NSData *data = [NSData dataWithContentsOfFile:path];
    if (!data && outError) {
        *outError = [NSError errorWithDomain:NSPOSIXErrorDomain code:errno userInfo:
            [NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"Failed to read file: %s", strerror(errno)] forKey:NSLocalizedDescriptionKey]];
    }
#else
    NSData *data = [NSData dataWithContentsOfFile:path options:0 error:outError];
#endif
    if (!data) return NO;
    NSDictionary *root = [NSPropertyListSerialization propertyListWithData:data
                                                                    options:NSPropertyListImmutable
                                                                     format:NULL
                                                                      error:outError];
    if (![root isKindOfClass:[NSDictionary class]]) return NO;
    [_shapes removeAllObjects];
    _selectedShape = nil;
    NSArray *arr = [root objectForKey:@"shapes"];
    if ([arr isKindOfClass:[NSArray class]]) {
        for (NSDictionary *dict in arr) {
            if (![dict isKindOfClass:[NSDictionary class]]) continue;
            NSString *type = [dict objectForKey:@"type"];
            SVShape *shape = nil;
            if ([type isEqualToString:@"rect"])
                shape = [SVRectShape shapeFromDictionary:dict];
            else if ([type isEqualToString:@"oval"])
                shape = [SVOvalShape shapeFromDictionary:dict];
            else if ([type isEqualToString:@"path"])
                shape = [SVPathShape shapeFromDictionary:dict];
            if (shape) [_shapes addObject:shape];
        }
    }
    NSNumber *w = [root objectForKey:@"width"];
    NSNumber *h = [root objectForKey:@"height"];
    if (w && h) _artboardSize = NSMakeSize([w floatValue], [h floatValue]);
    _dirty = NO;
    return YES;
}

#if defined(GNUSTEP) && !__has_feature(objc_arc)
- (void)dealloc {
    [_shapes release];
    [super dealloc];
}
#endif

@end
