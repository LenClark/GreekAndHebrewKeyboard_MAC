//
//  frmPreferences.m
//  GkHebKeyboard
//
//  Created by Leonard Clark on 22/12/2020.
//

#import "frmPreferences.h"

@interface frmPreferences ()

@end

@implementation frmPreferences

@synthesize globalVarsPref;
@synthesize rbtnHebrew;
@synthesize rbtnGreek;
@synthesize cbFont;

- (void)windowDidLoad {
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{//TODO
        [[NSApplication sharedApplication] runModalForWindow:self.window];
    });
    if( [globalVarsPref openingLanguage] == 1) [rbtnGreek setState:YES];
    else [rbtnHebrew setState:YES];
    [cbFont selectItemWithObjectValue:[[NSString alloc] initWithFormat:@"%li", [globalVarsPref fontSize]]];
}

- (void)windowWillClose:(NSNotification *)notification
{
    [[NSApplication sharedApplication] stopModal];
}

- (IBAction)doLanguageChoice:(NSButton *)sender
{
    
}

- (IBAction)doOK:(id)sender
{
    if( [rbtnGreek state] == NSControlStateValueOn ) globalVarsPref.openingLanguage = 1;
    else globalVarsPref.openingLanguage = 2;
    globalVarsPref.fontSize = [[cbFont objectValueOfSelectedItem] floatValue];
    [globalVarsPref.mainEnteredText setFont:[NSFont fontWithName:@"Times New Roman" size:[globalVarsPref fontSize]]];
    [self close];
}

- (IBAction)doCancel:(id)sender
{
    [self close];
}

@end
