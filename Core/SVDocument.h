//
//  SVDocument.h
//  SmallVector
//
//  Vector document: list of shapes, selection, artboard size, dirty flag.
//

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>

@class SVShape;

@interface SVDocument : NSObject {
#if defined(GNUSTEP) && !__has_feature(objc_arc)
    NSMutableArray *_shapes;
    NSSize _artboardSize;
    BOOL _dirty;
    SVShape *_selectedShape;
#endif
}

@property (nonatomic, assign) NSSize artboardSize;
@property (nonatomic, assign) BOOL dirty;
#if defined(GNUSTEP) && !__has_feature(objc_arc)
@property (nonatomic, assign) SVShape *selectedShape;
#else
@property (nonatomic, weak) SVShape *selectedShape;
#endif

- (NSArray *)shapes;
- (void)addShape:(SVShape *)shape;
- (void)removeShape:(SVShape *)shape;
- (void)removeSelectedShape;
- (SVShape *)shapeAtPoint:(NSPoint)point;

- (BOOL)writeToFile:(NSString *)path error:(NSError **)outError;
- (BOOL)readFromFile:(NSString *)path error:(NSError **)outError;

@end
