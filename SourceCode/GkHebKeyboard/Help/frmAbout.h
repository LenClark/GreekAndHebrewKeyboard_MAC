//
//  frmAbout.h
//  GkHebKeyboard
//
//  Created by Leonard Clark on 23/12/2020.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface frmAbout : NSWindowController

@property (retain) IBOutlet NSImageView *aboutTopImage;

- (void) simpleInitialisation: (frmAbout *) inSelf;

@end

NS_ASSUME_NONNULL_END
