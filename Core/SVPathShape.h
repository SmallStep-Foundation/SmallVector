//
//  SVPathShape.h
//  SmallVector
//
//  Freeform path (NSBezierPath). Serialized as array of points.
//

#import "SVShape.h"

#if defined(GNUSTEP) && !__has_feature(objc_arc)
#  define SV_RETAIN retain
#else
#  define SV_RETAIN strong
#endif

@interface SVPathShape : SVShape {
#if defined(GNUSTEP) && !__has_feature(objc_arc)
    NSBezierPath *_path;
#endif
}
@property (nonatomic, SV_RETAIN) NSBezierPath *path;
@end
