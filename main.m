//
//  main.m
//  SmallVector
//
//  Simple vector editor (early Sketch–style) for GNUStep. Uses SmallStepLib for
//  app lifecycle, menus, window style, and file dialogs.
//

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>
#import "SVAppDelegate.h"
#import "SSAppDelegate.h"
#import "SSHostApplication.h"

int main(int argc, const char *argv[]) {
#if defined(GNUSTEP) && !__has_feature(objc_arc)
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
#endif
    id<SSAppDelegate> delegate = [[SVAppDelegate alloc] init];
    [SSHostApplication runWithDelegate:delegate];
#if defined(GNUSTEP) && !__has_feature(objc_arc)
    [delegate release];
    [pool release];
#endif
    return 0;
}
