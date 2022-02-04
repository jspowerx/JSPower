//
//  QVPackageManager.m
//  ToolBox
//
//  Created by everettjf on 2018/11/2.
//  Copyright © 2018 everettjf. All rights reserved.
//

#import "QVPackageManager.h"
#import "QVSharedPackageManager.h"

@implementation QVPackageManager

+ (instancetype) sharedManager
{
    static QVPackageManager *obj;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        obj = [[QVPackageManager alloc] init];
    });
    return obj;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _menuItems = @[];
        _packageMap = @{};
    }
    return self;
}

- (BOOL)load
{
    NSMutableArray<QVMenu *> *menuArray = [[NSMutableArray alloc] initWithCapacity:20];
    NSMutableDictionary<NSString *,QVPackage *> *packageMap = [[NSMutableDictionary alloc] init];

    
    // load additional packages
    BOOL overwriteBuiltin = NO;
    {
        NSString *error = nil;
        QVSharedPackageConfig *config = [[QVSharedPackageManager sharedManager] readPackageConfig:&error];
        if(config){
            for(QVSharedPackageModelInConfig *packageConfig in config.packages){
                NSURL *packagePath = [[QVSharedPackageManager sharedManager].packagesDir URLByAppendingPathComponent:packageConfig.directoryName];
                
                QVPackage * package = [QVPackage loadPackageFromPath:packagePath group:packageConfig.directoryName];
                if (!package) {
                    NSLog(@"load package failed : %@",packagePath);
                    continue;
                }
                [menuArray addObjectsFromArray:package.menuItems];
                
                for(QVMenu *menu in package.menuItems) {
                    packageMap[menu.globalIdentifier] = package;
                }
                
                // Whether overwrite builtin package
                if([packageConfig.directoryName isEqualToString:@"44CC571A293004E88945C743EA5764F3"]){
                    overwriteBuiltin = YES;
                }
            }
        }
    }
    
    // load builtin packages
    if(!overwriteBuiltin){
        NSURL *builtinPackagePath = [[[NSBundle mainBundle] resourceURL] URLByAppendingPathComponent:@"builtin.bundle"];
        QVPackage * package = [QVPackage loadPackageFromPath:builtinPackagePath group:@"builtin"];
        if (!package) {
            NSLog(@"load builtin package failed : %@",builtinPackagePath);
            return NO;
        }
        [menuArray addObjectsFromArray:package.menuItems];
        
        for(QVMenu *menu in package.menuItems) {
            packageMap[menu.globalIdentifier] = package;
        }
    }
    
    self.menuItems = menuArray;
    self.packageMap = packageMap;
    
    return YES;
}

@end
