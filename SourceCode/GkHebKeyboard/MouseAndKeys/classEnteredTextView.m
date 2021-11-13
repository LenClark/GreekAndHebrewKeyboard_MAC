//
//  classEnteredTextView.m
//  GkHebKeyboard
//
//  Created by Leonard Clark on 16/12/2020.
//

#import "classEnteredTextView.h"

@implementation classEnteredTextView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

- (void) keyDown:(NSEvent *)event
{
    /*
     ************************************************************
     *                                                          *
     *                         keyDown                          *
     *                         =======                          *
     *                                                          *
     *  We will refer to keys pressed with Ctrl, Option or cmd  *
     *    as "modified keys".                                   *
     *                                                          *
     *  If a modified key is pressed, typeOfKey will have one   *
     *    of the following values:                              *
     *                                                          *
     *    Modifying Key               typeOfKey value           *
     *    -------------               ---------------           *
     *      Ctrl                           1                    *
     *      Option                         2                    *
     *      Cmd                            3                    *
     *                                                          *
     *  If the key is unmodified, typeOfKey = 0.                *
     *                                                          *
     ************************************************************/
     
    bool isGreek;
    NSInteger typeOfKey = 0;
    unichar initialChar, finalChar = '\0';
    classKeyboard *keyboardCtrl;
    AppDelegate *mainAppDelegate;

    mainAppDelegate = (AppDelegate *)[[NSApplication sharedApplication] delegate];
    keyboardCtrl = [mainAppDelegate keyboard];
    isGreek = [mainAppDelegate isGreek];
    if( [event modifierFlags] & NSEventModifierFlagControl ) typeOfKey = 1;
    if( [event modifierFlags] & NSEventModifierFlagOption ) typeOfKey = 2;
    if( [event modifierFlags] & NSEventModifierFlagCommand ) typeOfKey = 3;
    if( typeOfKey == 0 )
    {
        switch ([event keyCode])
        {
            case 36: [keyboardCtrl virtualKeyPress: '\n' withControl: isGreek]; break;  // Enter/return
            case 51: [keyboardCtrl virtualKeyPress: '\b' withControl: isGreek]; break;  // Backspace
            case 53: [keyboardCtrl virtualKeyPress: '@' withControl: isGreek]; break;  // Esc
            case 117: [keyboardCtrl virtualKeyPress: (unichar) 7 withControl: isGreek]; break;  // Del (fn + bspace)
            case 115: [keyboardCtrl virtualKeyPress: (unichar) 128 withControl: isGreek]; break;  // fn + left arrow = start of line
            case 116: [keyboardCtrl virtualKeyPress: (unichar) 129 withControl: isGreek]; break;  // fn + up arrow = start of input
            case 119: [keyboardCtrl virtualKeyPress: (unichar) 130 withControl: isGreek]; break;  // fn + right arrow = end of line
            case 121: [keyboardCtrl virtualKeyPress: (unichar) 131 withControl: isGreek]; break;  // fn + down arrow = end of input
            case 126: [keyboardCtrl virtualKeyPress: (unichar) 132 withControl: isGreek]; break;  // up arrow
            case 125: [keyboardCtrl virtualKeyPress: (unichar) 133 withControl: isGreek]; break;  // down arrow
            case 124: [keyboardCtrl virtualKeyPress: (unichar) 134 withControl: isGreek]; break;  // right arrow
            case 123: [keyboardCtrl virtualKeyPress: (unichar) 135 withControl: isGreek]; break;  // left arrow
            default: [keyboardCtrl virtualKeyPress:[[event characters] characterAtIndex:0] withControl: isGreek]; break;
        }
    }
    else
    {
        initialChar = [[event charactersIgnoringModifiers] characterAtIndex:0];
        if( isGreek )
        {
            switch (initialChar)
            {
                case 'e': finalChar = 0x03B7; break;
                case 'o': finalChar = 0x03C9; break;
                case 'p': finalChar = 0x03C8; break;
                case 's': finalChar = 0x03C2; break;
                case 't': finalChar = 0x03B8; break;
                case 'E': finalChar = 0x0397; break;
                case 'O': finalChar = 0x03A9; break;
                case 'P': finalChar = 0x03A8; break;
                case 'T': finalChar = 0x0398; break;
                default: break;
            }
        }
        else
        {
            switch (initialChar)
            {
                case '0': finalChar = 0x059B; break;
                case '1': finalChar = 0x059C; break;
                case '2': finalChar = 0x059D; break;
                case '3': finalChar = 0x059E; break;
                case '4': finalChar = 0x059F; break;
                case '5': finalChar = 0x05A0; break;
                case '6': finalChar = 0x05A1; break;
                case '7': finalChar = 0x05A2; break;
                case '8': finalChar = 0x05A3; break;
                case '9': finalChar = 0x05A4; break;
                case 'a': finalChar = 0x05A5; break;
                case 'b': finalChar = 0x05A6; break;
                case 'c': finalChar = 0x05A7; break;
                case 'd': finalChar = 0x05A8; break;
                case 'e': finalChar = 0x05A9; break;
                case 'f': finalChar = 0x05AA; break;
                case 'g': finalChar = 0x05AB; break;
                case 'h': finalChar = 0x05AC; break;
                case 'i': finalChar = 0x05AD; break;
                case 'j': finalChar = 0x05AE; break;
                case 'k': finalChar = 0x05AF; break;
                case 'l': finalChar = 0x05BD; break;
                case 'm': finalChar = 0x05BF; break;
                case 'n': finalChar = 0x05C0; break;
                case 'o': finalChar = 0x05C5; break;
                case 'p': finalChar = 0x05C6; break;
                case 'q': finalChar = 0x05C7; break;
                case 'r': finalChar = 0x05F0; break;
                case 's': finalChar = 0x05F1; break;
                case 't': finalChar = 0x05F2; break;
                case 'u': finalChar = 0x05F3; break;
                case 'v': finalChar = 0x05F4; break;
                default: break;
            }
        }
        [keyboardCtrl virtualKeyPress:finalChar withControl: isGreek];
    }
}

@end
