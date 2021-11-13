//
//  AppDelegate.m
//  GkHebKeyboard
//
//  Created by Leonard Clark on 12/12/2020.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@property (strong) IBOutlet NSWindow *window;
@end

@implementation AppDelegate

@synthesize mainWindow;
@synthesize pnlGkKeyboard;
@synthesize pnlHebKeyboard;
@synthesize enteredText;
@synthesize btnCapsLight;
@synthesize btnHebCapsLight;
@synthesize greekHebrewTabs;
@synthesize greekTab;
@synthesize hebrewTab;
@synthesize greekOptionTabs;
@synthesize greekKBrdTab;
@synthesize greekPhysTab;
@synthesize hebrewOptionTabs;
@synthesize hebrewKBrdTab;
@synthesize hebrewPhysTab;
@synthesize keyDetails;
@synthesize keyboard;
@synthesize isGreek;
@synthesize fullUpBtn;
@synthesize upBtn;
@synthesize fullLeftBtn;
@synthesize leftBtn;
@synthesize fullRightBtn;
@synthesize rightBtn;
@synthesize fullDownBtn;
@synthesize downBtn;
@synthesize lastSavedDocument;

/*----------------------------------------------------^
 *                                                    *
 *  Global Variables                                  *
 *                                                    *
 *----------------------------------------------------*/

bool isGreekVirtual = true, isHebrewVirtual = true;
classGlobal *globalVars;
// classKeyboard *keyboard;
classGreek *greekProcessing;

NSString *basePath;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    NSString *homeDirectory;
    NSFileManager *fmInit;

    globalVars = [classGlobal new];
    greekProcessing = [classGreek new];
    [greekProcessing initialProcessing];
    globalVars.greekProcessing = greekProcessing;
    keyboard = [classKeyboard new];
    fmInit = [NSFileManager defaultManager];
    homeDirectory = [[NSString alloc] initWithString:[[fmInit homeDirectoryForCurrentUser] path]];
    basePath = [[NSString alloc] initWithFormat:@"%@/LFCConsulting/Keyboard", homeDirectory];
    globalVars.basePath = basePath;
    keyboard.globalVarsKeyboard = globalVars;
    keyboard.mainWindow = mainWindow;
    keyboard.pnlGkKeyboard = pnlGkKeyboard;
    keyboard.pnlHebKeyboard = pnlHebKeyboard;
    keyboard.enteredText = enteredText;
    keyboard.btnCapsLight = btnCapsLight;
    keyboard.btnHebCapsLight = btnHebCapsLight;
    keyboard.greekHebrewTabView = greekHebrewTabs;
    globalVars.mainEnteredText = enteredText;
    isGreek = true;
    [self processStoredValues];
    [enteredText setFont:[NSFont fontWithName:@"Times New Roman" size:[globalVars fontSize]]];
    [keyboard initialiseKeyboard];
    lastSavedDocument = @"";
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
    BOOL isDirectory = true;
    NSString *iniFileName = @"gkHebKeyboard.ini", *fullFileName, *fileContents, *localBase;
    NSFileManager *fmInit;
    NSError *error;
    
    fmInit = [NSFileManager defaultManager];
    localBase = [[NSString alloc] initWithString:[globalVars basePath]];
    fileContents = [[NSString alloc] initWithFormat:@"Opening Language=%li\nFont Size=%li", [globalVars openingLanguage], [globalVars fontSize]];
    if( ! [fmInit fileExistsAtPath:localBase isDirectory:&isDirectory] )
        [fmInit createDirectoryAtPath:localBase withIntermediateDirectories:YES attributes:nil error:&error];
    fullFileName = [[NSString alloc] initWithFormat:@"%@/%@", localBase, iniFileName];
    [fileContents writeToFile:fullFileName atomically:YES encoding:NSUTF8StringEncoding error:&error];
}

- (void) processStoredValues
{
    BOOL isDir = true;
    NSString *iniFileName = @"gkHebKeyboard.ini", *fullFileName, *fileContents;
    NSArray *fileLines, *iniComponents;
    NSFileManager *fmInit;
    
    fmInit = [NSFileManager defaultManager];
    if( ! [fmInit fileExistsAtPath:[globalVars basePath] isDirectory:&isDir])
    {
        [fmInit createDirectoryAtPath:[globalVars basePath] withIntermediateDirectories:YES attributes:nil error:nil];
    }
    fullFileName = [[NSString alloc] initWithFormat:@"%@/%@", [globalVars basePath], iniFileName];
    globalVars.openingLanguage = 1;
    globalVars.fontSize = 40;
    if( [fmInit fileExistsAtPath:fullFileName])
    {
        fileContents = [[NSString alloc] initWithContentsOfFile:fullFileName encoding:NSUTF8StringEncoding error:nil];
        fileLines = [[NSArray alloc] initWithArray:[fileContents componentsSeparatedByString:@"\n"]];
        for( NSString *fileLine in fileLines)
        {
            iniComponents = [[NSArray alloc] initWithArray:[fileLine componentsSeparatedByString:@"="]];
            if( [iniComponents count] < 2 ) continue;
            if( [[iniComponents objectAtIndex:0] isEqualToString:@"Opening Language"] )
            {
                if( [[iniComponents objectAtIndex:1] isEqualToString:@"1"] ) globalVars.openingLanguage = 1;
                else globalVars.openingLanguage = 2;
            }
            if( [globalVars openingLanguage] == 1) [greekHebrewTabs selectTabViewItem:greekTab];
            else [greekHebrewTabs selectTabViewItem:hebrewTab];
            if( [[iniComponents objectAtIndex:0] isEqualToString:@"Font Size"] )
            {
                globalVars.fontSize = [[iniComponents objectAtIndex:1] integerValue];
            }
        }
    }
    [enteredText setFont:[NSFont fontWithName:@"Times New Roman" size:[globalVars fontSize]]];
}

-(IBAction)goFullLeft:(id)sender
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

-(IBAction)goLeft:(id)sender
{
    NSRange selectedRange;
    
    selectedRange = [enteredText selectedRange];
    if( selectedRange.location > 0 )
    {
        selectedRange.location--;
        enteredText.selectedRange = selectedRange;
    }
}

- (void) tabView:(NSTabView *)tabView didSelectTabViewItem:(NSTabViewItem *)tabViewItem
{
    if( tabViewItem == greekTab)
    {
        isGreek = true;
        if( isGreekVirtual )[self resetSpecialKeys:true];
        else [self resetSpecialKeys:false];
    }
    if( tabViewItem == hebrewTab)
    {
        isGreek = false;
        if( isHebrewVirtual )[self resetSpecialKeys:true];
        else [self resetSpecialKeys:false];
    }
    if( tabViewItem == greekKBrdTab)
    {
        [self resetSpecialKeys:true];
        isGreekVirtual = true;
    }
    if( tabViewItem == greekPhysTab)
    {
        [self resetSpecialKeys:false];
        isGreekVirtual = false;
    }
    if( tabViewItem == hebrewKBrdTab)
    {
        [self resetSpecialKeys:true];
        isHebrewVirtual = true;
    }
    if( tabViewItem == hebrewPhysTab)
    {
        [self resetSpecialKeys:false];
        isHebrewVirtual = false;
    }
}

- (void) resetSpecialKeys: (BOOL) isVisible
{
    if( isVisible)
    {
        [fullDownBtn setHidden:NO];
        [downBtn setHidden:NO];
        [fullLeftBtn setHidden:NO];
        [leftBtn setHidden:NO];
        [fullRightBtn setHidden:NO];
        [rightBtn setHidden:NO];
        [fullUpBtn setHidden:NO];
        [upBtn setHidden:NO];
        [keyDetails setHidden:YES];
    }
    else
    {
        [fullDownBtn setHidden:YES];
        [downBtn setHidden:YES];
        [fullLeftBtn setHidden:YES];
        [leftBtn setHidden:YES];
        [fullRightBtn setHidden:YES];
        [rightBtn setHidden:YES];
        [fullUpBtn setHidden:YES];
        [upBtn setHidden:YES];
        [keyDetails setHidden:NO];
    }
}

-(IBAction)goRight:(id)sender
{
    NSInteger csrPstn;
    NSRange selectedRange;
    NSUInteger stringLength;
    unichar characterCode;
    NSString *currChar;
    
    stringLength = [[enteredText string] length];
    selectedRange = [enteredText selectedRange];
    csrPstn = selectedRange.location;
    if( isGreek ) csrPstn++;
    else
    {
        while( csrPstn++ < stringLength)
        {
            if( csrPstn == stringLength) break;
            currChar = [[enteredText string] substringWithRange:NSMakeRange(csrPstn, 1)];
            characterCode = [currChar characterAtIndex:0];
            if ( ( ( characterCode >= 0x05d0 ) && ( characterCode <= 0x05ea ) ) /* && ( characterCode > 255) */ || ( ( characterCode == 0x05be ) || ( characterCode == 0x05c0 ) || ( characterCode == 0x05c6 ) ) ) break;
        }
    }
    enteredText.selectedRange = NSMakeRange(csrPstn, 0);
}

-(IBAction)goFullRight:(id)sender
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

-(IBAction)goFullUp:(id)sender
{
    enteredText.selectedRange = NSMakeRange(0, 0);
}

-(IBAction)goUp:(id)sender
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
        /*        NSAlert *alert = [[NSAlert alloc] init];
         [alert addButtonWithTitle:@"OK"];
         [alert setMessageText:@"Information"];
         //        [alert setInformativeText:[NSString stringWithFormat:@"You have %lu rows", (unsigned long)noOfLines]];
         [alert setInformativeText:[wholeText substringWithRange:selectedRange]];
         [alert setAlertStyle:NSWarningAlertStyle];
         [alert runModal]; */
    }
}

-(IBAction)goDown:(id)sender
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

-(IBAction)goFullDown:(id)sender
{
    enteredText.selectedRange = NSMakeRange([enteredText string].length, 0);
}

-(IBAction)copyToClipboard:(id)sender
{
    NSPasteboard *targetPasteboard;
    
    targetPasteboard = [NSPasteboard generalPasteboard];
    [targetPasteboard clearContents];
    [targetPasteboard setString:[enteredText string] forType:NSPasteboardTypeString];
}

- (IBAction) doOpen:(id)sender
{
    NSString *openFile, *fileName;
    NSURL *startingFolder, *urlStart;
    NSArray *fileComponents;
    NSOpenPanel *openPanel;
    NSFileManager *fsOpen;
    
    fsOpen = [NSFileManager defaultManager];
    openPanel = [[NSOpenPanel alloc] init];
    if( [lastSavedDocument length] > 0 ) openFile = lastSavedDocument;
    else openFile = [[NSString alloc] initWithFormat:@"%@/GBSDefault.txt", [[fsOpen homeDirectoryForCurrentUser] absoluteString]];
    startingFolder = [[NSURL alloc] initFileURLWithPath:openFile];
    urlStart = [[NSURL alloc] initWithString:openFile];
    fileComponents = [[NSArray alloc] initWithArray:[urlStart pathComponents]];
    fileName = [[NSString alloc] initWithString:[fileComponents objectAtIndex:[fileComponents count] - 1]];
    [openPanel setTitle:@"Get previously saved Text"];
    [openPanel setPrompt:@"Get Text"];
    [openPanel setMessage:@"Get previously saved text for the Entered Text area"];
    [openPanel setCanChooseFiles:true];
    [openPanel setCanChooseDirectories:true];
    [openPanel setNameFieldStringValue:fileName];
    openPanel.directoryURL = urlStart;
    if( [openPanel runModal] == NSModalResponseOK )
    {
        openFile = [[NSString alloc] initWithString:[[[openPanel URLs] objectAtIndex:0] absoluteString]];
        if( [openFile containsString:@"file://"] ) openFile = [[NSString alloc] initWithString:[openFile substringFromIndex:7]];
        openFile = [openFile stringByReplacingOccurrencesOfString:@"%20" withString:@" "];
        if( ! [fsOpen fileExistsAtPath:openFile] )
        {
            NSAlert *alert;
            
            alert = [NSAlert new];
            [alert setMessageText:[[NSString alloc] initWithFormat: @"The file, %@, does not exist", openFile]];
            [alert setInformativeText:@"No file"];
            [alert setAlertStyle:NSAlertStyleInformational];
            [alert addButtonWithTitle:@"OK"];
            [alert runModal];
            return;
        }
        enteredText.string = [[NSString alloc] initWithContentsOfFile:openFile encoding:NSUTF8StringEncoding error:nil];
        lastSavedDocument = openFile;
    }
}

- (IBAction)doSaveAs:(id)sender
{
    NSString *saveFile, *fileName;
    NSURL *startingFolder, *urlStart;
    NSArray *fileComponents;
    NSSavePanel *savePanel;
    NSFileManager *fsSave;
    NSError *errorMsg;
    
    fsSave = [NSFileManager defaultManager];
    savePanel = [[NSSavePanel alloc] init];
    if( [lastSavedDocument length] > 0 ) saveFile = lastSavedDocument;
    else saveFile = [[NSString alloc] initWithFormat:@"%@/GBSDefault.txt", [[fsSave homeDirectoryForCurrentUser] absoluteString]];
    startingFolder = [[NSURL alloc] initFileURLWithPath:saveFile];
    urlStart = [[NSURL alloc] initWithString:saveFile];
    fileComponents = [[NSArray alloc] initWithArray:[urlStart pathComponents]];
    fileName = [[NSString alloc] initWithString:[fileComponents objectAtIndex:[fileComponents count] - 1]];
    [savePanel setTitle:@"Save Entered Text As ... "];
    [savePanel setPrompt:@"Save Text"];
    [savePanel setMessage:@"Save the current contents of the Entered Text area"];
    [savePanel setCanCreateDirectories:true];
    [savePanel setNameFieldStringValue:fileName];
    savePanel.directoryURL = urlStart;
    if( [savePanel runModal] == NSModalResponseOK )
    {
        saveFile = [[NSString alloc] initWithString:[[savePanel URL] absoluteString]];
        if( [saveFile containsString:@"file://"] ) saveFile = [[NSString alloc] initWithString:[saveFile substringFromIndex:7]];
        if( [fsSave fileExistsAtPath:saveFile] )
        {
            NSAlert *alert;
            
            alert = [NSAlert new];
            [alert setMessageText:[[NSString alloc] initWithFormat: @"The file, %@, already exists", saveFile]];
            [alert setInformativeText:@"Do you want to replace it?"];
            [alert setAlertStyle:NSAlertStyleInformational];
            [alert addButtonWithTitle:@"Yes"];
            [alert addButtonWithTitle:@"No"];
            if( [alert runModal] != NSAlertFirstButtonReturn) return;
        }
        saveFile = [saveFile stringByReplacingOccurrencesOfString:@"%20" withString:@" "];
        [[enteredText string] writeToFile:saveFile atomically:YES encoding:NSUTF8StringEncoding error:&errorMsg];
        lastSavedDocument = saveFile;
    }
}

- (IBAction)doSave:(id)sender
{
    if( [lastSavedDocument length] == 0 ) [self doSaveAs:sender];
    else [[enteredText string] writeToFile:lastSavedDocument atomically:YES encoding:NSUTF8StringEncoding error:nil];
}

- (IBAction)doPreferences:(id)sender
{
    frmPreferences *prefWindow;
  
    prefWindow = [[frmPreferences alloc] initWithWindowNibName:@"frmPreferences"];
    prefWindow.globalVarsPref = globalVars;
    [prefWindow showWindow:nil];
}

- (IBAction)doHelp:(id)sender
{
    frmHelp *appHelp;
    
    appHelp = [[frmHelp alloc] initWithWindowNibName:@"frmHelp"];
    [appHelp initialiseForm: appHelp];
    [appHelp showWindow:nil];
}

- (IBAction)doAbout:(id)sender
{
    frmAbout *aboutBox;
    
    aboutBox = [[frmAbout alloc] initWithWindowNibName:@"frmAbout"];
    [aboutBox simpleInitialisation:aboutBox];
    [[NSApplication sharedApplication] runModalForWindow:[aboutBox window]];
}

- (IBAction)doClose:(NSButton *)sender
{
    [[NSApplication sharedApplication] terminate:nil];
}

@end
