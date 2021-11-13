//
//  frmPreferences.h
//  GkHebKeyboard
//
//  Created by Leonard Clark on 22/12/2020.
//

#import <Cocoa/Cocoa.h>
#import "classGlobal.h"

NS_ASSUME_NONNULL_BEGIN

@interface frmPreferences : NSWindowController

@property (retain) classGlobal *globalVarsPref;
@property (retain) IBOutlet NSButton *rbtnHebrew;
@property (retain) IBOutlet NSButton *rbtnGreek;
@property (retain) IBOutlet NSComboBox *cbFont;

@end

NS_ASSUME_NONNULL_END
