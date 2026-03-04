//
//  SVDocument.m
//  SmallVector
//

#import "SVDocument.h"
#import "SVShape.h"
#import "SVRectShape.h"
#import "SVOvalShape.h"
#import "SVPathShape.h"

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
    return [data writeToFile:path options:NSDataWritingAtomic error:outError];
}

- (BOOL)readFromFile:(NSString *)path error:(NSError **)outError {
    NSData *data = [NSData dataWithContentsOfFile:path options:0 error:outError];
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
