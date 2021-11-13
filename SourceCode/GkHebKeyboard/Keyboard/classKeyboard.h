//
//  classKeyboard.h
//  GkHebKeyboard
//
//  Created by Leonard Clark on 13/12/2020.
//

#import <Cocoa/Cocoa.h>
#import "classGlobal.h"
#import "classGreek.h"

NS_ASSUME_NONNULL_BEGIN

@interface classKeyboard : NSObject

@property (retain) NSWindow *mainWindow;
@property (retain) classGlobal *globalVarsKeyboard;
@property (retain) classGreek *greekProcessingKeyboard;
@property (retain) NSTextView *enteredText;
@property (retain) NSImageView *btnCapsLight;
@property (retain) NSImageView *btnHebCapsLight;

@property (retain) NSView *pnlGkKeyboard;
@property (retain) NSView *pnlHebKeyboard;

@property (retain) NSArray *nonPrintKeys;
@property (retain) NSArray *keyWidths;
@property (retain) NSArray *hebKeyFace;
@property (retain) NSArray *hebKeyHint;
@property (retain) NSArray *hebAccents;
@property (retain) NSArray *hebAccentHints;
@property (retain) NSArray *gkKeyFaceMin;
@property (retain) NSArray *gkKeyFaceMaj;
@property (retain) NSArray *gkKeyHintMin;
@property (retain) NSArray *gkKeyHintMaj;
@property (nonatomic) BOOL isGkMiniscule;
@property (nonatomic) BOOL isHebMiniscule;
@property (retain) NSTabView *greekHebrewTabView;
@property (retain) IBOutlet NSTabViewItem *greekTab;
@property (retain) IBOutlet NSTabViewItem *hebrewTab;

- (void) initialiseKeyboard;
- (void) virtualKeyPress: (unichar) keyValue withControl: (bool) isGreek;

@end

NS_ASSUME_NONNULL_END
