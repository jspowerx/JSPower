//
//  AddPackageViewController.m
//  JSPower
//
//  Created by everettjf on 2018/11/8.
//  Copyright © 2018 everettjf. All rights reserved.
//

#import "AddPackageViewController.h"
#import "../../Shared/QVSharedPackageManager.h"
#import "../../Shared/QVSharedUtil.h"
#import "../Logic/QVPackageDownloader.h"
#import "AddPackageLogic.h"

@interface AddPackageViewController ()<NSWindowDelegate, AddPackageLogicDelegate>
@property (weak) IBOutlet NSTextField *packageUrlTextField;
@property (unsafe_unretained) IBOutlet NSTextView *logTextView;
@property (weak) IBOutlet NSButton *addButton;
@property (weak) IBOutlet NSButton *cancelButton;

@property (strong) AddPackageLogic *logic;

@property (nonatomic,assign) BOOL completed;
@property (nonatomic,assign) BOOL adding;

@end

@implementation AddPackageViewController


+ (void)run
{
    AddPackageViewController *vc = [[AddPackageViewController alloc] initWithWindowNibName:@"AddPackageViewController"];
    [[NSApplication sharedApplication] runModalForWindow:vc.window];
}

- (void)windowDidLoad {
    [super windowDidLoad];
    
    self.window.delegate = self;
    [self.window center];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    
    NSLog(@"windowdidload");
}

- (void)windowWillClose:(NSNotification *)notification
{
    [NSApp stopModalWithCode:0];
}

- (BOOL)windowShouldClose:(NSWindow *)sender
{
    if(self.adding){
        return NO;
    }else{
        return YES;
    }
}

- (void)closeWindow
{
    [NSApp stopModalWithCode:0];
    [self.window close];
}

- (IBAction)cancelAction:(NSButton *)sender
{
    [self closeWindow];
}

- (IBAction)addAction:(NSButton *)sender
{
    if(self.completed){
        [self closeWindow];
        return;
    }
    [self updateAddingState:YES];
    
    NSString *packageUrlString = self.packageUrlTextField.stringValue;
    
    self.logic = [[AddPackageLogic alloc] init];
    self.logic.delegate = self;
    [self.logic startAddPackage:packageUrlString];
}

- (void)updateAddingState:(BOOL)adding
{
    self.adding = adding;
    if(self.adding){
        // disable
        self.addButton.enabled = NO;
        self.cancelButton.enabled = NO;
    }else{
        // enable
        self.addButton.enabled = YES;
        self.cancelButton.enabled = YES;
    }
}

- (void)addLog:(NSString*)log
{
    self.logTextView.string = [self.logTextView.string stringByAppendingFormat:@"%@\n",log];
    [self.logTextView scrollToEndOfDocument:nil];
}

- (void)addPackageLogic:(AddPackageLogic *)logic info:(NSString *)info
{
    [self addLog:info];
}

- (void)addPackageLogic:(AddPackageLogic *)logic error:(NSString *)error
{
    [self addLog:error];
    
    [self updateAddingState:NO];
}

- (void)addPackageLogicSucceed:(AddPackageLogic *)logic
{
    [self updateAddingState:NO];
    
    self.completed = YES;
    
    self.addButton.enabled = YES;
    self.cancelButton.enabled = NO;
    self.cancelButton.hidden = YES;
    [self.addButton setTitle:@"Close"];
}
- (IBAction)tryDLCPack1Clicked:(id)sender {
    self.packageUrlTextField.stringValue = @"https://jspowerx.github.io/packages/dlc/";
}

@end
