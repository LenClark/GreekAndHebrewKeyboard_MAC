//
//  classGlobal.h
//  GkHebKeyboard
//
//  Created by Leonard Clark on 13/12/2020.
//

#import <Cocoa/Cocoa.h>
#import "classGreek.h"

NS_ASSUME_NONNULL_BEGIN

@interface classGlobal : NSObject

@property (retain) NSString *basePath;
@property (retain) classGreek *greekProcessing;
/*------------------------------------------------*
 *  openingLanguage:                              *
 *  ---------------                               *
 *    1 = Greek                                   *
 *    2 = Hebrew                                  *
 *------------------------------------------------*/
@property (nonatomic) NSUInteger openingLanguage;
@property (nonatomic) NSInteger fontSize;
@property (retain) NSTextView *mainEnteredText;

@end

NS_ASSUME_NONNULL_END
