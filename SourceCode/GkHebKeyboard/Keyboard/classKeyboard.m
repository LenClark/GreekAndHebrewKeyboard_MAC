//
//  classKeyboard.m
//  GkHebKeyboard
//
//  Created by Leonard Clark on 13/12/2020.
//

#import "classKeyboard.h"

@implementation classKeyboard

@synthesize mainWindow;
@synthesize globalVarsKeyboard;
@synthesize greekProcessingKeyboard;
@synthesize enteredText;
@synthesize btnCapsLight;
@synthesize btnHebCapsLight;

@synthesize pnlGkKeyboard;
@synthesize pnlHebKeyboard;

@synthesize nonPrintKeys;
@synthesize keyWidths;
@synthesize hebKeyFace;
@synthesize hebKeyHint;
@synthesize hebAccents;
@synthesize hebAccentHints;
@synthesize gkKeyFaceMin;
@synthesize gkKeyFaceMaj;
@synthesize gkKeyHintMin;
@synthesize gkKeyHintMaj;
@synthesize isGkMiniscule;
@synthesize isHebMiniscule;
@synthesize greekHebrewTabView;

/*------------------------------------------------------------------------------------------------------*
 *                                                                                                      *
 *                                    Locally Global Variables                                          *
 *                                    ------------------------                                          *
 *                                                                                                      *
 *  nonPrintKeys:     This is simply a list of simple text, each being the text on a key which is *not* *
 *                    used in the creation of Greek or Hebrew text.                                     *
 *  keyWidths:        Essentially, this lists point widthd for each key of the keyboard.  It is a two-  *
 *                    dimensional array, implemented as an array of arrays.  The inner arrays are each  *
 *                    an array of a single row's keys.                                                  *
 *  hebKeyFace:       This is a two-dimensional array, on the same pattern as keyWidthd: each inner     *
 *                    array represents a row of the keyboard.  The result is an array of Strings which  *
 *                    either represent the key text or a "hint".  Specific logic has been introduced to *
 *                    handle input hex characters.                                                      *
 *  subsequent vars   follow the same pattern as hebKeyFace                                             *
 *  theKeys:          These follow the same pattern but they store specific NSButton references         *
 *                                                                                                      *
 *------------------------------------------------------------------------------------------------------*/

const NSUInteger noOfRows = 5, noOfCols = 14, keyGap = 4, xmax = 63, absKeyWidth = 48;

NSInteger gkCaseState, hebCaseState;
NSMutableArray *gkButtonObjects;
NSMutableArray *hebButtonObjects;

- (void) initialiseKeyboard
{
    greekProcessingKeyboard = globalVarsKeyboard.greekProcessing;
    isGkMiniscule = true;
    isHebMiniscule = true;
    gkCaseState = 0;
    nonPrintKeys = [self loadNonPrintKeys];
    keyWidths = [self loadKeyWidth];
    hebKeyFace = [self loadFileData: @"hebKeyFace"];
    hebKeyHint = [self loadFileData: @"hebKeyHint"];
    hebAccents = [self loadFileData: @"hebAccents"];
    hebAccentHints = [self loadFileData: @"hebAccentHints"];
    gkKeyFaceMin = [self loadFileData: @"gkKeyFaceMin"];
    gkKeyFaceMaj = [self loadFileData: @"gkKeyFaceMaj"];
    gkKeyHintMin = [self loadFileData: @"gkKeyHintMin"];
    gkKeyHintMaj = [self loadFileData: @"gkKeyHintMaj"];
    [self setSpecificKeys:true];
    [self setSpecificKeys:false];
}

- (void) setSpecificKeys: (BOOL) isGreek
{
    NSMutableArray *buttonObjects, *interimKeys, *rowOfKeys;
    NSInteger keyRow, keyCol, maxForRow, keyWidth, accummulativeWidth, tagCount, baseHeight;
    NSString *buttonText;
    NSButton *activeButton;

    if( isGreek )
    {
        gkButtonObjects = [[NSMutableArray alloc] initWithCapacity:xmax];
        buttonObjects = gkButtonObjects;
    }
    else
    {
        hebButtonObjects = [[NSMutableArray alloc] initWithCapacity:xmax];
        buttonObjects = hebButtonObjects;
    }
    tagCount = 0;
    interimKeys = [[NSMutableArray alloc] init];
    rowOfKeys = [[NSMutableArray alloc] init];
    maxForRow = 0;
    if( isGreek ) baseHeight = [pnlGkKeyboard frame].size.height;
    else baseHeight = [pnlHebKeyboard frame].size.height;
    for (keyRow = 0; keyRow < noOfRows; keyRow++)
    {
        switch (keyRow)
        {
            case 0:
            case 1:
            case 2: maxForRow = noOfCols; break;
            case 3: maxForRow = 13; break;
            case 4: maxForRow = 8; break;
        }
        accummulativeWidth = 16;
        for (keyCol = 0; keyCol < maxForRow; keyCol++)
        {
            keyWidth = [self getKeyWidth:keyRow forKeyCol:keyCol];
            activeButton = [[NSButton alloc] initWithFrame:NSMakeRect( accummulativeWidth, baseHeight - ((keyRow + 1) * (absKeyWidth + keyGap)), keyWidth, absKeyWidth )];
            [buttonObjects setObject:activeButton atIndexedSubscript:tagCount];
            switch (keyWidth)
            {
                case 47:
                {
                    activeButton.image = [[NSImage alloc] initByReferencingFile:[[NSBundle mainBundle] pathForResource:@"blank47" ofType:@"png"]];
                    keyWidth = 48;
                }
                    break;
                case 48: activeButton.image = [[NSImage alloc] initByReferencingFile:[[NSBundle mainBundle] pathForResource:@"blank48" ofType:@"png"]]; break;
                case 49:
                {
                    activeButton.image = [[NSImage alloc] initByReferencingFile:[[NSBundle mainBundle] pathForResource:@"blank48c" ofType:@"png"]];
                    keyWidth = 48;
                }
                    break;
                case 64: activeButton.image = [[NSImage alloc] initByReferencingFile:[[NSBundle mainBundle] pathForResource:@"blank64w" ofType:@"png"]]; break;
                case 96: activeButton.image = [[NSImage alloc] initByReferencingFile:[[NSBundle mainBundle] pathForResource:@"blank96w" ofType:@"png"]]; break;
                case 310: activeButton.image = [[NSImage alloc] initByReferencingFile:[[NSBundle mainBundle] pathForResource:@"space310w" ofType:@"png"]]; break;
            }
            if( isGreek)
            {
                buttonText = [self getText:gkKeyFaceMin forRow: keyRow forKeyCol:keyCol];
                [activeButton setToolTip:[self getText:gkKeyHintMin forRow:keyRow forKeyCol:keyCol]];
                [activeButton setAction:@selector(greekKeyPressed:)];
                [pnlGkKeyboard addSubview:activeButton];
            }
            else
            {
                buttonText = [self getText:hebKeyFace forRow: keyRow forKeyCol:keyCol];
                [activeButton setToolTip:[self getText:hebKeyHint forRow:keyRow forKeyCol:keyCol]];
                [activeButton setAction:@selector(hebrewKeyPressed:)];
                [pnlHebKeyboard addSubview:activeButton];
                if((keyRow == 1) && ( ( keyCol == 1 ) || ( keyCol == 2 ) ) ) buttonText = [[NSString alloc] initWithFormat:@"\u05e9%@", buttonText];
            }
            activeButton.title = buttonText;
            activeButton.alignment = NSTextAlignmentCenter;
            activeButton.font = [NSFont fontWithName:@"Times New Roman" size:22.0];
            activeButton.tag = ++tagCount;
            [activeButton setTarget:self];
            accummulativeWidth += keyWidth + keyGap;
        }
    }
}

- (NSArray *) loadNonPrintKeys
{
    NSString *fileBuffer, *fileContent;
    NSArray *targetArray;
    
    fileBuffer = [[NSBundle mainBundle] pathForResource:@"nonprintKeys" ofType:@"txt"];
    fileContent = [[NSString alloc] initWithContentsOfFile:fileBuffer encoding:NSUTF8StringEncoding error:nil];
    targetArray = [[NSArray alloc] initWithArray:[fileContent componentsSeparatedByString:@"\r"]];
    return targetArray;
}

- (NSArray *) loadKeyWidth
{
    NSUInteger idx, jdx;
    NSString *fileBuffer, *fileContent;
    NSArray *interimArray;
    NSMutableArray *targetArray, *partialArray;
    
    fileBuffer = [[NSBundle mainBundle] pathForResource:@"keyWidths" ofType:@"txt"];
    fileContent = [[NSString alloc] initWithContentsOfFile:fileBuffer encoding:NSUTF8StringEncoding error:nil];
    interimArray = [[NSArray alloc] initWithArray:[fileContent componentsSeparatedByString:@"\r"]];
    targetArray = [[NSMutableArray alloc] init];
    partialArray = [[NSMutableArray alloc] init];
    idx = 0; jdx = 0;
    for( NSString *fileItem in interimArray)
    {
        [partialArray addObject:[NSNumber numberWithInteger:[fileItem integerValue]]];
        if (++jdx == noOfCols)
        {
            [targetArray addObject:partialArray];
            jdx = 0;
            if (++idx == noOfRows) break;
            partialArray = [[NSMutableArray alloc] init];
        }
    }
    return [targetArray copy];
}

- (NSArray *) loadFileData: (NSString *) fileName
{
    uint endValue;
    NSUInteger idx, jdx;
    unichar firstChar;
    NSString *fileBuffer, *fileContent, *pureHex;
    NSArray *interimArray;
    NSMutableArray *targetArray, *partialArray;
    NSScanner *scanSrce;

    fileBuffer = [[NSBundle mainBundle] pathForResource:fileName ofType:@"txt"];
    fileContent = [[NSString alloc] initWithContentsOfFile:fileBuffer encoding:NSUTF8StringEncoding error:nil];
    interimArray = [[NSArray alloc] initWithArray:[fileContent componentsSeparatedByString:@"\r"]];
    targetArray = [[NSMutableArray alloc] init];
    partialArray = [[NSMutableArray alloc] init];
    idx = 0; jdx = 0;
    for( NSString *fileItem in interimArray)
    {
        if( [fileItem length] > 0 )
        {
            firstChar = [fileItem characterAtIndex:0];
            if( ( [fileItem length] > 0 ) && ( firstChar == '\\') )
            {
                pureHex = [[NSString alloc] initWithString:[fileItem substringFromIndex:2]];
                scanSrce = [NSScanner scannerWithString:pureHex];
                [scanSrce scanHexInt:&endValue];
                [partialArray addObject:[[NSString alloc] initWithFormat:@"%C", (unichar) endValue]];
            }
            else [partialArray addObject:[[NSString alloc] initWithString:fileItem]];
        }
        else [partialArray addObject:[[NSString alloc] initWithString:fileItem]];
        if (++jdx == noOfCols)
        {
            [targetArray addObject:partialArray];
            jdx = 0;
            if (++idx == noOfRows) break;
            partialArray = [[NSMutableArray alloc] init];
        }
    }
    return [targetArray copy];
}

- (NSUInteger) getKeyWidth: (NSUInteger) rowValue forKeyCol: (NSUInteger) colValue
{
NSNumber *rawWidth;
NSMutableArray *rowArray;

rowArray = [keyWidths objectAtIndex:rowValue];
rawWidth = [rowArray objectAtIndex:colValue];
return [rawWidth integerValue];
}

- (NSString *) getText: (NSArray *) sourceArray forRow: (NSUInteger) rowValue forKeyCol: (NSUInteger) colValue
{
NSInteger arrayLength;
NSString *finalResult;
NSMutableArray *rowArray;

arrayLength = [sourceArray count];
if( arrayLength <= rowValue) return @"";
rowArray = [sourceArray objectAtIndex:rowValue];
finalResult = [[NSString alloc] initWithString:[rowArray objectAtIndex:colValue]];
return finalResult;
}

- (void) greekKeyPressed: (id) sender
{
//    const NSInteger colsPerRow = 14;

    bool doOutput = true, isChar = false;
    NSInteger tagVal;
    NSUInteger cursorPstn;
    NSRange selectedRange;
    NSString *keyVal;
    NSButton *currButton;
    
    currButton = (NSButton *)sender;
    tagVal = (int)[currButton tag];
    if( isGkMiniscule )
    {
        switch (tagVal)
        {
            case 2: keyVal = @"1"; break;
            case 3: keyVal = @"2"; break;
            case 4: keyVal = @"3"; break;
            case 5: keyVal = @"4"; break;
            case 6: keyVal = @"5"; break;
            case 7: keyVal = @"6"; break;
            case 8: keyVal = @"7"; break;
            case 9: keyVal = @"8"; break;
            case 10: keyVal = @"9"; break;
            case 11: keyVal = @"0"; break;
            case 12: keyVal = @""; break;
            case 13: keyVal = @""; break;
            case 14: [self greekHandleBackspace: false]; break;
            case 15: enteredText.string = @""; break;
            case 16: [self handleGkExtra:[greekProcessingKeyboard addAccute]]; break;
            case 17: keyVal = @"ς"; break;
            case 18: keyVal = @"ε"; break;
            case 19: keyVal = @"ρ"; break;
            case 20: keyVal = @"τ"; break;
            case 21: keyVal = @"υ"; break;
            case 22: keyVal = @"θ"; break;
            case 23: keyVal = @"ι"; break;
            case 24: keyVal = @"ο"; break;
            case 25: keyVal = @"π"; break;
            case 26: [self handleGkExtra:[greekProcessingKeyboard addCirc]]; break;
            case 27: [self handleGkExtra:[greekProcessingKeyboard addGrave]]; break;
            case 28: [self greekHandleBackspace: true]; break;
                
            case 29: [self greekHandleCapsPress]; break;
            case 30: keyVal = @"α"; break;
            case 31: keyVal = @"σ"; break;
            case 32: keyVal = @"δ"; break;
            case 33: keyVal = @"φ"; break;
            case 34: keyVal = @"γ"; break;
            case 35: keyVal = @"η"; break;
            case 36: keyVal = @"ξ"; break;
            case 37: keyVal = @"κ"; break;
            case 38: keyVal = @"λ"; break;
            case 39: [self handleGkExtra:[greekProcessingKeyboard addRoughBreathing]]; break;
            case 40: [self handleGkExtra:[greekProcessingKeyboard addSmoothBreathing]]; break;
            case 41: [self handleGkExtra:[greekProcessingKeyboard addIotaSub]]; break;
            case 42: keyVal = @"\n"; break;
                
            case 43: [self greekHandleShiftPress]; break;
            case 44: keyVal = @"ζ"; break;
            case 45: keyVal = @"χ"; break;
            case 46: keyVal = @"ψ"; break;
            case 47: keyVal = @"ω"; break;
            case 48: keyVal = @"β"; break;
            case 49: keyVal = @"ν"; break;
            case 50: keyVal = @"μ"; break;
            case 51: keyVal = @"·"; break;
            case 52: keyVal = @";"; break;
            case 53: [self handleGkExtra:[greekProcessingKeyboard addDiaeresis]]; break;
            case 55: [self greekHandleShiftPress]; break;
                //                case 56: [self handleCtrlPress]; break;
                
            case 59: keyVal = @" "; break;
                
            case 62: break; // Do nothing
            default: break;
        }
    }
    else
    {
        switch (tagVal)
        {
            case 2: keyVal = @"1"; break;
            case 3: keyVal = @"2"; break;
            case 4: keyVal = @"3"; break;
            case 5: keyVal = @"4"; break;
            case 6: keyVal = @"5"; break;
            case 7: keyVal = @"6"; break;
            case 8: keyVal = @"7"; break;
            case 9: keyVal = @"8"; break;
            case 10: keyVal = @"9"; break;
            case 11: keyVal = @"0"; break;
            case 12: keyVal = @""; break;
            case 13: keyVal = @""; break;
            case 14: [self greekHandleBackspace: false]; break;
            case 15: enteredText.string = @""; break;
            case 16: [self handleGkExtra:[greekProcessingKeyboard addAccute]]; break;
            case 18: keyVal = @"Ε"; break;
            case 19: keyVal = @"Ρ"; break;
            case 20: keyVal = @"Τ"; break;
            case 21: keyVal = @"Υ"; break;
            case 22: keyVal = @"Θ"; break;
            case 23: keyVal = @"Ι"; break;
            case 24: keyVal = @"Ο"; break;
            case 25: keyVal = @"Π"; break;
            case 26: [self handleGkExtra:[greekProcessingKeyboard addCirc]]; break;
            case 27: [self handleGkExtra:[greekProcessingKeyboard addGrave]]; break;
            case 28: [self greekHandleBackspace: true]; break;
                
            case 29: [self greekHandleCapsPress]; break;
            case 30: keyVal = @"Α"; break;
            case 31: keyVal = @"Σ"; break;
            case 32: keyVal = @"Δ"; break;
            case 33: keyVal = @"Φ"; break;
            case 34: keyVal = @"Γ"; break;
            case 35: keyVal = @"Η"; break;
            case 36: keyVal = @"Ξ"; break;
            case 37: keyVal = @"Κ"; break;
            case 38: keyVal = @"Λ"; break;
            case 39: [self handleGkExtra:[greekProcessingKeyboard addRoughBreathing]]; break;
            case 40: [self handleGkExtra:[greekProcessingKeyboard addSmoothBreathing]]; break;
            case 41: [self handleGkExtra:[greekProcessingKeyboard addIotaSub]]; break;
            case 42: keyVal = @"\n"; break;
                
            case 43: [self greekHandleShiftPress]; break;
            case 44: keyVal = @"Ζ"; break;
            case 45: keyVal = @"Χ"; break;
            case 46: keyVal = @"Ψ"; break;
            case 47: keyVal = @"Ω"; break;
            case 48: keyVal = @"Β"; break;
            case 49: keyVal = @"Ν"; break;
            case 50: keyVal = @"Μ"; break;
            case 51: keyVal = @","; break;
            case 52: keyVal = @"."; break;
            case 53: [self handleGkExtra:[greekProcessingKeyboard addDiaeresis]]; break;
            case 55: [self greekHandleShiftPress]; break;
                //                case 56: handleCtrlPress(); break;
                
            case 59: keyVal = @" "; break;
                
            case 62: break;  // do nothing
            default: break;
        }
    }
    if( isGkMiniscule )
    {
        if ((tagVal >= 17) && (tagVal <= 25)) isChar = true;
        if ((tagVal >= 30) && (tagVal <= 38)) isChar = true;
        if ((tagVal > 44) && (tagVal <= 53)) isChar = true;
        if (tagVal == 42) isChar = true;
        if (tagVal == 59) isChar = true;
    }
    else
    {
        if ((tagVal >= 18) && (tagVal <= 25)) isChar = true;
        if ((tagVal >= 30) && (tagVal <= 38)) isChar = true;
        if ((tagVal >= 44) && (tagVal <= 53)) isChar = true;
        if (tagVal == 42) isChar = true;
        if (tagVal == 59) isChar = true;
    }
    if (isChar)
    {
        if( [enteredText.string length] == 0 )
        {
            enteredText.string = keyVal;
            enteredText.selectedRange = NSMakeRange(1, 0);
        }
        else
        {
            selectedRange = [enteredText selectedRange];
            cursorPstn = selectedRange.location;
            if( doOutput )
            {
                if( cursorPstn == [[enteredText string] length] )
                {
                    enteredText.string = [NSString stringWithFormat:@"%@%@", [enteredText string], keyVal];
                }
                else
                {
                    enteredText.string = [NSString stringWithFormat:@"%@%@%@", [[enteredText string] substringToIndex:cursorPstn], keyVal, [[enteredText string] substringFromIndex:cursorPstn]];
                    enteredText.selectedRange = NSMakeRange(cursorPstn+1, 0);
                }
            }
        }
        if( gkCaseState == 1 ) [self greekHandleShiftPress];
    }
}

-(void) greekHandleBackspace: (bool) isDelete
{
    NSUInteger csrPstn, stringLength;
    NSRange selectedRange;
    NSString *fullText;
    
    selectedRange = [enteredText selectedRange];
    csrPstn = selectedRange.location;
    if (csrPstn == 0) return;
    fullText = [enteredText string];
    
        stringLength = [[enteredText string] length];
        if( csrPstn == stringLength )
        {
            enteredText.string = [[enteredText string] substringToIndex:stringLength - 1];
            
        }
        else
        {
            enteredText.string = [NSString stringWithFormat:@"%@%@", [[enteredText string] substringToIndex:csrPstn - 1], [[enteredText string] substringFromIndex:csrPstn]];
            enteredText.selectedRange = NSMakeRange(--csrPstn, 0);
        }
}

-(void) greekHandleShiftPress
{
    if (gkCaseState == 2) return;
    if( gkCaseState == 0 )
    {
        isGkMiniscule = false;
        gkCaseState = 1;
    }
    else
    {
        isGkMiniscule = true;
        gkCaseState = 0;
    }
    [self gkChangeKeys];
}

-(void) greekHandleCapsPress
{
    if( ( gkCaseState == 0 ) || ( gkCaseState == 1 ) )
    {
        isGkMiniscule = false;
        gkCaseState = 2;
        btnCapsLight.image = [[NSImage alloc] initByReferencingFile:[[NSBundle mainBundle] pathForResource:@"lightOn" ofType:@"png"]];
    }
    else
    {
        isGkMiniscule = true;
        gkCaseState = 0;
        btnCapsLight.image = [[NSImage alloc] initByReferencingFile:[[NSBundle mainBundle] pathForResource:@"lightOff" ofType:@"png"]];
    }
    [self gkChangeKeys];
}


-(void)gkChangeKeys
{
//    const NSInteger colsPerRow = 14;
    
    NSInteger keyRow, keyCol, maxForRow, tagVal;
    NSButton *tempButton;
    
    maxForRow = 0;
    tagVal = 0;
    for (keyRow = 0; keyRow < 5; keyRow++)
    {
        switch (keyRow)
        {
            case 0:
            case 1:
            case 2: maxForRow = 14; break;
            case 3: maxForRow = 13; break;
            case 4: maxForRow = 7; break;
        }
            if (isGkMiniscule)
            {
                for (keyCol = 0; keyCol < maxForRow; keyCol++)
                {
                    tempButton = [gkButtonObjects objectAtIndex:tagVal];
                    [tempButton setTitle:[[gkKeyFaceMin objectAtIndex:keyRow] objectAtIndex:keyCol]];
                    //                theKeys[keyRow, keyCol].Font = new Font("Times New Roman", 14);
                    [tempButton setToolTip:[[gkKeyHintMin objectAtIndex:keyRow] objectAtIndex:keyCol]];
                    tagVal++;
                }
            }
            else
            {
                for (keyCol = 0; keyCol < maxForRow; keyCol++)
                {
                    tempButton = [gkButtonObjects objectAtIndex:tagVal];
                    [tempButton setTitle:[[gkKeyFaceMaj objectAtIndex:keyRow] objectAtIndex:keyCol]];
                    //                theKeys[keyRow, keyCol].Font = new Font("Times New Roman", 14);
                    [tempButton setToolTip:[[gkKeyHintMaj objectAtIndex:keyRow] objectAtIndex:keyCol]];
                    tagVal++;
                }
            }
        }
}

- (void) handleGkExtra: (NSMutableDictionary *) conversionTable
{
    // oxia (accute)
    NSInteger csrPstn;
    NSRange selectedRange, recordedRange;
    NSString *currentLetter, *replacementLetter;
    
    selectedRange = [enteredText selectedRange];
    recordedRange = selectedRange;
    selectedRange.length = 1;
    csrPstn = selectedRange.location - 1;
    selectedRange.location = csrPstn;
    if (csrPstn < 0) return;
    currentLetter = [[enteredText string] substringWithRange:selectedRange];
    replacementLetter = [conversionTable valueForKey:currentLetter];
    if ( replacementLetter != nil )
    {
        if (csrPstn == 0)
        {
            enteredText.string = [NSString stringWithFormat:@"%@%@", replacementLetter, [[enteredText string] substringFromIndex:1]];
        }
        else
        {
            if( csrPstn == [[enteredText string] length] - 1 )
            {
                enteredText.string = [NSString stringWithFormat:@"%@%@", [[enteredText string] substringToIndex:csrPstn], replacementLetter];
            }
            else
            {
                enteredText.string = [NSString stringWithFormat:@"%@%@%@", [[enteredText string] substringToIndex:csrPstn], replacementLetter, [[enteredText string] substringFromIndex:csrPstn + 1]];
            }
        }
    }
    enteredText.selectedRange = recordedRange;
}

- (void) hebrewKeyPressed: (id) sender
{
    const NSInteger colsPerRow = 14;

    bool doOutput = true, isChar = false;
    NSInteger tagVal, rowVal, colVal;
    NSUInteger cursorPstn;
    NSRange selectedRange;
    NSString *keyVal;
    NSButton *currButton;
    
    currButton = (NSButton *)sender;
    tagVal = (int)[currButton tag];
    if( isHebMiniscule )
    {
        switch (tagVal)
            {
                case 1: break;
                case 2: keyVal = @"\u05B1"; break;
                case 3: keyVal = @"\u05B3"; break;
                case 4: keyVal = @"\u05B2"; break;
                case 5: keyVal = @"\u05B6"; break;
                case 6: keyVal = @"\u05BC"; break;
                case 7: keyVal = @"\u05B5"; break;
                case 8: keyVal = @"\u05B4"; break;
                case 9: keyVal = @"\u05B0"; break;
                case 10: keyVal = @"\u05B8"; break;
                case 11: keyVal = @"\u05B7"; break;
                case 12: keyVal = @"\u05BB"; break;
                case 13: keyVal = @"\u05B9"; break;
                case 14: [self hebrewBackspace: false]; break;  // Why false?  This is Backspace
                case 15: enteredText.string = @""; break;
                case 16: keyVal = @"\u05C1"; break;
                case 17: keyVal = @"\u05C2"; break;
                case 18: keyVal = @"\u05E7"; break;
                case 19: keyVal = @"\u05E8"; break;
                case 20: keyVal = @"\u05D0"; break;
                case 21: keyVal = @"\u05D8"; break;
                case 22: keyVal = @"\u05D5"; break;
                case 23: keyVal = @"\u05DF"; break;
                case 24: keyVal = @"\u05DD"; break;
                case 25: keyVal = @"\u05E4"; break;
                case 26: keyVal = @"\u05BE"; break;
                case 27: keyVal = @"\u05ab"; break;
                case 28: [self hebrewBackspace: true]; break;   // This is Del
                    
                case 29: [self hebrewCapsPress]; break;
                case 30: keyVal = @"\u05E9"; break;
                case 31: keyVal = @"\u05D3"; break;
                case 32: keyVal = @"\u05D2"; break;
                case 33: keyVal = @"\u05DB"; break;
                case 34: keyVal = @"\u05E2"; break;
                case 35: keyVal = @"\u05D9"; break;
                case 36: keyVal = @"\u05D7"; break;
                case 37: keyVal = @"\u05DC"; break;
                case 38: keyVal = @"\u05DA"; break;
                case 39: keyVal = @"\u05E3"; break;
                case 42: keyVal = @"\n"; break;
                    
                case 43: [self hebrewShiftPress]; break;
                case 45: keyVal = @"\u05D6"; break;
                case 46: keyVal = @"\u05E1"; break;
                case 47: keyVal = @"\u05D1"; break;
                case 48: keyVal = @"\u05D4"; break;
                case 49: keyVal = @"\u05E0"; break;
                case 50: keyVal = @"\u05DE"; break;
                case 51: keyVal = @"\u05E6"; break;
                case 52: keyVal = @"\u05EA"; break;
                case 53: keyVal = @"\u05E5"; break;
                case 55: [self hebrewShiftPress]; break;
                    
                    //            case 56: handleCtrlPress(); break;
                case 59: keyVal = @" "; break;
                    
                case 62: break; // Do nothing
                default: break;
            }
        }
        else
        {
            if( tagVal == 0 )
            {
                rowVal = 0; colVal = 0;
            }
            else
            {
                rowVal = (tagVal - 1) / colsPerRow; colVal = (tagVal - 1) % colsPerRow;
            }
            keyVal = [[hebAccents objectAtIndex:rowVal] objectAtIndex:colVal];
            switch (tagVal)
            {
                case 1: keyVal = @""; break;
                case 14: [self hebrewBackspace: false]; keyVal = @""; break;
                case 15: enteredText.string = @""; keyVal = @""; break;
                case 28: [self hebrewBackspace: true]; keyVal = @""; break;
                case 29: [self hebrewCapsPress]; keyVal = @""; break;
                case 42: keyVal = @"\n"; break;
                case 43: [self hebrewShiftPress]; keyVal = @""; break;
                case 55: [self hebrewShiftPress]; keyVal = @""; break;
                    //            case 56: handleCtrlPress(); break;
                case 59: keyVal = @" "; break;
                case 62: break; // Do nothing
                default: break;
            }
        }
    if( isHebMiniscule )
    {
        if ((tagVal > 1) && (tagVal <= 13)) isChar = true;
        if ((tagVal >= 16) && (tagVal <= 27)) isChar = true;
        if ((tagVal >= 30) && (tagVal <= 40)) isChar = true;
        if ((tagVal >= 45) && (tagVal <= 53)) isChar = true;
        if (tagVal == 42) isChar = true;
        if (tagVal == 59) isChar = true;
    }
    else
    {
        if ((tagVal > 1) && (tagVal <= 13)) isChar = true;
        if ((tagVal >= 16) && (tagVal <= 27)) isChar = true;
        if ((tagVal >= 30) && (tagVal <= 41)) isChar = true;
        if ((tagVal >= 44) && (tagVal <= 54)) isChar = true;
        if (tagVal == 59) isChar = true;
    }
    if (isChar)
    {
        if( [enteredText.string length] == 0 )
        {
            enteredText.string = keyVal;
            enteredText.selectedRange = NSMakeRange(1, 0);
        }
        else
        {
            selectedRange = [enteredText selectedRange];
            cursorPstn = selectedRange.location;
            if( doOutput )
            {
                if( cursorPstn == [[enteredText string] length] )
                {
                    enteredText.string = [NSString stringWithFormat:@"%@%@", [enteredText string], keyVal];
                }
                else
                {
                    enteredText.string = [NSString stringWithFormat:@"%@%@%@", [[enteredText string] substringToIndex:cursorPstn], keyVal, [[enteredText string] substringFromIndex:cursorPstn]];
                    enteredText.selectedRange = NSMakeRange(cursorPstn+1, 0);
                }
            }
        }
        if( hebCaseState == 1 ) [self hebrewShiftPress];
    }
}

-(void) hebrewBackspace: (bool) isDelete
{
    NSUInteger csrPstn, csrStartPstn;
    unichar characterCode;
    NSRange selectedRange;
    NSString *currChar, *fullText, *firstHalf, *secondHalf;
    
    selectedRange = [enteredText selectedRange];
    csrPstn = selectedRange.location;
    if (csrPstn == 0) return;
    fullText = [enteredText string];
    csrStartPstn = csrPstn;
    // If backspace, then delete *all* the next "letter";
    // If Del, then unicode character by character
    if( isDelete) csrPstn--;
    else
    {
        do
        {
            currChar = [[enteredText string] substringWithRange:NSMakeRange(csrPstn-1, 1)];
            characterCode = [currChar characterAtIndex:0];
            csrPstn--;
        } while ( ( characterCode < 0x05d0 ) && ( characterCode > 255) && ( ! ( ( characterCode == 0x05be ) || ( characterCode == 0x05c0 ) || ( characterCode == 0x05c6 ) )));
    }
    if( csrStartPstn == [fullText length] )
    {
        // We are at the end of the text
        if( csrPstn <= 0 )
        {
            enteredText.string = @"";
        }
        else
        {
            // Simply lose the end of the text
            fullText = [fullText substringToIndex:csrPstn];
            enteredText.string = fullText;
        }
    }
    else
    {
        // We are mid-way into the text
        if( csrPstn <= 0 )
        {
            // Even here, we can just lose the end of the text
            enteredText.string = [[enteredText string] substringFromIndex:csrStartPstn];
            enteredText.selectedRange = NSMakeRange(0, 0);
        }
        else
        {
            // This is the awkward option
            firstHalf = [fullText substringToIndex:csrPstn];
            secondHalf = [fullText substringFromIndex:csrStartPstn];
            enteredText.string = [NSString stringWithFormat:@"%@%@", firstHalf, secondHalf ];
            enteredText.selectedRange = NSMakeRange(csrPstn, 0);
        }
    }
}

-(void) hebrewShiftPress
{
    if (hebCaseState == 2) return;
    if( hebCaseState == 0 )
    {
        isHebMiniscule = false;
        hebCaseState = 1;
    }
    else
    {
        isHebMiniscule = true;
        hebCaseState = 0;
    }
    [self hebChangeKeys];
}

-(void) hebrewCapsPress
{
    if( ( hebCaseState == 0 ) || ( hebCaseState == 1 ) )
    {
        isHebMiniscule = false;
        hebCaseState = 2;
        btnHebCapsLight.image = [[NSImage alloc] initByReferencingFile:[[NSBundle mainBundle] pathForResource:@"lightOn" ofType:@"png"]];
    }
    else
    {
        isHebMiniscule = true;
        hebCaseState = 0;
        btnHebCapsLight.image = [[NSImage alloc] initByReferencingFile:[[NSBundle mainBundle] pathForResource:@"lightOff" ofType:@"png"]];
    }
    [ self hebChangeKeys];
}

-(void) hebChangeKeys
{
    NSInteger keyRow, keyCol, maxForRow, tagVal;
    NSArray *accentControl;
    NSButton *tempButton;
    
    maxForRow = 0;
    tagVal = 0;
    accentControl = [[NSArray alloc] initWithObjects: @0, @1, @1, @1, @1, @1, @1, @1, @1, @1, @1, @1, @1, @0, @0, @1, @1, @1, @1, @1, @1, @1, @1, @1, @1, @1, @1, @0,
                                                      @0, @1, @1, @1, @1, @1, @1, @1, @1, @1, @0, @1, @0, @0, @0, @1, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, nil];
    for (keyRow = 0; keyRow < 5; keyRow++)
    {
        switch (keyRow)
        {
            case 0:
            case 1:
            case 2: maxForRow = 14; break;
            case 3: maxForRow = 13; break;
            case 4: maxForRow = 7; break;
        }
            if (isHebMiniscule)
            {
                for (keyCol = 0; keyCol < maxForRow; keyCol++)
                {
                    tempButton = [hebButtonObjects objectAtIndex:tagVal];
                    [tempButton setTitle:[[hebKeyFace objectAtIndex:keyRow] objectAtIndex:keyCol]];
                    //                theKeys[keyRow, keyCol].Font = new Font("Times New Roman", 14);
                    [tempButton setToolTip:[[hebKeyHint objectAtIndex:keyRow] objectAtIndex:keyCol]];
                    tagVal++;
                }
            }
            else
            {
                maxForRow = 0;
                for (keyRow = 0; keyRow < noOfRows - 1; keyRow++)
                {
                    switch (keyRow)
                    {
                        case 0:
                        case 1:
                        case 2: maxForRow = noOfCols; break;
                        case 3: maxForRow = 13; break;
                            //case 4: maxForRow = 8; break;
                    }
                    for (keyCol = 0; keyCol < maxForRow; keyCol++)
                    {
                        tempButton = [hebButtonObjects objectAtIndex:tagVal];
                        [tempButton setTitle: [[hebAccents objectAtIndex:keyRow] objectAtIndex:keyCol]];
                        [tempButton setToolTip:[[hebAccentHints objectAtIndex:keyRow] objectAtIndex:keyCol]];
                        tagVal++;
                    }
                }
            }
        }
}

- (void) virtualKeyPress: (unichar) keyValue withControl: (bool) isGreek
{
    if (isGreek )
    {
        switch (keyValue)
        {
            case '\n': [self addGkChar:@"\n"]; break;
            case (char)7: [self handleDel:isGreek]; break;
            case '\b': [self handleBackspace:isGreek]; break;
            case '@': enteredText.string = @""; break;  //Esc
            case 'a': [self addGkChar: @"\u03B1"]; break;
            case 'b': [self addGkChar: @"\u03B2"]; break;
            case 'c': [self addGkChar: @"\u03C7"]; break;
            case 'd': [self addGkChar: @"\u03B4"]; break;
            case 'e': [self addGkChar: @"\u03B5"]; break;
            case 'f': [self addGkChar: @"\u03C6"]; break;
            case 'g': [self addGkChar: @"\u03B3"]; break;
                //                    case 'h': [self addGkChar: @"\u03B7"]; break;
                    case 'i': [self addGkChar: @"\u03B9"]; break;
                //                    case 'j': [self addGkChar: @"\u03C9"]; break;
            case 'k': [self addGkChar: @"\u03BA"]; break;
            case 'l': [self addGkChar: @"\u03BB"]; break;
            case 'm': [self addGkChar: @"\u03BC"]; break;
            case 'n': [self addGkChar: @"\u03BD"]; break;
            case 'o': [self addGkChar: @"\u03BF"]; break;
            case 'p': [self addGkChar: @"\u03C0"]; break;
                //                    case 'q': [self addGkChar: @"\u03B8"]; break;
            case 'r': [self addGkChar: @"\u03C1"]; break;
            case 's': [self addGkChar: @"\u03C3"]; break;
            case 't': [self addGkChar: @"\u03C4"]; break;
            case 'u': [self addGkChar: @"\u03C5"]; break;
            case 'w': [self addGkChar: @"\u03DD"]; break;
            case 'x': [self addGkChar: @"\u03BE"]; break;
                //                    case 'y': [self addGkChar: @"\u03C8"]; break;
            case 'z': [self addGkChar: @"\u03B6"]; break;
            case 'A': [self addGkChar: @"\u0391"]; break;
            case 'B': [self addGkChar: @"\u0392"]; break;
            case 'C': [self addGkChar: @"\u03A7"]; break;
            case 'D': [self addGkChar: @"\u0394"]; break;
            case 'E': [self addGkChar: @"\u0395"]; break;
            case 'F': [self addGkChar: @"\u03A6"]; break;
            case 'G': [self addGkChar: @"\u0393"]; break;
                //                    case 'H': [self addGkChar: @"\u0397"]; break;
                    case 'I': [self addGkChar: @"\u0399"]; break;
                //                    case 'J': [self addGkChar: @"\u03A9"]; break;
            case 'K': [self addGkChar: @"\u039A"]; break;
            case 'L': [self addGkChar: @"\u039B"]; break;
            case 'M': [self addGkChar: @"\u039C"]; break;
            case 'N': [self addGkChar: @"\u039D"]; break;
            case 'O': [self addGkChar: @"\u039F"]; break;
            case 'P': [self addGkChar: @"\u03A0"]; break;
                //                    case 'Q': [self addGkChar: @"\u0398"]; break;
            case 'R': [self addGkChar: @"\u03A1"]; break;
            case 'S': [self addGkChar: @"\u03A3"]; break;
            case 'T': [self addGkChar: @"\u03A4"]; break;
            case 'U': [self addGkChar: @"\u03A5"]; break;
            case 'W': [self addGkChar: @"\u03DC"]; break;
            case 'X': [self addGkChar: @"\u039E"]; break;
                //                    case 'Y': [self addGkChar: @"\u03A8"]; break;
            case 'Z': [self addGkChar: @"\u0396"]; break;
                //                    case '@': [self addGkChar: @"\u03C2"]; break;
            case ',': [self addGkChar: @"\u0387"]; break;
            case '?': [self addGkChar: @"\u037E"]; break;
            case ')': [self addGkChar: @")"]; break;
            case '(': [self addGkChar: @"("]; break;
            case '/': [self addGkChar: @"/"]; break;
            case '\\': [self addGkChar: @"\\"]; break;
            case '~': [self addGkChar: @"~"]; break;
            case '\'': [self addGkChar: @"'"]; break;
            case ':': [self addGkChar: @":"]; break;
            case ' ': [self addGkChar: @" "]; break;
            case '.': [self addGkChar: @"."]; break;
            case 0x03B7: [self addGkChar: @"\u03B7"]; break;
            case 0x03C9: [self addGkChar: @"\u03C9"]; break;
            case 0x03C8: [self addGkChar: @"\u03C8"]; break;
            case 0x03C2: [self addGkChar: @"\u03C2"]; break;
            case 0x03B8: [self addGkChar: @"\u03B8"]; break;
            case 0x0397: [self addGkChar: @"\u0397"]; break;
            case 0x03A9: [self addGkChar: @"\u03A9"]; break;
            case 0x03A8: [self addGkChar: @"\u03A8"]; break;
            case 0x0398: [self addGkChar: @"\u0398"]; break;
            case 128: [self goFullLeft:nil]; break;  // fn + left arrow = start of line
            case 129: [self goFullUp:nil]; break;  // fn + up arrow = start of input
            case 130: [self goFullRight: nil]; break;  // fn + right arrow = end of line
            case 131: [self goFullDown: nil]; break;  // fn + down arrow = end of input
            case 132: [self goUp: nil]; break;  // up arrow
            case 133: [self goDown: nil]; break;  // down arrow
            case 134: [self goRight: nil]; break;  // right arrow
            case 135: [self goLeft: nil]; break;  // left arrow
        }
    }
    else
    {
        switch (keyValue)
        {
            case '\n': [self addHebConsonant:@"\n"]; break;
            case (char)7: [self handleDel:isGreek]; break;
            case '@': enteredText.string = @""; break;  //Esc
            case '\b': [self handleBackspace:isGreek]; break;
            case 'A': [self  addHebVowel: @"\u05B8"]; break;
            case 'C': [self  addHebConsonant: @"\u05E5"]; break;
            case 'E': [self  addHebVowel: @"\u05B5"]; break;
            case 'H': [self  addHebConsonant: @"\u05D7"]; break;
            case 'K': [self  addHebConsonant: @"\u05DA"]; break;
            case 'M': [self  addHebConsonant: @"\u05DD"]; break;
            case 'N': [self  addHebConsonant: @"\u05DF"]; break;
            case 'P': [self  addHebConsonant: @"\u05E3"]; break;
            case 'S': [self  addHebConsonant: @"\u05E9"]; break;
            case 'T': [self  addHebConsonant: @"\u05EA"]; break;
            case 'Y': [self  addHebConsonant: @"\u05E2"]; break;
            case 'a': [self  addHebVowel: @"\u05B7"]; break;
            case 'b': [self  addHebConsonant: @"\u05D1"]; break;
            case 'c': [self  addHebConsonant: @"\u05E6"]; break;
            case 'd': [self  addHebConsonant: @"\u05D3"]; break;
            case 'e': [self  addHebVowel: @"\u05B6"]; break; //
            case 'g': [self  addHebConsonant: @"\u05D2"]; break;
            case 'h': [self  addHebConsonant: @"\u05D4"]; break;
            case 'i': [self  addHebVowel: @"\u05B4"]; break; //
            case 'k': [self  addHebConsonant: @"\u05DB"]; break;
            case 'l': [self  addHebConsonant: @"\u05DC"]; break;
            case 'm': [self  addHebConsonant: @"\u05DE"]; break;
            case 'n': [self  addHebConsonant: @"\u05E0"]; break;
            case 'o': [self  addHebVowel: @"\u05B9"]; break; //
            case 'p': [self  addHebConsonant: @"\u05E4"]; break;
            case 'q': [self  addHebConsonant: @"\u05E7"]; break;
            case 'r': [self  addHebConsonant: @"\u05E8"]; break;
            case 's': [self  addHebConsonant: @"\u05E1"]; break;
            case 't': [self  addHebConsonant: @"\u05D8"]; break;
            case 'u': [self  addHebVowel: @"\u05BB"]; break; //
            case 'v': [self  addHebConsonant: @"\u05D5"]; break;
            case 'x': [self  addHebConsonant: @"\u05D0"]; break;
            case 'y': [self  addHebConsonant: @"\u05D9"]; break;
            case 'z': [self  addHebConsonant: @"\u05D6"]; break;
            case '\'': [self  addHebVowel: @"\u05B0"]; break;
            case '<': [self  addHebVowel: @"\u05C2"]; break;
            case '>': [self  addHebVowel: @"\u05C1"]; break;
            case '-': [self  addHebVowel: @"\u05BE"]; break;
            case '^': [self  addHebVowel: @"\u05AB"]; break;
            case '.': [self  addHebVowel: @"\u05BC"]; break;
            case ':': [self  addHebVowel: @"\u05C3"]; break;
            case ' ': [self  addHebConsonant: @" "]; break;
            case '0': [self  addHebVowel: @"\u0591"]; break;
            case '1': [self  addHebVowel: @"\u0592"]; break;
            case '2': [self  addHebVowel: @"\u0593"]; break;
            case '3': [self  addHebVowel: @"\u0594"]; break;
            case '4': [self  addHebVowel: @"\u0595"]; break;
            case '5': [self  addHebVowel: @"\u0596"]; break;
            case '6': [self  addHebVowel: @"\u0597"]; break;
            case '7': [self  addHebVowel: @"\u0598"]; break;
            case '8': [self  addHebVowel: @"\u0599"]; break;
            case '9': [self  addHebVowel: @"\u059A"]; break;
            case  0x059B: [self addHebVowel: @"\u059B"]; break;
            case  0x059C: [self addHebVowel: @"\u059C"]; break;
            case  0x059D: [self addHebVowel: @"\u059D"]; break;
            case  0x059E: [self addHebVowel: @"\u059E"]; break;
            case  0x059F: [self addHebVowel: @"\u059F"]; break;
            case  0x05A0: [self addHebVowel: @"\u05A0"]; break;
            case  0x05A1: [self addHebVowel: @"\u05A1"]; break;
            case  0x05A2: [self addHebVowel: @"\u05A2"]; break;
            case  0x05A3: [self addHebVowel: @"\u05A3"]; break;
            case  0x05A4: [self addHebVowel: @"\u05A4"]; break;
            case  0x05A5: [self addHebVowel: @"\u05A5"]; break;
            case  0x05A6: [self addHebVowel: @"\u05A6"]; break;
            case  0x05A7: [self addHebVowel: @"\u05A7"]; break;
            case  0x05A8: [self addHebVowel: @"\u05A8"]; break;
            case  0x05A9: [self addHebVowel: @"\u05A9"]; break;
            case  0x05AA: [self addHebVowel: @"\u05AA"]; break;
            case  0x05AB: [self addHebVowel: @"\u05AB"]; break;
            case  0x05AC: [self addHebVowel: @"\u05AC"]; break;
            case  0x05AD: [self addHebVowel: @"\u05AD"]; break;
            case  0x05AE: [self addHebVowel: @"\u05AE"]; break;
            case  0x05AF: [self addHebVowel: @"\u05AF"]; break;
            case  0x05BD: [self addHebVowel: @"\u05BD"]; break;
            case  0x05BF: [self addHebVowel: @"\u05BF"]; break;
            case  0x05C0: [self addHebVowel: @"\u05C0"]; break;
            case  0x05C5: [self addHebVowel: @"\u05C5"]; break;
            case  0x05C6: [self addHebVowel: @"\u05C6"]; break;
            case  0x05C7: [self addHebVowel: @"\u05C7"]; break;
            case  0x05F0: [self addHebVowel: @"\u05F0"]; break;
            case  0x05F1: [self addHebVowel: @"\u05F1"]; break;
            case  0x05F2: [self addHebVowel: @"\u05F2"]; break;
            case  0x05F3: [self addHebVowel: @"\u05F3"]; break;
            case  0x05F4: [self addHebVowel: @"\u05F4"]; break;
            case 128: [self goFullLeft:nil]; break;  // fn + left arrow = start of line
            case 129: [self goFullUp:nil]; break;  // fn + up arrow = start of input
            case 130: [self goFullRight: nil]; break;  // fn + right arrow = end of line
            case 131: [self goFullDown: nil]; break;  // fn + down arrow = end of input
            case 132: [self goUp: nil]; break;  // up arrow
            case 133: [self goDown: nil]; break;  // down arrow
            case 134: [self goRight: nil]; break;  // right arrow
            case 135: [self goLeft: nil]; break;  // left arrow
            default: break;
        }
    }
}

- (void) addGkChar: (NSString *) inputCharacter
{
    NSInteger textPosition;
    NSString *newCharacter, *leftOfWord, *rightOfWord;
    NSArray *nonAlpha1 = @[ @"/", @"~", @"\\", @")", @"(", @"'", @",", @"?", @":", @"\u0387", @"\u037E", @" ", @"." ];
    NSArray *nonAlpha2 = @[ @"/", @"~", @"\\", @")", @"(", @"'", @":" ];
//    SortedList<int, String> previousCharacter = new SortedList<int, string>();
    
    newCharacter = inputCharacter;
    if ( [[enteredText string] length] == 0)
    {
        if ( [nonAlpha1 containsObject:newCharacter] ) return;
        enteredText.string = newCharacter;
        enteredText.selectedRange = NSMakeRange(1, 0);
    }
    else
    {
        textPosition = [enteredText selectedRange].location;
        if (textPosition == 0)
        {
            if ( [nonAlpha1 containsObject:newCharacter] ) return;
            enteredText.string = [[NSString alloc] initWithFormat:@"%@%@", newCharacter, [enteredText string]];
            enteredText.selectedRange = NSMakeRange(1, 0);
        }
        else
        {
            if (textPosition == [[enteredText string] length] )
            {
                if ( [nonAlpha2 containsObject:newCharacter]) enteredText.string = [self modifyFinalChar: [enteredText string] byCharacter:newCharacter];
                else enteredText.string = [[NSString alloc] initWithFormat:@"%@%@", [enteredText string], newCharacter];
                enteredText.selectedRange = NSMakeRange([[enteredText string] length], 0);
            }
            else
            {
                leftOfWord = [[enteredText string] substringToIndex:textPosition];
                rightOfWord = [[enteredText string] substringFromIndex:textPosition];
                if ( [nonAlpha2 containsObject:newCharacter] )
                {
                    leftOfWord = [self modifyFinalChar:leftOfWord byCharacter:newCharacter];
                    enteredText.string = [[NSString alloc] initWithFormat:@"%@%@", leftOfWord, rightOfWord];
                }
                else enteredText.string = [[NSString alloc] initWithFormat:@"%@%@%@", leftOfWord, newCharacter, rightOfWord];
                enteredText.selectedRange = NSMakeRange([leftOfWord length], 0);
            }
        }
    }
}

- (void) handleBackspace: (bool) isGreek
{
    NSInteger csrPstn;
    unichar hebChar;
    NSString *leftPart, *rightPart;
    
    csrPstn = [enteredText selectedRange].location;
    if (csrPstn == 0) return;
    {
        if (isGreek)
        {
            if (csrPstn == [[enteredText string] length] )
            {
                enteredText.string = [[enteredText string] substringToIndex:[[enteredText string] length] - 1];
            }
            else
            {
                leftPart = [[NSString alloc] initWithString:[[enteredText string] substringToIndex:csrPstn - 1]];
                rightPart = [[NSString alloc] initWithString:[[enteredText string] substringFromIndex:csrPstn]];
                enteredText.string = [[NSString alloc] initWithFormat:@"%@%@", leftPart, rightPart];
            }
            enteredText.selectedRange = NSMakeRange(csrPstn - 1, 0);
        }
        else
        {
            hebChar = [[enteredText string] characterAtIndex:csrPstn - 1];
            if (csrPstn == [[enteredText string] length] )
            {
                enteredText.string = [[enteredText string] substringToIndex:[[enteredText string] length] - 1];
            }
            else
            {
                leftPart = [[NSString alloc] initWithString:[[enteredText string] substringToIndex:csrPstn - 1]];
                rightPart = [[NSString alloc] initWithString:[[enteredText string] substringFromIndex:csrPstn]];
                enteredText.string = [[NSString alloc] initWithFormat:@"%@%@", leftPart, rightPart];
            }
            csrPstn--;
            enteredText.selectedRange = NSMakeRange(csrPstn, 0);
        }
    }
}

- (void) handleDel: (bool) isGreek
{
    NSInteger csrPstn;
    unichar hebChar;
    NSString *leftPart, *rightPart;
    
    csrPstn = [enteredText selectedRange].location;
    if (csrPstn == [[enteredText string] length] ) return;
    if (isGreek)
    {
        if (csrPstn == 0)
        {
            enteredText.string = [[enteredText string] substringFromIndex:1];
        }
        else
        {
            leftPart = [[enteredText string] substringToIndex:csrPstn];
            rightPart = [[enteredText string] substringFromIndex:csrPstn + 1];
            enteredText.string = [[NSString alloc] initWithFormat:@"%@%@", leftPart, rightPart];
        }
        enteredText.selectedRange = NSMakeRange(csrPstn, 0);
    }
    else
    {
        do
        {
            hebChar = [[enteredText string] characterAtIndex:csrPstn];
            if (csrPstn == 0)
            {
                enteredText.string = [[enteredText string] substringFromIndex:1];
            }
            else
            {
                leftPart = [[enteredText string] substringToIndex:csrPstn];
                rightPart = [[enteredText string] substringFromIndex:csrPstn + 1];
                enteredText.string =  [[NSString alloc] initWithFormat:@"%@%@", leftPart, rightPart];
            }
            
        } while ((csrPstn > 0) && ((hebChar < 0x05D0) || (hebChar > 0x05EA)));
        enteredText.selectedRange = NSMakeRange(csrPstn, 0);
    }
}

-(void) goFullLeft:(id)sender
{
    NSString *wholeText;
    NSRange selectedRange, newRange;
    NSUInteger noOfLines, index, stringLength;
    
    selectedRange = [enteredText selectedRange];
    wholeText = [enteredText string];
    stringLength = [wholeText length];
    for( noOfLines = 0, index = 0; index < stringLength; noOfLines++ )
    {
        newRange = [wholeText lineRangeForRange:NSMakeRange(index, 0)];
        index = NSMaxRange([wholeText lineRangeForRange:NSMakeRange(index, 0)]);
        if( selectedRange.location <= index )
        {
            // This is our line
            newRange.length = 0;
            enteredText.selectedRange = newRange;
            break;
        }
    }
}

-(void) goLeft:(id)sender
{
    NSRange selectedRange;
    
    selectedRange = [enteredText selectedRange];
    if( selectedRange.location > 0 )
    {
        selectedRange.location--;
        enteredText.selectedRange = selectedRange;
    }
}

-(void) goRight:(id)sender
{
    NSInteger csrPstn;
    NSRange selectedRange;
    NSUInteger stringLength;
    
    stringLength = [[enteredText string] length];
    selectedRange = [enteredText selectedRange];
    csrPstn = selectedRange.location;
    if( csrPstn < stringLength )
    {
        selectedRange.location++;
        enteredText.selectedRange = selectedRange;
    }
}

-(void) goFullRight:(id)sender
{
    NSString *wholeText;
    NSRange selectedRange, newRange;
    NSUInteger noOfLines, index, stringLength;
    
    selectedRange = [enteredText selectedRange];
    wholeText = [enteredText string];
    stringLength = [wholeText length];
    for( noOfLines = 0, index = 0; index < stringLength; noOfLines++ )
    {
        newRange = [wholeText lineRangeForRange:NSMakeRange(index, 0)];
        index = NSMaxRange([wholeText lineRangeForRange:NSMakeRange(index, 0)]);
        if( selectedRange.location < index )
        {
            // This is our line
            newRange.location = index;
            newRange.length = 0;
            enteredText.selectedRange = newRange;
            break;
        }
    }
}

-(void) goFullUp:(id)sender
{
    enteredText.selectedRange = NSMakeRange(0, 0);
}

-(void) goUp:(id)sender
{
    NSString *wholeText;
    NSRange selectedRange, newRange;
    NSUInteger noOfLines, index, stringLength, newPstn, prevLocation = 0, currCsrPstn;
    
    selectedRange = [enteredText selectedRange];
    wholeText = [enteredText string];
    stringLength = [wholeText length];
    currCsrPstn = selectedRange.location;
    if( currCsrPstn >= [wholeText length] )
    {
        for( noOfLines = 0, index = 0; index < stringLength; noOfLines++ )
        {
            if( noOfLines > 0 ) prevLocation = newRange.location;
            newRange = [wholeText lineRangeForRange:NSMakeRange(index, 0)];
            index = NSMaxRange([wholeText lineRangeForRange:NSMakeRange(index, 0)]);
        }
        if( selectedRange.location <= index )
        {
            // This is our line
            if( newRange.location > 0 )
            {
                newPstn = currCsrPstn - newRange.location;
                newRange.location = prevLocation + newPstn;
                newRange.length = 0;
                enteredText.selectedRange = newRange;
            }
        }
    }
    else
    {
        for( noOfLines = 0, index = 0; index < stringLength; noOfLines++ )
        {
            newRange = [wholeText lineRangeForRange:NSMakeRange(index, 0)];
            index = NSMaxRange([wholeText lineRangeForRange:NSMakeRange(index, 0)]);
            if( selectedRange.location < index )
            {
                // This is our line
                if( newRange.location == 0 ) break;
                newPstn = currCsrPstn - newRange.location;
                newRange.location = prevLocation + newPstn;
                newRange.length = 0;
                enteredText.selectedRange = newRange;
                break;
            }
            prevLocation = newRange.location;
        }
    }
}

-(void) goDown:(id)sender
{
    NSString *wholeText;
    NSRange selectedRange, newRange;
    NSUInteger noOfLines, index, stringLength, newPstn, currCsrPstn;
    NSNumber *prevNumber = 0;
    NSMutableArray *firstPsitions;
    
    selectedRange = [enteredText selectedRange];
    wholeText = [enteredText string];
    stringLength = [wholeText length];
    currCsrPstn = selectedRange.location;
    firstPsitions = [[NSMutableArray alloc] init];
    
    for( noOfLines = 0, index = 0; index < stringLength; noOfLines++ )
    {
        [firstPsitions addObject:[NSNumber numberWithUnsignedInteger:index]];
        newRange = [wholeText lineRangeForRange:NSMakeRange(index, 0)];
        index = NSMaxRange([wholeText lineRangeForRange:NSMakeRange(index, 0)]);
    }
    for( NSNumber *startPstn in firstPsitions )
    {
        if( currCsrPstn < [startPstn integerValue] )
        {
            // This is the *next* line, so find how many chars cursor is into prev line
            newPstn = currCsrPstn - [prevNumber integerValue];
            // Now add this to the next line
            newRange.location = [startPstn integerValue] + newPstn;
            newRange.length = 0;
            enteredText.selectedRange = newRange;
            break;
            
        }
        prevNumber = startPstn;
    }
}

-(void) goFullDown:(id)sender
{
    enteredText.selectedRange = NSMakeRange([enteredText string].length, 0);
}

- (void) addHebConsonant: (NSString *) newConsonant
{
    NSInteger textPosition;
    NSString *newCharacter, *leftOfWord, *rightOfWord;
//    SortedList<int, String> previousCharacter = new SortedList<int, string>();
    
    newCharacter = newConsonant;
    if ( [[enteredText string] length] == 0 )
    {
        enteredText.string = newCharacter;
        enteredText.selectedRange = NSMakeRange(1, 0);
    }
    else
    {
        textPosition = [enteredText selectedRange].location;
        if (textPosition == 0)
        {
            enteredText.string = [[NSString alloc] initWithFormat:@"%@%@", newCharacter, [enteredText string]];
            enteredText.selectedRange = NSMakeRange(1, 0);
        }
        else
        {
            if (textPosition == [[enteredText string] length] )
            {
                enteredText.string = [[NSString alloc] initWithFormat:@"%@%@", [enteredText string], newCharacter];
                enteredText.selectedRange = NSMakeRange([[enteredText string] length] - 1, 0);
            }
            else
            {
                leftOfWord = [[NSString alloc] initWithString:[[enteredText string] substringToIndex:textPosition]];
                rightOfWord = [[NSString alloc] initWithString:[[enteredText string] substringFromIndex:textPosition]];
                enteredText.string = [[NSString alloc] initWithFormat:@"%@%@%@", leftOfWord, newCharacter, rightOfWord];
                enteredText.selectedRange = NSMakeRange( [leftOfWord length], 0);
            }
        }
    }
    enteredText.selectedRange = NSMakeRange( [enteredText selectedRange].location + 1, 0);
}

- (void) addHebVowel: (NSString *) newVowel
{
    /***********************************************************************************
     *                                                                                 *
     *                                   addHebVowel                                   *
     *                                   ===========                                   *
     *                                                                                 *
     *  We will *not* protect the user from silly input.                               *
     *                                                                                 *
     *  Hataf vowels will be created from the corresponding full vowel followed        *
     *    *immediately* by a sheva.                                                    *
     *                                                                                 *
     ***********************************************************************************/
    
    NSInteger textPosition;
    NSString *newCharacter, *prevCharacter, *leftOfWord, *rightOfWord;
//    SortedList<int, String> previousCharacter = new SortedList<int, string>();
    
    newCharacter = newVowel;
    if ( [[enteredText string] length ] == 0 ) return;  // A vowel doesn't make sense here
    textPosition = [enteredText selectedRange].location;
    if (textPosition == 0) return;  // A vowel doesn't make sense here, either
    if (textPosition == [[enteredText string] length ] )
    {
        if ( [newVowel characterAtIndex:0] == 0x05b0)
        {
            prevCharacter = [[enteredText string] substringFromIndex:(textPosition - 1)];
            switch ( [prevCharacter characterAtIndex:0] )
            {
                case 0x05B6: enteredText.string = [[NSString alloc] initWithString:[self replaceFinalChar: [enteredText string] withNewChar:@"\u05B1"]]; break;
                case 0x05B7: enteredText.string = [[NSString alloc] initWithString:[self replaceFinalChar: [enteredText string] withNewChar:@"\u05B2"]]; break;
                case 0x05B8: enteredText.string = [[NSString alloc] initWithString:[self replaceFinalChar: [enteredText string] withNewChar:@"\u05B3"]]; break;
                default: enteredText.string = [[NSString alloc] initWithFormat:@"%@%@", [enteredText string], newCharacter]; break;
            }
            
        }
        else enteredText.string = [[NSString alloc] initWithFormat:@"%@%@", [enteredText string], newVowel];
        enteredText.selectedRange = NSMakeRange([[enteredText string] length], 0);
    }
    else
    {
        leftOfWord = [[NSString alloc] initWithString:[[enteredText string] substringToIndex:textPosition]];
        rightOfWord = [[NSString alloc] initWithString:[[enteredText string] substringFromIndex:textPosition]];
        if ( [newVowel characterAtIndex:0] == 0x05b0 )
        {
            prevCharacter = [[NSString alloc] initWithString:[leftOfWord substringToIndex:textPosition - 1]];
            switch ( [prevCharacter characterAtIndex:0] )
            {
                case 0x05B6: enteredText.string = [[NSString alloc] initWithFormat:@"%@%@", [self replaceFinalChar: leftOfWord withNewChar: @"\u05B1"], rightOfWord]; break;
                case 0x05B7: enteredText.string = [[NSString alloc] initWithFormat:@"%@%@", [self replaceFinalChar: leftOfWord withNewChar: @"\u05B2"], rightOfWord]; break;
                case 0x05B8: enteredText.string = [[NSString alloc] initWithFormat:@"%@%@", [self replaceFinalChar: leftOfWord withNewChar: @"\u05B3"], rightOfWord]; break;
                default: enteredText.string = [[NSString alloc] initWithFormat:@"%@%@%@", leftOfWord, newCharacter, rightOfWord]; break;
            }
        }
        else enteredText.string = [[NSString alloc] initWithFormat:@"%@%@%@", leftOfWord, newVowel, rightOfWord];
        enteredText.selectedRange = NSMakeRange( [leftOfWord length], 0);
    }
}

- (NSString *) replaceFinalChar: (NSString *) targetString withNewChar: (NSString *) newChar
{
    NSString *newString;
    
    newString = [targetString substringToIndex:[targetString length] - 1];
    return newString;
}

- (NSString *) modifyFinalChar: (NSString *) targetString byCharacter: (NSString *) modifyingChar
{
    NSString *charToBeModified, *modifiedChar;
    
    charToBeModified = [[NSString alloc] initWithString:[targetString substringFromIndex:[targetString length] - 1]];
    switch( [modifyingChar characterAtIndex:0] )
    {
        case ')': modifiedChar = [greekProcessingKeyboard processSmoothBreathing:charToBeModified]; break;
        case '(': modifiedChar = [greekProcessingKeyboard processRoughBreathing:charToBeModified]; break;
        case '/': modifiedChar = [greekProcessingKeyboard processAccute:charToBeModified]; break;
        case '\\': modifiedChar = [greekProcessingKeyboard processGrave:charToBeModified]; break;
        case '~': modifiedChar = [greekProcessingKeyboard processCirc:charToBeModified]; break;
        case ':': modifiedChar = [greekProcessingKeyboard processDiaeresis:charToBeModified]; break;
        case '\'': modifiedChar = [greekProcessingKeyboard processIotaSub:charToBeModified]; break;
        default: modifiedChar = modifyingChar; break;
    }
    return [[NSString alloc] initWithFormat:@"%@%@", [targetString substringToIndex:[targetString length] - 1], modifiedChar];
}

@end
