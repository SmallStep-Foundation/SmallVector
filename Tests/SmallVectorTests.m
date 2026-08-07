//
//  SmallVectorTests.m
//  SmallVector unit tests (SVDocument and shapes)
//

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>
#import "SSTestMacros.h"
#import "../Core/SVDocument.h"
#import "../Core/SVShape.h"
#import "../Core/SVRectShape.h"
#import "../Core/SVOvalShape.h"
#import "../Core/SVPathShape.h"

static void testSVDocumentShapes(void)
{
    CREATE_AUTORELEASE_POOL(pool);
    SVDocument *doc = [[SVDocument alloc] init];
    SS_TEST_ASSERT(doc != nil, "SVDocument init");
    SS_TEST_ASSERT([[doc shapes] count] == 0, "initial shapes empty");

    SVRectShape *rect = [[SVRectShape alloc] init];
    rect.frame = NSMakeRect(10, 20, 100, 50);
    [doc addShape:rect];
#if defined(GNUSTEP) && !__has_feature(objc_arc)
    [rect release];
#endif
    SS_TEST_ASSERT([[doc shapes] count] == 1, "one shape after add");
    SS_TEST_ASSERT([doc dirty], "dirty after add");

    SVShape *atPoint = [doc shapeAtPoint:NSMakePoint(50, 45)];
    SS_TEST_ASSERT(atPoint != nil, "shapeAtPoint hits rect");

#if defined(GNUSTEP) && !__has_feature(objc_arc)
    [doc release];
#endif
    RELEASE(pool);
}

static void testSVDocumentWriteReadRoundtrip(void)
{
    CREATE_AUTORELEASE_POOL(pool);
    SVDocument *doc = [[SVDocument alloc] init];
    SVRectShape *rect = [[SVRectShape alloc] init];
    rect.frame = NSMakeRect(0, 0, 200, 100);
    [doc addShape:rect];
#if defined(GNUSTEP) && !__has_feature(objc_arc)
    [rect release];
#endif

    NSString *path = [NSTemporaryDirectory() stringByAppendingPathComponent:@"SmallVectorTests_roundtrip.plist"];
    NSError *err = nil;
    SS_TEST_ASSERT([doc writeToFile:path error:&err], "writeToFile");
    SS_TEST_ASSERT([[NSFileManager defaultManager] fileExistsAtPath:path], "file exists");

    SVDocument *doc2 = [[SVDocument alloc] init];
    SS_TEST_ASSERT([doc2 readFromFile:path error:&err], "readFromFile");
    SS_TEST_ASSERT([[doc2 shapes] count] == 1, "one shape after read");
    [[NSFileManager defaultManager] removeItemAtPath:path error:NULL];

#if defined(GNUSTEP) && !__has_feature(objc_arc)
    [doc release];
    [doc2 release];
#endif
    RELEASE(pool);
}

static void testSVDocumentSVGExport(void)
{
    CREATE_AUTORELEASE_POOL(pool);
    SVDocument *doc = [[SVDocument alloc] init];

    SVRectShape *rect = [[SVRectShape alloc] init];
    rect.frame = NSMakeRect(10, 20, 100, 50);
    [doc addShape:rect];
#if defined(GNUSTEP) && !__has_feature(objc_arc)
    [rect release];
#endif

    SVOvalShape *oval = [[SVOvalShape alloc] init];
    oval.frame = NSMakeRect(0, 0, 40, 30);
    [doc addShape:oval];
#if defined(GNUSTEP) && !__has_feature(objc_arc)
    [oval release];
#endif

    SVPathShape *pathShape = [[SVPathShape alloc] init];
    [[pathShape path] moveToPoint:NSMakePoint(0, 0)];
    [[pathShape path] lineToPoint:NSMakePoint(50, 50)];
    [doc addShape:pathShape];
#if defined(GNUSTEP) && !__has_feature(objc_arc)
    [pathShape release];
#endif

    NSString *svg = [doc svgString];
    SS_TEST_ASSERT(svg != nil, "svgString returns non-nil");
    SS_TEST_ASSERT([svg rangeOfString:@"<svg"].location != NSNotFound, "svg has root element");
    SS_TEST_ASSERT([svg rangeOfString:@"viewBox"].location != NSNotFound, "svg has viewBox");
    SS_TEST_ASSERT([svg rangeOfString:@"<rect"].location != NSNotFound, "svg has rect");
    SS_TEST_ASSERT([svg rangeOfString:@"<ellipse"].location != NSNotFound, "svg has ellipse");
    SS_TEST_ASSERT([svg rangeOfString:@"<path"].location != NSNotFound, "svg has path");
    SS_TEST_ASSERT([svg rangeOfString:@"M 0 0 L 50 50"].location != NSNotFound,
        "svg path data matches the bezier path");

    NSString *svgPath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"SmallVectorTests_export.svg"];
    [[NSFileManager defaultManager] removeItemAtPath:svgPath error:NULL];
    NSError *err = nil;
    SS_TEST_ASSERT([doc writeSVGToPath:svgPath error:&err], "writeSVGToPath writes a file");
    NSString *written = [NSString stringWithContentsOfFile:svgPath encoding:NSUTF8StringEncoding error:NULL];
    SS_TEST_ASSERT(written != nil && [written rangeOfString:@"<svg"].location != NSNotFound,
        "written SVG is a full document");
    [[NSFileManager defaultManager] removeItemAtPath:svgPath error:NULL];

#if defined(GNUSTEP) && !__has_feature(objc_arc)
    [doc release];
#endif
    RELEASE(pool);
}

int main(int argc, char **argv)
{
    (void)argc;
    (void)argv;
    CREATE_AUTORELEASE_POOL(pool);
    [NSApplication sharedApplication];

    testSVDocumentShapes();
    testSVDocumentWriteReadRoundtrip();
    testSVDocumentSVGExport();

    SS_TEST_SUMMARY();
    RELEASE(pool);
    return SS_TEST_RETURN();
}
