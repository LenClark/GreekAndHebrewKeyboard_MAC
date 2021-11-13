//
//  classGreek.m
//  GkHebKeyboard
//
//  Created by Leonard Clark on 13/12/2020.
//

#import "classGreek.h"

/*******************************************************************************************************************************
 *                                                                        *
 *                           classGreek                                                                                  *
 *                           ========                                                                                   *
 *                                                                        *
 *  All manipulations of Greek text will, where possible, be handled here.  Envisaged tasks are:          *
 *                                                                        *
 *  1. Store bare vowels                                                                                                                           *
 *  2. Store bare consonants                                                                                                                   *
 *  3. Store all base letters                                                                                                                       *
 *  4. Handle the transition from a letter with "furniture" (e.g. accents, diaraesis, etc - excluding         *
 *       breathings) to related letters with either no diacritics or with a breathing only;                      *
 *  5. Handle the transition from a letter with breathings to the base equivalent                                    *
 *  6. Potentially, handle the addition of diacritics (not currently needed)                                               *
 *  7. Potentially, handle the transition from transliterations to the real Greek character (not currently  *
 *       needed)                                                                                                                                    *
 *                                                                        *
 *********************************************************************************************************************************/

@implementation classGreek

@synthesize allGkChars;
@synthesize addRoughBreathing;
@synthesize addSmoothBreathing;
@synthesize addAccute;
@synthesize addGrave;
@synthesize addCirc;
@synthesize addDiaeresis;
@synthesize addIotaSub;

const NSInteger mainCharsStart = 0x0386, mainCharsEnd = 0x03ce, furtherCharsStart = 0x1f00, furtherCharsEnd = 0x1ffc;

// hexadecimal punctuation characters are: the middle dot, the ano teleia (partial stop, which is
//    functionally the same as the middle dot and the unicode documentation says that the middle
//    dot is the "preferred character") and the erotimatiko (the Greek question mark, identical in
//    appearance to the semi colon).  So, elements 1 (zero-based) and 5 are equivalent and elements
//    3 and 4 are equivalent.  Both are included in case source material has varied usage.
NSArray *allowedPunctuation;

- (void) initialProcessing
{
    /************************************************************************************************************
     *                                                                                                          *
     *                                       constructGreekLists                                                *
     *                                       ===================                                                *
     *                                                                                                          *
     *  The coding works on the following basis:                                                                *
     *      a) Each base vowel has an integer value in ascending order.  So:                                    *
     *              α = 1                                                                                       *
     *              ε = 2                                                                                       *
     *              η = 3                                                                                       *
     *              ι = 4                                                                                       *
     *              ο = 5                                                                                       *
     *              υ = 6                                                                                       *
     *              ω = 7                                                                                       *
     *         This value applies whether it is miniscule or majiscule                                          *
     *      b) Add 10 if the vowel has a "grave" accent (varia)                                                 *
     *      c) Add 20 if the vowel has an "accute" accent (oxia)                                                *
     *      d) Add 30 if the vowel has a "circumflex" accent (perispomeni)                                      *
     *      e) Add 40 if the vowel is in the base table and has an accute accent (oxia) i.e. it is an           *
     *           alternative coding - it's actually a tonos, not an oxia                                        *
     *      f) Add 50 if the vowel has a vrachy (cannot have a breathing or accent)                             *
     *      g) Add 60 if the vowel has a macron                                                                 *
     *      h) Add 100 if the vowel has a smooth breathing (psili)                                              *
     *      i) Add 200 if the vowel has a rough breathing (dasia)                                               *
     *      j) Add 300 if the vowel has dieresis (dialytika) - only ι and υ                                     *
     *      k) Add 1000 if the vowel has an iota subscript - only α, η and ω                                    *
     *      l) Add 10000 if a majuscule                                                                         *
     *                                                                                                          *
     *  charCode1 (a and b):                                                                                    *
     *    purpose: to indicate whether a char is vowel (and, if so, which), another, extra character (i.e. rho  *
     *             or final sigma), a simple letter or puntuation.                                              *
     *    Code values are:                                                                                      *
     *     -1     A null value - to be ignored                                                                  *
     *      0 - 6 alpha to omega respectively - not simple                                                      *
     *      7     rho - not simple                                                                              *
     *      8     final sigma                                                                                   *
     *      9     simple alphabet                                                                               *
     *      10    punctuation                                                                                   *
     *                                                                                                          *
     *   charCode2:                                                                                             *
     *     purpose: identify whether char has a smooth breathing, rough breathing or none.  All part a chars    *
     *              are without breathing, so only part b characters are coded. (Note, however, that 0x03ca and *
     *              0x03cb are diereses (code value 3).                                                         *
     *     Code values are:                                                                                     *
     *       0   No breathing                                                                                   *
     *       1   Smooth breathing                                                                               *
     *       2   Rough breathing                                                                                *
     *       3   Dieresis                                                                                       *
     *                                                                                                          *
     ************************************************************************************************************/
    
    NSInteger idx, mainCharIndex, furtherCharIndex;
    NSString *charRepresentation;
    NSArray *gkTable1, *gkTable2;

    allowedPunctuation = [[NSArray alloc] initWithObjects: @".", @";", @",", @"\u00b7", @"\u0387", @"\u037e", nil ];

    /*............................................................*
     *  A table matching the main Greek table in Unicode          *
     *............................................................*/
    
    gkTable1 = [[NSArray alloc] initWithObjects: [NSNumber numberWithInt: 0x03b1], [NSNumber numberWithInt:  -1], [NSNumber numberWithInt:  0x03b5],
                [NSNumber numberWithInt:  0x03b7], [NSNumber numberWithInt:  0x03b9], [NSNumber numberWithInt:  -1], [NSNumber numberWithInt:  0x03bf],
                [NSNumber numberWithInt:  -1], [NSNumber numberWithInt:  0x03c5], [NSNumber numberWithInt:  0x03c9], [NSNumber numberWithInt:  0x03ca],
                [NSNumber numberWithInt: 0x03b1], [NSNumber numberWithInt:  0x03b2], [NSNumber numberWithInt:  0x03b3], [NSNumber numberWithInt:  0x03b4],
                [NSNumber numberWithInt:  0x03b5], [NSNumber numberWithInt:  0x03b6], [NSNumber numberWithInt:  0x03b7], [NSNumber numberWithInt:  0x03b8],
                [NSNumber numberWithInt:  0x03b9], [NSNumber numberWithInt:  0x03ba], [NSNumber numberWithInt:  0x03bb], [NSNumber numberWithInt:  0x03bc],
                [NSNumber numberWithInt:  0x03bd], [NSNumber numberWithInt:  0x03be], [NSNumber numberWithInt:  0x03bf], [NSNumber numberWithInt: 0x03c0],
                [NSNumber numberWithInt:  0x03c1], [NSNumber numberWithInt:  -1], [NSNumber numberWithInt:  0x03c3], [NSNumber numberWithInt:  0x03c4],
                [NSNumber numberWithInt:  0x03c5], [NSNumber numberWithInt:  0x03c6], [NSNumber numberWithInt:  0x03c7], [NSNumber numberWithInt:  0x03c8],
                [NSNumber numberWithInt:  0x03c9], [NSNumber numberWithInt:  0x03ca], [NSNumber numberWithInt:  0x03cb], [NSNumber numberWithInt:  0x03b1],
                [NSNumber numberWithInt:  0x03b5], [NSNumber numberWithInt:  0x03b7], [NSNumber numberWithInt:  0x03b9], [NSNumber numberWithInt:  0x03cb],
                [NSNumber numberWithInt: 0x03b1], [NSNumber numberWithInt:  0x03b2], [NSNumber numberWithInt:  0x03b3], [NSNumber numberWithInt:  0x03b4],
                [NSNumber numberWithInt:  0x03b5], [NSNumber numberWithInt:  0x03b6], [NSNumber numberWithInt:  0x03b7], [NSNumber numberWithInt:  0x03b8],
                [NSNumber numberWithInt:  0x03b9], [NSNumber numberWithInt:  0x03ba], [NSNumber numberWithInt:  0x03bb], [NSNumber numberWithInt:  0x03bc],
                [NSNumber numberWithInt:  0x03bd], [NSNumber numberWithInt:  0x03be], [NSNumber numberWithInt:  0x03bf], [NSNumber numberWithInt:0x03c0],
                [NSNumber numberWithInt:  0x03c1], [NSNumber numberWithInt:  0x03c2], [NSNumber numberWithInt:  0x03c3], [NSNumber numberWithInt:  0x03c4],
                [NSNumber numberWithInt:  0x03c5], [NSNumber numberWithInt:  0x03c6], [NSNumber numberWithInt:  0x03c7], [NSNumber numberWithInt:  0x03c8],
                [NSNumber numberWithInt:  0x03c9], [NSNumber numberWithInt:  0x03ca], [NSNumber numberWithInt:  0x03cb], [NSNumber numberWithInt:  0x03bf],
                [NSNumber numberWithInt:  0x03c5], [NSNumber numberWithInt:  0x03c9], nil];

    /*............................................................*
     *  A table matching the additional Greek table in Unicode    *
     *............................................................*/
    
    gkTable2 = [[NSArray alloc] initWithObjects:[NSNumber numberWithInt: 0x1f00], [NSNumber numberWithInt:  0x1f01], [NSNumber numberWithInt:  0x1f00],
                [NSNumber numberWithInt:  0x1f01], [NSNumber numberWithInt:  0x1f00], [NSNumber numberWithInt:  0x1f01], [NSNumber numberWithInt:  0x1f00],
                [NSNumber numberWithInt:  0x1f01], [NSNumber numberWithInt:  0x1f00], [NSNumber numberWithInt:  0x1f01], [NSNumber numberWithInt:  0x1f00],
                [NSNumber numberWithInt:  0x1f01], [NSNumber numberWithInt:  0x1f00], [NSNumber numberWithInt:  0x1f01], [NSNumber numberWithInt:  0x1f00],
                [NSNumber numberWithInt:  0x1f01], [NSNumber numberWithInt: 0x1f10], [NSNumber numberWithInt:  0x1f11], [NSNumber numberWithInt:  0x1f10],
                [NSNumber numberWithInt:  0x1f11], [NSNumber numberWithInt:  0x1f10], [NSNumber numberWithInt:  0x1f11], [NSNumber numberWithInt:  -1],
                [NSNumber numberWithInt:  -1], [NSNumber numberWithInt:  0x1f10], [NSNumber numberWithInt:  0x1f11], [NSNumber numberWithInt:  0x1f10],
                [NSNumber numberWithInt:  0x1f11], [NSNumber numberWithInt:  0x1f10], [NSNumber numberWithInt:  0x1f11], [NSNumber numberWithInt:  -1],
                [NSNumber numberWithInt:  -1], [NSNumber numberWithInt: 0x1f20], [NSNumber numberWithInt:  0x1f21], [NSNumber numberWithInt:  0x1f20],
                [NSNumber numberWithInt:  0x1f21], [NSNumber numberWithInt:  0x1f20], [NSNumber numberWithInt:  0x1f21], [NSNumber numberWithInt:  0x1f20],
                [NSNumber numberWithInt:  0x1f21], [NSNumber numberWithInt:  0x1f20], [NSNumber numberWithInt:  0x1f21], [NSNumber numberWithInt:  0x1f20],
                [NSNumber numberWithInt:  0x1f21], [NSNumber numberWithInt:  0x1f20], [NSNumber numberWithInt:  0x1f21], [NSNumber numberWithInt:  0x1f20],
                [NSNumber numberWithInt:  0x1f21], [NSNumber numberWithInt: 0x1f30], [NSNumber numberWithInt:  0x1f31], [NSNumber numberWithInt:  0x1f30],
                [NSNumber numberWithInt:  0x1f31], [NSNumber numberWithInt:  0x1f30], [NSNumber numberWithInt:  0x1f31], [NSNumber numberWithInt:  0x1f30],
                [NSNumber numberWithInt:  0x1f31], [NSNumber numberWithInt:  0x1f30], [NSNumber numberWithInt:  0x1f31], [NSNumber numberWithInt:  0x1f30],
                [NSNumber numberWithInt:  0x1f31], [NSNumber numberWithInt:  0x1f30], [NSNumber numberWithInt:  0x1f31], [NSNumber numberWithInt:  0x1f30],
                [NSNumber numberWithInt:  0x1f31], [NSNumber numberWithInt: 0x1f40], [NSNumber numberWithInt:  0x1f41], [NSNumber numberWithInt:  0x1f40],
                [NSNumber numberWithInt:  0x1f41], [NSNumber numberWithInt:  0x1f40], [NSNumber numberWithInt:  0x1f41], [NSNumber numberWithInt:  -1],
                [NSNumber numberWithInt:  -1], [NSNumber numberWithInt:  0x1f40], [NSNumber numberWithInt:  0x1f41], [NSNumber numberWithInt:  0x1f40],
                [NSNumber numberWithInt:  0x1f41], [NSNumber numberWithInt:  0x1f40], [NSNumber numberWithInt:  0x1f41], [NSNumber numberWithInt:  -1],
                [NSNumber numberWithInt:  -1], [NSNumber numberWithInt: 0x1f50], [NSNumber numberWithInt:  0x1f51], [NSNumber numberWithInt:  0x1f50],
                [NSNumber numberWithInt:  0x1f51], [NSNumber numberWithInt:  0x1f50], [NSNumber numberWithInt:  0x1f51], [NSNumber numberWithInt:  0x1f50],
                [NSNumber numberWithInt:  0x1f51], [NSNumber numberWithInt:  -1], [NSNumber numberWithInt:  0x1f51], [NSNumber numberWithInt:  -1],
                [NSNumber numberWithInt:  0x1f51], [NSNumber numberWithInt:  -1], [NSNumber numberWithInt:  0x1f51], [NSNumber numberWithInt:  -1],
                [NSNumber numberWithInt:  0x1f51], [NSNumber numberWithInt: 0x1f60], [NSNumber numberWithInt:  0x1f61], [NSNumber numberWithInt:  0x1f60],
                [NSNumber numberWithInt:  0x1f61], [NSNumber numberWithInt:  0x1f60], [NSNumber numberWithInt:  0x1f61], [NSNumber numberWithInt:  0x1f60],
                [NSNumber numberWithInt:  0x1f61], [NSNumber numberWithInt:  0x1f60], [NSNumber numberWithInt:  0x1f61], [NSNumber numberWithInt:  0x1f60],
                [NSNumber numberWithInt:  0x1f61], [NSNumber numberWithInt:  0x1f60], [NSNumber numberWithInt:  0x1f61], [NSNumber numberWithInt:  0x1f60],
                [NSNumber numberWithInt:  0x1f61], [NSNumber numberWithInt: 0x03b1], [NSNumber numberWithInt:  0x03b1], [NSNumber numberWithInt:  0x03b5],
                [NSNumber numberWithInt:  0x03b5], [NSNumber numberWithInt:  0x03b7], [NSNumber numberWithInt:  0x03b7], [NSNumber numberWithInt:  0x03b9],
                [NSNumber numberWithInt:  0x03b9], [NSNumber numberWithInt:  0x03bf], [NSNumber numberWithInt:  0x03bf], [NSNumber numberWithInt:  0x03c5],
                [NSNumber numberWithInt:  0x03c5], [NSNumber numberWithInt:  0x03c9], [NSNumber numberWithInt:  0x03c9], [NSNumber numberWithInt:  -1],
                [NSNumber numberWithInt:  -1], [NSNumber numberWithInt: 0x1f00], [NSNumber numberWithInt:  0x1f01], [NSNumber numberWithInt:  0x1f00],
                [NSNumber numberWithInt:  0x1f01], [NSNumber numberWithInt:  0x1f00], [NSNumber numberWithInt:  0x1f01], [NSNumber numberWithInt:  0x1f00],
                [NSNumber numberWithInt:  0x1f01], [NSNumber numberWithInt:  0x1f00], [NSNumber numberWithInt:  0x1f01], [NSNumber numberWithInt:  0x1f00],
                [NSNumber numberWithInt:  0x1f01], [NSNumber numberWithInt:  0x1f00], [NSNumber numberWithInt:  0x1f01], [NSNumber numberWithInt:  0x1f00],
                [NSNumber numberWithInt:  0x1f01], [NSNumber numberWithInt: 0x1f20], [NSNumber numberWithInt:  0x1f21], [NSNumber numberWithInt:  0x1f20],
                [NSNumber numberWithInt:  0x1f21], [NSNumber numberWithInt:  0x1f20], [NSNumber numberWithInt:  0x1f21], [NSNumber numberWithInt:  0x1f20],
                [NSNumber numberWithInt:  0x1f21], [NSNumber numberWithInt:  0x1f20], [NSNumber numberWithInt:  0x1f21], [NSNumber numberWithInt:  0x1f20],
                [NSNumber numberWithInt:  0x1f21], [NSNumber numberWithInt:  0x1f20], [NSNumber numberWithInt:  0x1f21], [NSNumber numberWithInt:  0x1f20],
                [NSNumber numberWithInt:  0x1f21], [NSNumber numberWithInt: 0x1f60], [NSNumber numberWithInt:  0x1f61], [NSNumber numberWithInt:  0x1f60],
                [NSNumber numberWithInt:  0x1f61], [NSNumber numberWithInt:  0x1f60], [NSNumber numberWithInt:  0x1f61], [NSNumber numberWithInt:  0x1f60],
                [NSNumber numberWithInt:  0x1f61], [NSNumber numberWithInt:  0x1f60], [NSNumber numberWithInt:  0x1f61], [NSNumber numberWithInt:  0x1f60],
                [NSNumber numberWithInt:  0x1f61], [NSNumber numberWithInt:  0x1f60], [NSNumber numberWithInt:  0x1f61], [NSNumber numberWithInt:  0x1f60],
                [NSNumber numberWithInt:  0x1f61], [NSNumber numberWithInt: 0x03b1], [NSNumber numberWithInt:  0x03b1], [NSNumber numberWithInt:  0x03b1],
                [NSNumber numberWithInt:  0x03b1], [NSNumber numberWithInt:  0x03b1], [NSNumber numberWithInt:  -1], [NSNumber numberWithInt:  0x03b1],
                [NSNumber numberWithInt:  0x03b1], [NSNumber numberWithInt:  0x03b1], [NSNumber numberWithInt:  0x03b1], [NSNumber numberWithInt:  0x03b1],
                [NSNumber numberWithInt:  0x03b1], [NSNumber numberWithInt:  0x03b1], [NSNumber numberWithInt:  -1], [NSNumber numberWithInt:  -1],
                [NSNumber numberWithInt:  -1], [NSNumber numberWithInt: -1], [NSNumber numberWithInt:  -1], [NSNumber numberWithInt:  0x03b7],
                [NSNumber numberWithInt:  0x03b7], [NSNumber numberWithInt:  0x03b7], [NSNumber numberWithInt:  -1], [NSNumber numberWithInt:  0x03b7],
                [NSNumber numberWithInt:  0x03b7], [NSNumber numberWithInt:  0x03b5], [NSNumber numberWithInt:  0x03b5], [NSNumber numberWithInt:  0x03b7],
                [NSNumber numberWithInt:  0x03b7], [NSNumber numberWithInt:  0x03b7], [NSNumber numberWithInt:  -1], [NSNumber numberWithInt:  -1],
                [NSNumber numberWithInt:  -1], [NSNumber numberWithInt: 0x03b9], [NSNumber numberWithInt:  0x03b9], [NSNumber numberWithInt:  0x03ca],
                [NSNumber numberWithInt:  0x03ca], [NSNumber numberWithInt:  -1], [NSNumber numberWithInt:  -1], [NSNumber numberWithInt:  0x03b9],
                [NSNumber numberWithInt:  0x03ca], [NSNumber numberWithInt:  0x03b9], [NSNumber numberWithInt:  0x03b9], [NSNumber numberWithInt:  0x03b9],
                [NSNumber numberWithInt:  0x03b9], [NSNumber numberWithInt:  -1], [NSNumber numberWithInt:  -1], [NSNumber numberWithInt:  -1],
                [NSNumber numberWithInt:  -1], [NSNumber numberWithInt: 0x03c5], [NSNumber numberWithInt:  0x03c5], [NSNumber numberWithInt:  0x03cb],
                [NSNumber numberWithInt:  0x03cb], [NSNumber numberWithInt:  0x1fe4], [NSNumber numberWithInt:  0x1fe5], [NSNumber numberWithInt:  0x03c5],
                [NSNumber numberWithInt:  0x03cb], [NSNumber numberWithInt:  0x03c5], [NSNumber numberWithInt:  0x03c5], [NSNumber numberWithInt:  0x03c5],
                [NSNumber numberWithInt:  0x03c5], [NSNumber numberWithInt:  0x1fe5], [NSNumber numberWithInt:  -1], [NSNumber numberWithInt:  -1],
                [NSNumber numberWithInt:  -1], [NSNumber numberWithInt: -1], [NSNumber numberWithInt:  -1], [NSNumber numberWithInt:  0x03c9],
                [NSNumber numberWithInt:  0x03c9], [NSNumber numberWithInt:  0x03c9], [NSNumber numberWithInt:  -1], [NSNumber numberWithInt:  0x03c9],
                [NSNumber numberWithInt:  0x03c9], [NSNumber numberWithInt:  0x03bf], [NSNumber numberWithInt:  0x03bf], [NSNumber numberWithInt:  0x03c9],
                [NSNumber numberWithInt:  0x03c9], [NSNumber numberWithInt:  0x03c9], [NSNumber numberWithInt:  -1], [NSNumber numberWithInt:  -1],
                [NSNumber numberWithInt:  -1], nil];

    allGkChars = [[NSMutableDictionary alloc] init];
    addRoughBreathing = [[NSMutableDictionary alloc] init];
    addSmoothBreathing = [[NSMutableDictionary alloc] init];
    addAccute = [[NSMutableDictionary alloc] init];
    addGrave = [[NSMutableDictionary alloc] init];
    addCirc = [[NSMutableDictionary alloc] init];
    addDiaeresis = [[NSMutableDictionary alloc] init];
    addIotaSub = [[NSMutableDictionary alloc] init];
    
    // Load the two Unicode tables into memory.  These are stored as:
    //           - base characters (and a few extras);
    //           - characters with accents, breathings, iota subscript, etc.
    // allGkChars: key = the code value, value = the code converted to a string character
    idx = 0;
    for (mainCharIndex = mainCharsStart; mainCharIndex <= mainCharsEnd; mainCharIndex++)
    {
        charRepresentation = [[NSString alloc] initWithFormat:@"%li", mainCharIndex];
        if ( [charRepresentation compare:@"΋"] == 0)
        {
            idx++;
            continue;
        }
        [allGkChars setObject:charRepresentation forKey:[[NSNumber alloc] initWithInteger:mainCharIndex]];
        idx++;
    }
    idx = 0;
    for (furtherCharIndex = furtherCharsStart; furtherCharIndex <= furtherCharsEnd; furtherCharIndex++)
    {
        charRepresentation = [[NSString alloc] initWithFormat:@"%li", furtherCharIndex];
        if ( [charRepresentation compare:@"΋"] == 0)
        {
            idx++;
            continue;
        }
        [allGkChars setObject:charRepresentation forKey:[[NSNumber alloc] initWithInteger:furtherCharIndex]];
        idx++;
    }
    charRepresentation = [[NSString alloc] initWithFormat:@"%i", 0x03dc]; // Majuscule and miuscule digamma
    [allGkChars setObject:charRepresentation forKey:[[NSNumber alloc] initWithInt:0x03dc]];
    charRepresentation = [[NSString alloc] initWithFormat:@"%i", 0x03dd]; // Majuscule and miuscule digamma
    [allGkChars setObject:charRepresentation forKey:[[NSNumber alloc] initWithInt:0x03dd]];
    
    [self setupVowelConversionTable: 1 withKey: @"α"  andValue: @"\u1f01"];
    [self setupVowelConversionTable: 1 withKey: @"\u1f70"  andValue: @"\u1f03"];
    [self setupVowelConversionTable: 1 withKey: @"ά"  andValue: @"\u1f05"];
    [self setupVowelConversionTable: 1 withKey: @"\u1fb6"  andValue: @"\u1f07"];
    [self setupVowelConversionTable: 1 withKey: @"\u1fb3"  andValue: @"\u1f81"];
    [self setupVowelConversionTable: 1 withKey: @"\u1fb2"  andValue: @"\u1f83"];
    [self setupVowelConversionTable: 1 withKey: @"\u1fb4"  andValue: @"\u1f85"];
    [self setupVowelConversionTable: 1 withKey: @"\u1fb7"  andValue: @"\u1f87"];
    [self setupVowelConversionTable: 1 withKey: @"ε"  andValue: @"\u1f11"];
    [self setupVowelConversionTable: 1 withKey: @"\u1f72"  andValue: @"\u1f13"];
    [self setupVowelConversionTable: 1 withKey: @"έ"  andValue: @"\u1f15"];
    [self setupVowelConversionTable: 1 withKey: @"η"  andValue: @"\u1f21"];
    [self setupVowelConversionTable: 1 withKey: @"\u1f74"  andValue: @"\u1f23"];
    [self setupVowelConversionTable: 1 withKey: @"ή"  andValue: @"\u1f25"];
    [self setupVowelConversionTable: 1 withKey: @"\u1fc6"  andValue: @"\u1f27"];
    [self setupVowelConversionTable: 1 withKey: @"\u1fc3"  andValue: @"\u1f91"];
    [self setupVowelConversionTable: 1 withKey: @"\u1fc2"  andValue: @"\u1f93"];
    [self setupVowelConversionTable: 1 withKey: @"\u1fc4"  andValue: @"\u1f95"];
    [self setupVowelConversionTable: 1 withKey: @"\u1fc7"  andValue: @"\u1f97"];
    [self setupVowelConversionTable: 1 withKey: @"ι"  andValue: @"\u1f31"];
    [self setupVowelConversionTable: 1 withKey: @"\u1f76"  andValue: @"\u1f33"];
    [self setupVowelConversionTable: 1 withKey: @"ί"  andValue: @"\u1f35"];
    [self setupVowelConversionTable: 1 withKey: @"\u1fd6"  andValue: @"\u1f37"];
    [self setupVowelConversionTable: 1 withKey: @"ο"  andValue: @"\u1f41"];
    [self setupVowelConversionTable: 1 withKey: @"\u1f78"  andValue: @"\u1f43"];
    [self setupVowelConversionTable: 1 withKey: @"ό"  andValue: @"\u1f45"];
    [self setupVowelConversionTable: 1 withKey: @"υ"  andValue: @"\u1f51"];
    [self setupVowelConversionTable: 1 withKey: @"\u1f7a"  andValue: @"\u1f53"];
    [self setupVowelConversionTable: 1 withKey: @"ύ"  andValue: @"\u1f55"];
    [self setupVowelConversionTable: 1 withKey: @"\u1fe6"  andValue: @"\u1f57"];
    [self setupVowelConversionTable: 1 withKey: @"ω"  andValue: @"\u1f61"];
    [self setupVowelConversionTable: 1 withKey: @"\u1f7c"  andValue: @"\u1f63"];
    [self setupVowelConversionTable: 1 withKey: @"ώ"  andValue: @"\u1f65"];
    [self setupVowelConversionTable: 1 withKey: @"\u1ff6"  andValue: @"\u1f67"];
    [self setupVowelConversionTable: 1 withKey: @"\u1ff3"  andValue: @"\u1fa1"];
    [self setupVowelConversionTable: 1 withKey: @"\u1ff2"  andValue: @"\u1fa3"];
    [self setupVowelConversionTable: 1 withKey: @"\u1ff4"  andValue: @"\u1fa5"];
    [self setupVowelConversionTable: 1 withKey: @"\u1ff7"  andValue: @"\u1fa7"];
    [self setupVowelConversionTable: 1 withKey: @"ρ"  andValue: @"ῥ"];
    [self setupVowelConversionTable: 1 withKey: @"Α"  andValue: @"\u1f09"];
    [self setupVowelConversionTable: 1 withKey: @"\u1fba"  andValue: @"\u1f0b"];
    [self setupVowelConversionTable: 1 withKey: @"Ά"  andValue: @"\u1f0d"];
    [self setupVowelConversionTable: 1 withKey: @"\u1fbc"  andValue: @"\u1f89"];
    [self setupVowelConversionTable: 1 withKey: @"Ε"  andValue: @"\u1f19"];
    [self setupVowelConversionTable: 1 withKey: @"\u1fc8"  andValue: @"\u1f1b"];
    [self setupVowelConversionTable: 1 withKey: @"Έ"  andValue: @"\u1f1d"];
    [self setupVowelConversionTable: 1 withKey: @"Η"  andValue: @"\u1f29"];
    [self setupVowelConversionTable: 1 withKey: @"\u1fca"  andValue: @"\u1f2b"];
    [self setupVowelConversionTable: 1 withKey: @"Ή"  andValue: @"\u1f2d"];
    [self setupVowelConversionTable: 1 withKey: @"\u1fcc"  andValue: @"\u1f99"];
    [self setupVowelConversionTable: 1 withKey: @"Ι"  andValue: @"\u1f39"];
    [self setupVowelConversionTable: 1 withKey: @"\u1fda"  andValue: @"\u1f3b"];
    [self setupVowelConversionTable: 1 withKey: @"Ί"  andValue: @"\u1f3d"];
    [self setupVowelConversionTable: 1 withKey: @"Ο"  andValue: @"\u1f49"];
    [self setupVowelConversionTable: 1 withKey: @"\u1ff8"  andValue: @"\u1f4b"];
    [self setupVowelConversionTable: 1 withKey: @"Ό"  andValue: @"\u1f4d"];
    [self setupVowelConversionTable: 1 withKey: @"Υ"  andValue: @"\u1f59"];
    [self setupVowelConversionTable: 1 withKey: @"\u1fea"  andValue: @"\u1f5b"];
    [self setupVowelConversionTable: 1 withKey: @"Ύ"  andValue: @"\u1f5d"];
    [self setupVowelConversionTable: 1 withKey: @"Ω"  andValue: @"\u1f69"];
    [self setupVowelConversionTable: 1 withKey: @"\u1ffa"  andValue: @"\u1f6b"];
    [self setupVowelConversionTable: 1 withKey: @"Ώ"  andValue: @"\u1f6d"];
    [self setupVowelConversionTable: 1 withKey: @"\u1ffc"  andValue: @"\u1fa9"];
    [self setupVowelConversionTable: 1 withKey: @"Ρ"  andValue: @"Ρ"];
    
    [self setupVowelConversionTable: 2 withKey: @"α" andValue: @"\u1f00"];
    [self setupVowelConversionTable: 2 withKey: @"\u1f70" andValue: @"\u1f02"];
    [self setupVowelConversionTable: 2 withKey: @"ά" andValue: @"\u1f04"];
    [self setupVowelConversionTable: 2 withKey: @"\u1fb6" andValue: @"\u1f06"];
    [self setupVowelConversionTable: 2 withKey: @"\u1fb3" andValue: @"\u1f80"];
    [self setupVowelConversionTable: 2 withKey: @"\u1fb2" andValue: @"\u1f82"];
    [self setupVowelConversionTable: 2 withKey: @"\u1fb4" andValue: @"\u1f84"];
    [self setupVowelConversionTable: 2 withKey: @"\u1fb7" andValue: @"\u1f86"];
    [self setupVowelConversionTable: 2 withKey: @"ε" andValue: @"\u1f10"];
    [self setupVowelConversionTable: 2 withKey: @"\u1f72" andValue: @"\u1f12"];
    [self setupVowelConversionTable: 2 withKey: @"έ" andValue: @"\u1f14"];
    [self setupVowelConversionTable: 2 withKey: @"η" andValue: @"\u1f20"];
    [self setupVowelConversionTable: 2 withKey: @"\u1f74" andValue: @"\u1f22"];
    [self setupVowelConversionTable: 2 withKey: @"ή" andValue: @"\u1f24"];
    [self setupVowelConversionTable: 2 withKey: @"\u1fc6" andValue: @"\u1f26"];
    [self setupVowelConversionTable: 2 withKey: @"\u1fc3" andValue: @"\u1f90"];
    [self setupVowelConversionTable: 2 withKey: @"\u1fc2" andValue: @"\u1f92"];
    [self setupVowelConversionTable: 2 withKey: @"\u1fc4" andValue: @"\u1f94"];
    [self setupVowelConversionTable: 2 withKey: @"\u1fc7" andValue: @"\u1f96"];
    [self setupVowelConversionTable: 2 withKey: @"ι" andValue: @"\u1f30"];
    [self setupVowelConversionTable: 2 withKey: @"\u1f76" andValue: @"\u1f32"];
    [self setupVowelConversionTable: 2 withKey: @"ί" andValue: @"\u1f34"];
    [self setupVowelConversionTable: 2 withKey: @"\u1fd6" andValue: @"\u1f36"];
    [self setupVowelConversionTable: 2 withKey: @"ο" andValue: @"\u1f40"];
    [self setupVowelConversionTable: 2 withKey: @"\u1f78" andValue: @"\u1f42"];
    [self setupVowelConversionTable: 2 withKey: @"ό" andValue: @"\u1f44"];
    [self setupVowelConversionTable: 2 withKey: @"υ" andValue: @"\u1f50"];
    [self setupVowelConversionTable: 2 withKey: @"\u1f7a" andValue: @"\u1f52"];
    [self setupVowelConversionTable: 2 withKey: @"ύ" andValue: @"\u1f54"];
    [self setupVowelConversionTable: 2 withKey: @"\u1fe6" andValue: @"\u1f56"];
    [self setupVowelConversionTable: 2 withKey: @"ω" andValue: @"\u1f60"];
    [self setupVowelConversionTable: 2 withKey: @"\u1f7c" andValue: @"\u1f62"];
    [self setupVowelConversionTable: 2 withKey: @"ώ" andValue: @"\u1f64"];
    [self setupVowelConversionTable: 2 withKey: @"\u1ff6" andValue: @"\u1f66"];
    [self setupVowelConversionTable: 2 withKey: @"\u1ff3" andValue: @"\u1fa0"];
    [self setupVowelConversionTable: 2 withKey: @"\u1ff2" andValue: @"\u1fa2"];
    [self setupVowelConversionTable: 2 withKey: @"\u1ff4" andValue: @"\u1fa4"];
    [self setupVowelConversionTable: 2 withKey: @"\u1ff7" andValue: @"\u1fa6"];
    [self setupVowelConversionTable: 2 withKey: @"ρ" andValue: @"ῤ"];
    [self setupVowelConversionTable: 2 withKey: @"Α" andValue: @"\u1f08"];
    [self setupVowelConversionTable: 2 withKey: @"\u1fba" andValue: @"\u1f0a"];
    [self setupVowelConversionTable: 2 withKey: @"Ά" andValue: @"\u1f0c"];
    [self setupVowelConversionTable: 2 withKey: @"\u1fbc" andValue: @"\u1f88"];
    [self setupVowelConversionTable: 2 withKey: @"Ε" andValue: @"\u1f18"];
    [self setupVowelConversionTable: 2 withKey: @"\u1fc8" andValue: @"\u1f1a"];
    [self setupVowelConversionTable: 2 withKey: @"Έ" andValue: @"\u1f1c"];
    [self setupVowelConversionTable: 2 withKey: @"Η" andValue: @"\u1f28"];
    [self setupVowelConversionTable: 2 withKey: @"\u1fca" andValue: @"\u1f2a"];
    [self setupVowelConversionTable: 2 withKey: @"Ή" andValue: @"\u1f2c"];
    [self setupVowelConversionTable: 2 withKey: @"\u1fcc" andValue: @"\u1f98"];
    [self setupVowelConversionTable: 2 withKey: @"Ι" andValue: @"\u1f38"];
    [self setupVowelConversionTable: 2 withKey: @"\u1fda" andValue: @"\u1f3a"];
    [self setupVowelConversionTable: 2 withKey: @"Ί" andValue: @"\u1f3c"];
    [self setupVowelConversionTable: 2 withKey: @"Ο" andValue: @"\u1f48"];
    [self setupVowelConversionTable: 2 withKey: @"\u1ff8" andValue: @"\u1f4a"];
    [self setupVowelConversionTable: 2 withKey: @"Ό" andValue: @"\u1f4c"];
    [self setupVowelConversionTable: 2 withKey: @"Υ" andValue: @"\u1f58"];
    [self setupVowelConversionTable: 2 withKey: @"\u1fea" andValue: @"\u1f5a"];
    [self setupVowelConversionTable: 2 withKey: @"Ύ" andValue: @"\u1f5c"];
    [self setupVowelConversionTable: 2 withKey: @"Ω" andValue: @"\u1f68"];
    [self setupVowelConversionTable: 2 withKey: @"\u1ffa" andValue: @"\u1f6a"];
    [self setupVowelConversionTable: 2 withKey: @"Ώ" andValue: @"\u1f6c"];
    [self setupVowelConversionTable: 2 withKey: @"\u1ffc" andValue: @"\u1fa8"];

    [self setupVowelConversionTable: 3 withKey: @"α" andValue: @"ά"];
    [self setupVowelConversionTable: 3 withKey: @"\u1f00" andValue: @"\u1f04"];
    [self setupVowelConversionTable: 3 withKey: @"\u1f01" andValue: @"\u1f05"];
    [self setupVowelConversionTable: 3 withKey: @"\u1fb3" andValue: @"\u1fb4"];
    [self setupVowelConversionTable: 3 withKey: @"\u1f80" andValue: @"\u1f84"];
    [self setupVowelConversionTable: 3 withKey: @"\u1f81" andValue: @"\u1f85"];
    [self setupVowelConversionTable: 3 withKey: @"ε" andValue: @"έ"];
    [self setupVowelConversionTable: 3 withKey: @"\u1f10" andValue: @"\u1f14"];
    [self setupVowelConversionTable: 3 withKey: @"\u1f11" andValue: @"\u1f15"];
    [self setupVowelConversionTable: 3 withKey: @"η" andValue: @"ή"];
    [self setupVowelConversionTable: 3 withKey: @"\u1f20" andValue: @"\u1f24"];
    [self setupVowelConversionTable: 3 withKey: @"\u1f21" andValue: @"\u1f25"];
    [self setupVowelConversionTable: 3 withKey: @"\u1fc3" andValue: @"\u1fc4"];
    [self setupVowelConversionTable: 3 withKey: @"\u1f90" andValue: @"\u1f94"];
    [self setupVowelConversionTable: 3 withKey: @"\u1f91" andValue: @"\u1f95"];
    [self setupVowelConversionTable: 3 withKey: @"ι" andValue: @"ί"];
    [self setupVowelConversionTable: 3 withKey: @"\u1f30" andValue: @"\u1f34"];
    [self setupVowelConversionTable: 3 withKey: @"\u1f31" andValue: @"\u1f35"];
    [self setupVowelConversionTable: 3 withKey: @"ϊ" andValue: @"\u1fd3"];
    [self setupVowelConversionTable: 3 withKey: @"ο" andValue: @"ό"];
    [self setupVowelConversionTable: 3 withKey: @"\u1f40" andValue: @"\u1f44"];
    [self setupVowelConversionTable: 3 withKey: @"\u1f41" andValue: @"\u1f45"];
    [self setupVowelConversionTable: 3 withKey: @"υ" andValue: @"ύ"];
    [self setupVowelConversionTable: 3 withKey: @"\u1f50" andValue: @"\u1f54"];
    [self setupVowelConversionTable: 3 withKey: @"\u1f51" andValue: @"\u1f55"];
    [self setupVowelConversionTable: 3 withKey: @"ϋ" andValue: @"ΰ"];
    [self setupVowelConversionTable: 3 withKey: @"ω" andValue: @"ώ"];
    [self setupVowelConversionTable: 3 withKey: @"\u1f60" andValue: @"\u1f64"];
    [self setupVowelConversionTable: 3 withKey: @"\u1f61" andValue: @"\u1f65"];
    [self setupVowelConversionTable: 3 withKey: @"\u1ff3" andValue: @"\u1ff4"];
    [self setupVowelConversionTable: 3 withKey: @"\u1fa0" andValue: @"\u1fa4"];
    [self setupVowelConversionTable: 3 withKey: @"\u1fa1" andValue: @"\u1fa5"];
    [self setupVowelConversionTable: 3 withKey: @"Α" andValue: @"Ά"];
    [self setupVowelConversionTable: 3 withKey: @"\u1f08" andValue: @"\u1f0c"];
    [self setupVowelConversionTable: 3 withKey: @"\u1f09" andValue: @"\u1f0d"];
    [self setupVowelConversionTable: 3 withKey: @"\u1f88" andValue: @"\u1f8c"];
    [self setupVowelConversionTable: 3 withKey: @"\u1f89" andValue: @"\u1f8d"];
    [self setupVowelConversionTable: 3 withKey: @"Ε" andValue: @"Έ"];
    [self setupVowelConversionTable: 3 withKey: @"\u1f18" andValue: @"\u1f1c"];
    [self setupVowelConversionTable: 3 withKey: @"\u1f19" andValue: @"\u1f1d"];
    [self setupVowelConversionTable: 3 withKey: @"Η" andValue: @"Ή"];
    [self setupVowelConversionTable: 3 withKey: @"\u1f28" andValue: @"\u1f2c"];
    [self setupVowelConversionTable: 3 withKey: @"\u1f29" andValue: @"\u1f2d"];
    [self setupVowelConversionTable: 3 withKey: @"\u1f98" andValue: @"\u1f9c"];
    [self setupVowelConversionTable: 3 withKey: @"\u1f99" andValue: @"\u1f9d"];
    [self setupVowelConversionTable: 3 withKey: @"Ι" andValue: @"Ί"];
    [self setupVowelConversionTable: 3 withKey: @"\u1f38" andValue: @"\u1f3c"];
    [self setupVowelConversionTable: 3 withKey: @"\u1f39" andValue: @"\u1f3d"];
    [self setupVowelConversionTable: 3 withKey: @"Ϊ" andValue: @"\u1fd9"];
    [self setupVowelConversionTable: 3 withKey: @"Ο" andValue: @"Ό"];
    [self setupVowelConversionTable: 3 withKey: @"\u1f48" andValue: @"\u1f4c"];
    [self setupVowelConversionTable: 3 withKey: @"\u1f49" andValue: @"\u1f4d"];
    [self setupVowelConversionTable: 3 withKey: @"Υ" andValue: @"Ύ"];
    [self setupVowelConversionTable: 3 withKey: @"\u1f58" andValue: @"\u1f5c"];
    [self setupVowelConversionTable: 3 withKey: @"\u1f59" andValue: @"\u1f5d"];
    [self setupVowelConversionTable: 3 withKey: @"Ϋ" andValue: @"Ϋ"];
    [self setupVowelConversionTable: 3 withKey: @"Ω" andValue: @"Ώ"];
    [self setupVowelConversionTable: 3 withKey: @"\u1f68" andValue: @"\u1f6c"];
    [self setupVowelConversionTable: 3 withKey: @"\u1f69" andValue: @"\u1f6d"];
    [self setupVowelConversionTable: 3 withKey: @"\u1fa8" andValue: @"\u1fac"];
    [self setupVowelConversionTable: 3 withKey: @"\u1fa9" andValue: @"\u1fad"];

    [self setupVowelConversionTable: 4 withKey: @"α" andValue: @"\u1f70"];
    [self setupVowelConversionTable: 4 withKey: @"\u1f00" andValue: @"\u1f02"];
    [self setupVowelConversionTable: 4 withKey: @"\u1f01" andValue: @"\u1f03"];
    [self setupVowelConversionTable: 4 withKey: @"\u1fb3" andValue: @"\u1fb2"];
    [self setupVowelConversionTable: 4 withKey: @"\u1f80" andValue: @"\u1f82"];
    [self setupVowelConversionTable: 4 withKey: @"\u1f81" andValue: @"\u1f83"];
    [self setupVowelConversionTable: 4 withKey: @"ε" andValue: @"\u1f72"];
    [self setupVowelConversionTable: 4 withKey: @"\u1f10" andValue: @"\u1f12"];
    [self setupVowelConversionTable: 4 withKey: @"\u1f11" andValue: @"\u1f13"];
    [self setupVowelConversionTable: 4 withKey: @"η" andValue: @"\u1f74"];
    [self setupVowelConversionTable: 4 withKey: @"\u1f20" andValue: @"\u1f22"];
    [self setupVowelConversionTable: 4 withKey: @"\u1f21" andValue: @"\u1f23"];
    [self setupVowelConversionTable: 4 withKey: @"\u1fc3" andValue: @"\u1fc2"];
    [self setupVowelConversionTable: 4 withKey: @"\u1f90" andValue: @"\u1f92"];
    [self setupVowelConversionTable: 4 withKey: @"\u1f91" andValue: @"\u1f93"];
    [self setupVowelConversionTable: 4 withKey: @"ι" andValue: @"\u1f76"];
    [self setupVowelConversionTable: 4 withKey: @"\u1f30" andValue: @"\u1f32"];
    [self setupVowelConversionTable: 4 withKey: @"\u1f31" andValue: @"\u1f33"];
    [self setupVowelConversionTable: 4 withKey: @"ϊ" andValue: @"\u1fd2"];
    [self setupVowelConversionTable: 4 withKey: @"ο" andValue: @"\u1f78"];
    [self setupVowelConversionTable: 4 withKey: @"\u1f40" andValue: @"\u1f42"];
    [self setupVowelConversionTable: 4 withKey: @"\u1f41" andValue: @"\u1f43"];
    [self setupVowelConversionTable: 4 withKey: @"υ" andValue: @"\u1f7a"];
    [self setupVowelConversionTable: 4 withKey: @"\u1f50" andValue: @"\u1f52"];
    [self setupVowelConversionTable: 4 withKey: @"\u1f51" andValue: @"\u1f53"];
    [self setupVowelConversionTable: 4 withKey: @"ϋ" andValue: @"\u1fe2"];
    [self setupVowelConversionTable: 4 withKey: @"ω" andValue: @"\u1f7c"];
    [self setupVowelConversionTable: 4 withKey: @"\u1f60" andValue: @"\u1f62"];
    [self setupVowelConversionTable: 4 withKey: @"\u1f61" andValue: @"\u1f63"];
    [self setupVowelConversionTable: 4 withKey: @"\u1ff3" andValue: @"\u1ff2"];
    [self setupVowelConversionTable: 4 withKey: @"\u1fa0" andValue: @"\u1fa2"];
    [self setupVowelConversionTable: 4 withKey: @"\u1fa1" andValue: @"\u1fa3"];
    [self setupVowelConversionTable: 4 withKey: @"Α" andValue: @"\u1fba"];
    [self setupVowelConversionTable: 4 withKey: @"\u1f08" andValue: @"\u1f0a"];
    [self setupVowelConversionTable: 4 withKey: @"\u1f09" andValue: @"\u1f0b"];
    [self setupVowelConversionTable: 4 withKey: @"\u1f88" andValue: @"\u1f8a"];
    [self setupVowelConversionTable: 4 withKey: @"\u1f89" andValue: @"\u1f8b"];
    [self setupVowelConversionTable: 4 withKey: @"Ε" andValue: @"\u1fc8"];
    [self setupVowelConversionTable: 4 withKey: @"\u1f18" andValue: @"\u1f1a"];
    [self setupVowelConversionTable: 4 withKey: @"\u1f19" andValue: @"\u1f1b"];
    [self setupVowelConversionTable: 4 withKey: @"Η" andValue: @"\u1fca"];
    [self setupVowelConversionTable: 4 withKey: @"\u1f28" andValue: @"\u1f2a"];
    [self setupVowelConversionTable: 4 withKey: @"\u1f29" andValue: @"\u1f2b"];
    [self setupVowelConversionTable: 4 withKey: @"\u1f98" andValue: @"\u1f9a"];
    [self setupVowelConversionTable: 4 withKey: @"\u1f99" andValue: @"\u1f9b"];
    [self setupVowelConversionTable: 4 withKey: @"Ι" andValue: @"\u1fda"];
    [self setupVowelConversionTable: 4 withKey: @"\u1f38" andValue: @"\u1f3a"];
    [self setupVowelConversionTable: 4 withKey: @"\u1f39" andValue: @"\u1f3b"];
    [self setupVowelConversionTable: 4 withKey: @"Ο" andValue: @"\u1ff8"];
    [self setupVowelConversionTable: 4 withKey: @"\u1f48" andValue: @"\u1f4a"];
    [self setupVowelConversionTable: 4 withKey: @"\u1f49" andValue: @"\u1f4b"];
    [self setupVowelConversionTable: 4 withKey: @"Υ" andValue: @"\u1fea"];
    [self setupVowelConversionTable: 4 withKey: @"\u1f58" andValue: @"\u1f5a"];
    [self setupVowelConversionTable: 4 withKey: @"\u1f59" andValue: @"\u1f5b"];
    [self setupVowelConversionTable: 4 withKey: @"Ω" andValue: @"\u1ffa"];
    [self setupVowelConversionTable: 4 withKey: @"\u1f68" andValue: @"\u1f6a"];
    [self setupVowelConversionTable: 4 withKey: @"\u1f69" andValue: @"\u1f6b"];
    [self setupVowelConversionTable: 4 withKey: @"\u1fa8" andValue: @"\u1faa"];
    [self setupVowelConversionTable: 4 withKey: @"\u1fa9" andValue: @"\u1fab"];
    
    [self setupVowelConversionTable: 5 withKey: @"α" andValue: @"\u1fb6"];
    [self setupVowelConversionTable: 5 withKey: @"\u1f00" andValue: @"\u1f06"];
    [self setupVowelConversionTable: 5 withKey: @"\u1f01" andValue: @"\u1f07"];
    [self setupVowelConversionTable: 5 withKey: @"\u1fb3" andValue: @"\u1fb7"];
    [self setupVowelConversionTable: 5 withKey: @"\u1f80" andValue: @"\u1f86"];
    [self setupVowelConversionTable: 5 withKey: @"\u1f81" andValue: @"\u1f87"];
    [self setupVowelConversionTable: 5 withKey: @"η" andValue: @"\u1fc6"];
    [self setupVowelConversionTable: 5 withKey: @"\u1f20" andValue: @"\u1f26"];
    [self setupVowelConversionTable: 5 withKey: @"\u1f21" andValue: @"\u1f27"];
    [self setupVowelConversionTable: 5 withKey: @"\u1fc3" andValue: @"\u1fc7"];
    [self setupVowelConversionTable: 5 withKey: @"\u1f90" andValue: @"\u1f96"];
    [self setupVowelConversionTable: 5 withKey: @"\u1f91" andValue: @"\u1f97"];
    [self setupVowelConversionTable: 5 withKey: @"ι" andValue: @"\u1fd6"];
    [self setupVowelConversionTable: 5 withKey: @"\u1f30" andValue: @"\u1f36"];
    [self setupVowelConversionTable: 5 withKey: @"\u1f31" andValue: @"\u1f37"];
    [self setupVowelConversionTable: 5 withKey: @"ϊ" andValue: @"\u1fd7"];
    [self setupVowelConversionTable: 5 withKey: @"υ" andValue: @"\u1fe6"];
    [self setupVowelConversionTable: 5 withKey: @"\u1f50" andValue: @"\u1f56"];
    [self setupVowelConversionTable: 5 withKey: @"\u1f51" andValue: @"\u1f57"];
    [self setupVowelConversionTable: 5 withKey: @"ϋ" andValue: @"\u1fe7"];
    [self setupVowelConversionTable: 5 withKey: @"ω" andValue: @"\u1ff6"];
    [self setupVowelConversionTable: 5 withKey: @"\u1f60" andValue: @"\u1f66"];
    [self setupVowelConversionTable: 5 withKey: @"\u1f61" andValue: @"\u1f67"];
    [self setupVowelConversionTable: 5 withKey: @"\u1ff3" andValue: @"\u1ff7"];  //#
    [self setupVowelConversionTable: 5 withKey: @"\u1fa0" andValue: @"\u1fa6"];
    [self setupVowelConversionTable: 5 withKey: @"\u1fa1" andValue: @"\u1fa7"];
    [self setupVowelConversionTable: 5 withKey: @"\u1f08" andValue: @"\u1f0e"];
    [self setupVowelConversionTable: 5 withKey: @"\u1f09" andValue: @"\u1f0f"];
    [self setupVowelConversionTable: 5 withKey: @"\u1f88" andValue: @"\u1f8e"];
    [self setupVowelConversionTable: 5 withKey: @"\u1f89" andValue: @"\u1f8f"]; //Α
    [self setupVowelConversionTable: 5 withKey: @"\u1f28" andValue: @"\u1f2e"];
    [self setupVowelConversionTable: 5 withKey: @"\u1f29" andValue: @"\u1f2f"];
    [self setupVowelConversionTable: 5 withKey: @"\u1f98" andValue: @"\u1f9e"];
    [self setupVowelConversionTable: 5 withKey: @"\u1f99" andValue: @"\u1f9f"]; //Η
    [self setupVowelConversionTable: 5 withKey: @"\u1f38" andValue: @"\u1f3e"];
    [self setupVowelConversionTable: 5 withKey: @"\u1f39" andValue: @"\u1f3f"]; //Ι
    [self setupVowelConversionTable: 5 withKey: @"\u1f58" andValue: @"\u1f5e"];
    [self setupVowelConversionTable: 5 withKey: @"\u1f59" andValue: @"\u1f5f"]; //Υ
    [self setupVowelConversionTable: 5 withKey: @"\u1f68" andValue: @"\u1f6e"];
    [self setupVowelConversionTable: 5 withKey: @"\u1f69" andValue: @"\u1f6f"];
    [self setupVowelConversionTable: 5 withKey: @"\u1fa8" andValue: @"\u1fae"];
    [self setupVowelConversionTable: 5 withKey: @"\u1fa9" andValue: @"\u1faf"]; //Ω

    [self setupVowelConversionTable: 6 withKey: @"ι" andValue: @"ϊ"];
    [self setupVowelConversionTable: 6 withKey: @"\u1f76" andValue: @"\u1fd2"];
    [self setupVowelConversionTable: 6 withKey: @"ί" andValue: @"\u1fd3"];
    [self setupVowelConversionTable: 6 withKey: @"\u1fd6" andValue: @"\u1fd7"];
    [self setupVowelConversionTable: 6 withKey: @"υ" andValue: @"ϋ"];
    [self setupVowelConversionTable: 6 withKey: @"\u1f7a" andValue: @"\u1fe2"];
    [self setupVowelConversionTable: 6 withKey: @"ύ" andValue: @"ΰ"];
    [self setupVowelConversionTable: 6 withKey: @"\u1fe6" andValue: @"\u1fe7"];
    [self setupVowelConversionTable: 6 withKey: @"Ι" andValue: @"Ϊ"];
    [self setupVowelConversionTable: 6 withKey: @"Υ" andValue: @"Ϋ"];

    [self setupVowelConversionTable: 7 withKey: @"α" andValue: @"\u1fb3"];
    [self setupVowelConversionTable: 7 withKey: @"\u1f00" andValue: @"\u1f80"];
    [self setupVowelConversionTable: 7 withKey: @"\u1f01" andValue: @"\u1f81"];
    [self setupVowelConversionTable: 7 withKey: @"\u1f70" andValue: @"\u1fb2"];
    [self setupVowelConversionTable: 7 withKey: @"ά" andValue: @"\u1fb4"];
    [self setupVowelConversionTable: 7 withKey: @"\u1fb6" andValue: @"\u1fb7"];
    [self setupVowelConversionTable: 7 withKey: @"\u1f02" andValue: @"\u1f82"];
    [self setupVowelConversionTable: 7 withKey: @"\u1f03" andValue: @"\u1f83"];
    [self setupVowelConversionTable: 7 withKey: @"\u1f04" andValue: @"\u1f84"];
    [self setupVowelConversionTable: 7 withKey: @"\u1f06" andValue: @"\u1f86"];
    [self setupVowelConversionTable: 7 withKey: @"\u1f07" andValue: @"\u1f87"];
    [self setupVowelConversionTable: 7 withKey: @"η" andValue: @"\u1fc3"];
    [self setupVowelConversionTable: 7 withKey: @"\u1f20" andValue: @"\u1f90"];
    [self setupVowelConversionTable: 7 withKey: @"\u1f21" andValue: @"\u1f91"];
    [self setupVowelConversionTable: 7 withKey: @"\u1f74" andValue: @"\u1fc2"];
    [self setupVowelConversionTable: 7 withKey: @"ή" andValue: @"\u1fc4"];
    [self setupVowelConversionTable: 7 withKey: @"\u1fc6" andValue: @"\u1fc7"];
    [self setupVowelConversionTable: 7 withKey: @"\u1f22" andValue: @"\u1f92"];
    [self setupVowelConversionTable: 7 withKey: @"\u1f23" andValue: @"\u1f93"];
    [self setupVowelConversionTable: 7 withKey: @"\u1f24" andValue: @"\u1f94"];
    [self setupVowelConversionTable: 7 withKey: @"\u1f26" andValue: @"\u1f96"];
    [self setupVowelConversionTable: 7 withKey: @"\u1f27" andValue: @"\u1f97"];
    [self setupVowelConversionTable: 7 withKey: @"ω" andValue: @"\u1ff3"];
    [self setupVowelConversionTable: 7 withKey: @"\u1f60" andValue: @"\u1fa0"];
    [self setupVowelConversionTable: 7 withKey: @"\u1f61" andValue: @"\u1fa1"];
    [self setupVowelConversionTable: 7 withKey: @"\u1f7c" andValue: @"\u1ff2"];
    [self setupVowelConversionTable: 7 withKey: @"ώ" andValue: @"\u1ff4"];
    [self setupVowelConversionTable: 7 withKey: @"\u1ff6" andValue: @"\u1ff7"];
    [self setupVowelConversionTable: 7 withKey: @"\u1f62" andValue: @"\u1fa2"];
    [self setupVowelConversionTable: 7 withKey: @"\u1f63" andValue: @"\u1fa3"];
    [self setupVowelConversionTable: 7 withKey: @"\u1f64" andValue: @"\u1fa4"];
    [self setupVowelConversionTable: 7 withKey: @"\u1f66" andValue: @"\u1fa6"];
    [self setupVowelConversionTable: 7 withKey: @"\u1f67" andValue: @"\u1fa7"];
    [self setupVowelConversionTable: 7 withKey: @"Α" andValue: @"\u1fbc"];
    [self setupVowelConversionTable: 7 withKey: @"\u1f08" andValue: @"\u1f88"];
    [self setupVowelConversionTable: 7 withKey: @"\u1f09" andValue: @"\u1f89"];
    [self setupVowelConversionTable: 7 withKey: @"\u1f0a" andValue: @"\u1f8a"];
    [self setupVowelConversionTable: 7 withKey: @"\u1f0b" andValue: @"\u1f8b"];
    [self setupVowelConversionTable: 7 withKey: @"\u1f0c" andValue: @"\u1f8c"];
    [self setupVowelConversionTable: 7 withKey: @"\u1f0e" andValue: @"\u1f8e"];
    [self setupVowelConversionTable: 7 withKey: @"\u1f0f" andValue: @"\u1f8f"];
    [self setupVowelConversionTable: 7 withKey: @"Η" andValue: @"\u1fcc"];
    [self setupVowelConversionTable: 7 withKey: @"\u1f28" andValue: @"\u1f98"];
    [self setupVowelConversionTable: 7 withKey: @"\u1f29" andValue: @"\u1f99"];
    [self setupVowelConversionTable: 7 withKey: @"\u1f2a" andValue: @"\u1f9a"];
    [self setupVowelConversionTable: 7 withKey: @"\u1f2b" andValue: @"\u1f9b"];
    [self setupVowelConversionTable: 7 withKey: @"\u1f2c" andValue: @"\u1f9c"];
    [self setupVowelConversionTable: 7 withKey: @"\u1f2e" andValue: @"\u1f9e"];
    [self setupVowelConversionTable: 7 withKey: @"\u1f2f" andValue: @"\u1f9f"];
    [self setupVowelConversionTable: 7 withKey: @"Ω" andValue: @"\u1ffc"];
    [self setupVowelConversionTable: 7 withKey: @"\u1f68" andValue: @"\u1fa8"];
    [self setupVowelConversionTable: 7 withKey: @"\u1f69" andValue: @"\u1fa9"];
    [self setupVowelConversionTable: 7 withKey: @"\u1f6a" andValue: @"\u1faa"];
    [self setupVowelConversionTable: 7 withKey: @"\u1f6b" andValue: @"\u1fab"];
    [self setupVowelConversionTable: 7 withKey: @"\u1f6c" andValue: @"\u1fac"];
    [self setupVowelConversionTable: 7 withKey: @"\u1f6e" andValue: @"\u1fae"];
    [self setupVowelConversionTable: 7 withKey: @"\u1f6f" andValue: @"\u1faf"];
}

- (void) setupVowelConversionTable: (NSInteger) ctlCode withKey: (NSString *) keyVal andValue: (NSString *) valueVal
{
    switch (ctlCode)
    {
        case 1: [addRoughBreathing setObject:valueVal forKey:keyVal]; break;
        case 2: [addSmoothBreathing setObject:valueVal forKey:keyVal]; break;
        case 3: [addAccute setObject:valueVal forKey:keyVal]; break;
        case 4: [addGrave setObject:valueVal forKey:keyVal]; break;
        case 5: [addCirc setObject:valueVal forKey:keyVal]; break;
        case 6: [addDiaeresis setObject:valueVal forKey:keyVal]; break;
        case 7: [addIotaSub setObject:valueVal forKey:keyVal]; break;
        default: break;
    }
}

- (NSString *) processRoughBreathing: (NSString *) originalChar
{
    NSString *replacementChar;
    
    replacementChar = nil;
    replacementChar = [addRoughBreathing valueForKey:originalChar];
    if( replacementChar == nil ) return originalChar;
    else return replacementChar;
}

- (NSString *) processSmoothBreathing: (NSString *) originalChar
{
    NSString *replacementChar;
    
    replacementChar = nil;
    replacementChar = [addSmoothBreathing valueForKey:originalChar];
    if( replacementChar == nil ) return originalChar;
    else return replacementChar;
}

- (NSString *) processAccute: (NSString *) originalChar
{
    NSString *replacementChar;
    
    replacementChar = nil;
    replacementChar = [addAccute valueForKey:originalChar];
    if( replacementChar == nil ) return originalChar;
    else return replacementChar;
}

- (NSString *) processGrave: (NSString *) originalChar
{
    NSString *replacementChar;
    
    replacementChar = nil;
    replacementChar = [addGrave valueForKey:originalChar];
    if( replacementChar == nil ) return originalChar;
    else return replacementChar;
}

- (NSString *) processCirc: (NSString *) originalChar
{
    NSString *replacementChar;
    
    replacementChar = nil;
    replacementChar = [addCirc valueForKey:originalChar];
    if( replacementChar == nil ) return originalChar;
    else return replacementChar;
}

- (NSString *) processDiaeresis: (NSString *) originalChar
{
    NSString *replacementChar;
    
    replacementChar = nil;
    replacementChar = [addDiaeresis valueForKey:originalChar];
    if( replacementChar == nil ) return originalChar;
    else return replacementChar;
}

- (NSString *) processIotaSub: (NSString *) originalChar
{
    NSString *replacementChar;
    
    replacementChar = nil;
    replacementChar = [addIotaSub valueForKey:originalChar];
    if( replacementChar == nil ) return originalChar;
    else return replacementChar;
}

@end
