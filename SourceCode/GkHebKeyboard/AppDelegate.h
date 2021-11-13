//
//  AppDelegate.h
//  GkHebKeyboard
//
//  Created by Leonard Clark on 12/12/2020.
//

#import <Cocoa/Cocoa.h>
#import "classGlobal.h"
#import "classKeyboard.h"
#import "frmPreferences.h"
#import "frmAbout.h"
#import "frmHelp.h"

@interface AppDelegate : NSObject <NSApplicationDelegate, NSTabViewDelegate>

@property (retain) IBOutlet NSWindow *mainWindow;
@property (retain) IBOutlet NSView *pnlGkKeyboard;
@property (retain) IBOutlet NSView *pnlHebKeyboard;
@property (retain) IBOutlet NSTextView *enteredText;
@property (retain) IBOutlet NSImageView *btnCapsLight;
@property (retain) IBOutlet NSImageView *btnHebCapsLight;
@property (retain) IBOutlet NSTabView *greekHebrewTabs;
@property (retain) IBOutlet NSTabViewItem *greekTab;
@property (retain) IBOutlet NSTabViewItem *hebrewTab;
@property (retain) IBOutlet NSTabView *greekOptionTabs;
@property (retain) IBOutlet NSTabViewItem *greekKBrdTab;
@property (retain) IBOutlet NSTabViewItem *greekPhysTab;
@property (retain) IBOutlet NSTabView *hebrewOptionTabs;
@property (retain) IBOutlet NSTabViewItem *hebrewKBrdTab;
@property (retain) IBOutlet NSTabViewItem *hebrewPhysTab;
@property (retain) IBOutlet NSImageView *keyDetails;
@property (retain) IBOutlet NSButton *fullUpBtn;
@property (retain) IBOutlet NSButton *upBtn;
@property (retain) IBOutlet NSButton *fullLeftBtn;
@property (retain) IBOutlet NSButton *leftBtn;
@property (retain) IBOutlet NSButton *fullRightBtn;
@property (retain) IBOutlet NSButton *rightBtn;
@property (retain) IBOutlet NSButton *fullDownBtn;
@property (retain) IBOutlet NSButton *downBtn;
@property (retain) classKeyboard *keyboard;
@property (nonatomic) bool isGreek;
@property (retain) NSString *lastSavedDocument;

@end

