//
//  SVAppDelegate.h
//  SmallVector
//
//  App lifecycle and menu; creates the main vector editor window.
//

#import <Foundation/Foundation.h>
#if !TARGET_OS_IPHONE
#import <AppKit/AppKit.h>
#endif
#import "SSAppDelegate.h"

@class SVMainWindow;

@interface SVAppDelegate : NSObject <SSAppDelegate>
{
    SVMainWindow *_mainWindow;
}
@end
