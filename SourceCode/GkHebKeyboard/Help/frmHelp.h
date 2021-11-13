//
//  frmHelp.h
//  GkHebKeyboard
//
//  Created by Leonard Clark on 24/12/2020.
//

#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface frmHelp : NSWindowController

@property (retain) IBOutlet WebView *helpWeb;

- (void) initialiseForm: (frmHelp *) inForm;

@end

NS_ASSUME_NONNULL_END
