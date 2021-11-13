//
//  frmHelp.m
//  GkHebKeyboard
//
//  Created by Leonard Clark on 24/12/2020.
//

#import "frmHelp.h"

@interface frmHelp ()

@end

@implementation frmHelp

@synthesize helpWeb;

frmHelp *currentForm;

- (void)windowDidLoad {
    [super windowDidLoad];
    
    NSString *helpFileName, *htmlContent;
    NSURL *helpFile;
    NSURLRequest *newRequest;
    NSError *error;
    
    helpFileName = [[NSBundle mainBundle] pathForResource:@"Help" ofType:@"html"];
    helpFile = [NSURL fileURLWithPath: helpFileName];
    htmlContent = [[NSString alloc] initWithContentsOfFile:helpFileName encoding:NSUTF8StringEncoding error:&error];
    newRequest = [[NSURLRequest alloc] initWithURL:helpFile];
    [[helpWeb mainFrame] loadRequest:newRequest];
}

- (void) initialiseForm: (frmHelp *) inForm
{
    currentForm = inForm;
}

- (IBAction)doClose:(id)sender
{
    [currentForm close];
}

@end
