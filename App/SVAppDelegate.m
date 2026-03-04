//
//  SVAppDelegate.m
//  SmallVector
//

#import "SVAppDelegate.h"
#import "SVMainWindow.h"
#import "SSAppDelegate.h"
#import "SSHostApplication.h"
#import "SSMainMenu.h"

@implementation SVAppDelegate

- (void)applicationWillFinishLaunching {
    [self buildMenu];
}

- (void)applicationDidFinishLaunching {
    _mainWindow = [[SVMainWindow alloc] init];
    [_mainWindow makeKeyAndOrderFront:nil];
    [[NSApplication sharedApplication] activateIgnoringOtherApps:YES];
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(id)sender {
    (void)sender;
    return YES;
}

- (void)buildMenu {
#if !TARGET_OS_IPHONE
    SSMainMenu *menu = [[SSMainMenu alloc] init];
    [menu setAppName:@"SmallVector"];
    NSArray *items = [NSArray arrayWithObjects:
        [SSMainMenuItem itemWithTitle:@"New" action:@selector(newDocument:) keyEquivalent:@"n" modifierMask:NSCommandKeyMask target:self],
        [SSMainMenuItem itemWithTitle:@"Open…" action:@selector(openDocument:) keyEquivalent:@"o" modifierMask:NSCommandKeyMask target:self],
        [SSMainMenuItem itemWithTitle:@"Save" action:@selector(saveDocument:) keyEquivalent:@"s" modifierMask:NSCommandKeyMask target:self],
        [SSMainMenuItem itemWithTitle:@"Save As…" action:@selector(saveDocumentAs:) keyEquivalent:@"" modifierMask:0 target:self],
        nil];
    [menu buildMenuWithItems:items quitTitle:@"Quit SmallVector" quitKeyEquivalent:@"q"];
    [menu install];
#if defined(GNUSTEP) && !__has_feature(objc_arc)
    [menu release];
#endif
#endif
}

- (void)newDocument:(id)sender {
    (void)sender;
    [_mainWindow newDocument];
}

- (void)openDocument:(id)sender {
    (void)sender;
    [_mainWindow openDocument];
}

- (void)saveDocument:(id)sender {
    (void)sender;
    [_mainWindow saveDocument];
}

- (void)saveDocumentAs:(id)sender {
    (void)sender;
    [_mainWindow saveDocumentAs];
}

#if defined(GNUSTEP) && !__has_feature(objc_arc)
- (void)dealloc {
    [_mainWindow release];
    [super dealloc];
}
#endif

@end
