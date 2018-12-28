//
//  SourceEditorExtension.m
//  ToolBox
//
//  Created by everettjf on 2018/10/30.
//  Copyright © 2018 everettjf. All rights reserved.
//

#import "SourceEditorExtension.h"
#import "QVSharedUtil.h"
#import "QVPackageManager.h"
#import "QVSharedFile.h"

@implementation SourceEditorExtension


- (void)extensionDidFinishLaunching
{
    NSLog(@"extensionDidFinishLaunching");
    
    BOOL result = [[QVPackageManager sharedManager] load];
    if(!result){
        NSLog(@"failed load package");
    }
}


- (NSArray <NSDictionary <XCSourceEditorCommandDefinitionKey, id> *> *)commandDefinitions
{
    NSMutableArray *commands = [[NSMutableArray alloc] init];
    
    NSArray<QVMenu*> * menuItems = [[QVPackageManager sharedManager] menuItems];
    NSLog(@"commandDefinitions = %@", menuItems);
    
    for(QVMenu *menu in menuItems) {
        [commands addObject:@{
                              XCSourceEditorCommandNameKey : menu.name,
                              XCSourceEditorCommandIdentifierKey : menu.globalIdentifier,
                              XCSourceEditorCommandClassNameKey : @"SourceEditorCommand",
                              }];
        NSLog(@"menu name = %@ , id = %@", menu.name, menu.globalIdentifier);
    }
    
    return commands;
}


@end
