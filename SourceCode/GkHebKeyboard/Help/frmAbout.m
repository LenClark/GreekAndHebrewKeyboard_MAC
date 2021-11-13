//
//  frmAbout.m
//  GkHebKeyboard
//
//  Created by Leonard Clark on 23/12/2020.
//

#import "frmAbout.h"

@interface frmAbout ()

@end

@implementation frmAbout

@synthesize aboutTopImage;

frmAbout *aboutSelf;


- (void)windowDidLoad {
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

- (void) windowWillClose: (NSNotification *) notification
{
    [[NSApplication sharedApplication] stopModal];
}

- (void) simpleInitialisation: (frmAbout *) inSelf
{
    aboutSelf = inSelf;
}

- (IBAction)doClose:(id)sender
{
    [aboutSelf close];
}

@end
