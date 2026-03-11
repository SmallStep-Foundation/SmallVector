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

int main(int argc, char **argv)
{
    (void)argc;
    (void)argv;
    CREATE_AUTORELEASE_POOL(pool);
    [NSApplication sharedApplication];

    testSVDocumentShapes();
    testSVDocumentWriteReadRoundtrip();

    SS_TEST_SUMMARY();
    RELEASE(pool);
    return SS_TEST_RETURN();
}
