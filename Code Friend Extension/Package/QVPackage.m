//
//  QVPackage.m
//  ToolBox
//
//  Created by everettjf on 2018/11/2.
//  Copyright © 2018 everettjf. All rights reserved.
//

#import "QVPackage.h"
#import "QVSharedUtil.h"


@implementation QVMenu

@end

@implementation QVPackage

- (instancetype)init
{
    self = [super init];
    if (self) {
        _menuItems = @[];
        _menuMap = @{};
    }
    return self;
}

+ (QVPackage*)loadPackageFromPath:(NSURL *)path group:(NSString*)group
{
    QVPackage * package = [[QVPackage alloc] init];
    package.path = path;
    package.manifestPath = [package.path URLByAppendingPathComponent:@"manifest.json"];
    package.group = group;
    
    NSError *error = nil;
    NSString *content = [[NSString alloc] initWithContentsOfURL:package.manifestPath encoding:NSUTF8StringEncoding error:&error];
    if(!content){
        return nil;
    }
    NSData *data = [content dataUsingEncoding:NSUTF8StringEncoding];
    if(!data){
        return nil;
    }
    
    NSDictionary * dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
    if(!dict){
        return nil;
    }
    
    NSMutableArray<QVMenu *> *menuItems = [[NSMutableArray alloc] init];
    for (NSDictionary *item in dict[@"menu"]) {
        QVMenu *menu = [[QVMenu alloc] init];
        menu.name = item[@"name"];
        menu.identifier = item[@"id"];
        menu.globalIdentifier = [QVSharedUtil boxingIdentifier:menu.identifier group:group];
        
        NSString *menuDirectoryName = menu.identifier;
        NSArray<NSString*> * parts = [menu.identifier componentsSeparatedByString:@"."];
        if (parts.count > 0) {
            menuDirectoryName = parts[0];
        }
        menu.path = [package.path URLByAppendingPathComponent:menuDirectoryName];
        menu.entryPath = [menu.path URLByAppendingPathComponent:@"entry.js"];

        [menuItems addObject:menu];
    }
    package.menuItems = menuItems;
    
    NSMutableDictionary<NSString *, QVMenu *> * menuMap = [[NSMutableDictionary alloc] initWithCapacity:package.menuItems.count];
    for(QVMenu *menu in package.menuItems) {
        menuMap[menu.globalIdentifier] = menu;
    }
    package.menuMap = menuMap;
    
    return package;
}


@end
