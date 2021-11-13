//
//  classGreek.h
//  GkHebKeyboard
//
//  Created by Leonard Clark on 13/12/2020.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface classGreek : NSObject

@property (retain) NSMutableDictionary *allGkChars;
@property (retain) NSMutableDictionary *addRoughBreathing;
@property (retain) NSMutableDictionary *addSmoothBreathing;
@property (retain) NSMutableDictionary *addAccute;
@property (retain) NSMutableDictionary *addGrave;
@property (retain) NSMutableDictionary *addCirc;
@property (retain) NSMutableDictionary *addDiaeresis;
@property (retain) NSMutableDictionary *addIotaSub;

- (void) initialProcessing;
- (NSString *) processRoughBreathing: (NSString *) originalChar;
- (NSString *) processSmoothBreathing: (NSString *) originalChar;
- (NSString *) processAccute: (NSString *) originalChar;
- (NSString *) processGrave: (NSString *) originalChar;
- (NSString *) processCirc: (NSString *) originalChar;
- (NSString *) processDiaeresis: (NSString *) originalChar;
- (NSString *) processIotaSub: (NSString *) originalChar;

@end

NS_ASSUME_NONNULL_END
