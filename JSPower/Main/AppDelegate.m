//
//  AppDelegate.m
//  JSPower
//
//  Created by everettjf on 2018/11/6.
//  Copyright © 2018 everettjf. All rights reserved.
//

#import "AppDelegate.h"
#import "QVSharedFile.h"
#import "PackageListController.h"
#import "AddPackageViewController.h"
#import "QVSharedUtil.h"

@interface AppDelegate ()<PackageListControllerDelegate>

@property (weak) IBOutlet NSWindow *window;

@property (strong) PackageListController *packageListController;
@property (weak) IBOutlet NSTableView *packageTableView;
@property (unsafe_unretained) IBOutlet NSTextView *contentTextView;

@property (strong) AddPackageViewController *addPackageViewController;
@end

@implementation AppDelegate

- (void)applicationWillFinishLaunching:(NSNotification *)notification
{
    [self.window center];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    [self checkDarkMode];
    
    self.packageListController = [[PackageListController alloc] init];
    self.packageListController.packageTableView = self.packageTableView;
    self.packageListController.contentTextView = self.contentTextView;
    self.packageListController.delegate = self;
    [self.packageListController setup];
    
    [self reloadPackages];

    [[NSNotificationCenter defaultCenter] addObserverForName:@"index.package.reload" object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
        [self reloadPackages];
    }];
}

-(void)reloadPackages
{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSString *error = nil;
        QVSharedPackageConfig *config = [[QVSharedPackageManager sharedManager] readPackageConfig:&error];
        if(!config){
            NSLog(@"%@", error);
            return;
        }
        
        self.packageListController.packages = [config.packages copy];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.packageListController reload];
            self.contentTextView.string = @"";
        });
    });
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}


- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender
{
    return YES;
}

- (IBAction)addPackageClicked:(id)sender
{
    NSLog(@"add");
    [AddPackageViewController run];
}

- (IBAction)removePackageClicked:(id)sender
{
    NSLog(@"remove");
    QVSharedPackageModelInConfig *selectedPackage = self.packageListController.selectedPackage;
    if(!selectedPackage){
        return;
    }
    
    NSAlert *alert = [[NSAlert alloc]init];
    alert.alertStyle = NSAlertStyleWarning;
    alert.informativeText = @"Really remove the package ?";
    [alert addButtonWithTitle:@"Confirm"];
    [alert addButtonWithTitle:@"Cancel"];
    NSModalResponse res = [alert runModal];
    if(res != 1000){
        // cancel
        return;
    }
    
    [[QVSharedPackageManager sharedManager] removePackage:selectedPackage.directoryName error:nil];
    [self reloadPackages];
}
- (IBAction)helpClicked:(id)sender
{
    [QVSharedUtil openURL:@"https://jspowerx.github.io"];
}

- (IBAction)reportIssueClicked:(id)sender
{
    [QVSharedUtil openURL:@"https://github.com/jspowerx/jspowerx.github.io/issues"];
}
- (IBAction)sayHelloToAuthorClicked:(id)sender
{
    [QVSharedUtil openURL:@"mailto:everettjf@live.com"];
}
- (IBAction)howToCreatePackageClicked:(id)sender
{
    [QVSharedUtil openURL:@"https://jspowerx.github.io/develop"];
}
- (IBAction)viewLocalClicked:(id)sender {
    NSURL *packageDir = [QVSharedPackageManager sharedManager].packagesDir;
    QVSharedPackageModelInConfig *selectedPackage = self.packageListController.selectedPackage;
    if(selectedPackage){
        packageDir = [packageDir URLByAppendingPathComponent:selectedPackage.directoryName];
    }
    
    [QVSharedUtil openURL:packageDir.absoluteString];
    
}
- (IBAction)marketClicked:(id)sender {
    [QVSharedUtil openURL:@"https://jspowerx.github.io/marketplace"];
}

- (void)packageListControllerSelectedPackageChanged:(PackageListController *)controller
{
    if(!self.packageListController.selectedPackage){
        self.contentTextView.string = @"";
        return;
    }
    
    NSString *manifestContent = [[QVSharedPackageManager sharedManager] readPackageManifestContent:self.packageListController.selectedPackage.directoryName];
    if(!manifestContent){
        self.contentTextView.string = @"";
        return;
    }
    
    self.contentTextView.string = manifestContent;
}

- (void)checkDarkMode
{
    if ([QVSharedUtil isSystemDarkMode]) {
        self.contentTextView.textColor = [NSColor whiteColor];
    } else {
        self.contentTextView.textColor = [NSColor blackColor];
    }
    self.contentTextView.font =  [NSFont fontWithName:@"Arial" size:13];

}

@end
