//
//  QVSharedPackageManager.m
//  JSPower
//
//  Created by everettjf on 2018/11/8.
//  Copyright © 2018 everettjf. All rights reserved.
//

#import "QVSharedPackageManager.h"
#import "QVSharedUtil.h"
#import <YYModel.h>
#import "QVSharedFile.h"

@implementation QVSharedPackageManifestMenuItemuModel
+ (NSDictionary *)modelCustomPropertyMapper {
    return @{
             @"identifier":@"id"
             };
}
@end

@implementation QVSharedPackageManifestModel

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{
             @"desc":@"description"
             };
}

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{
             @"menu" : QVSharedPackageManifestMenuItemuModel.class
             };
}
@end

@implementation QVSharedPackageModelInConfig
@end

@implementation QVSharedPackageConfig

- (instancetype)init
{
    self = [super init];
    if (self) {
        _packages = [[NSMutableArray alloc]init];
    }
    return self;
}

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{
             @"packages" : QVSharedPackageModelInConfig.class
             };
}
- (BOOL)modelCustomTransformFromDictionary:(NSDictionary *)dic {
    NSNumber *updatedAt = dic[@"updatedAt"];
    if (![updatedAt isKindOfClass:[NSNumber class]]) return NO;
    _updatedAt = [NSDate dateWithTimeIntervalSince1970:updatedAt.floatValue];
    return YES;
}
- (BOOL)modelCustomTransformToDictionary:(NSMutableDictionary *)dic {
    if (!_updatedAt) return NO;
    dic[@"updatedAt"] = @(_updatedAt.timeIntervalSince1970);
    return YES;
}
@end

@interface QVSharedPackageManager ()

@end

@implementation QVSharedPackageManager


+ (instancetype)sharedManager
{
    static QVSharedPackageManager *obj;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        obj = [[QVSharedPackageManager alloc] init];
    });
    return obj;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _documentDir = [QVSharedFile sharedFile].rootPath;
        _packagesDir = [_documentDir URLByAppendingPathComponent:@"Packages"];
        _packagesJsonPath = [_packagesDir URLByAppendingPathComponent:@"packages.json"];
        
        if(![[NSFileManager defaultManager] fileExistsAtPath:_packagesDir.absoluteString]){
            [[NSFileManager defaultManager] createDirectoryAtURL:_packagesDir withIntermediateDirectories:YES attributes:nil error:nil];
        }
        
        NSLog(@"document dir : %@",_documentDir);
    }
    return self;
}

- (NSString*)getPackageName:(NSURL*)packageURL
{
    return [[packageURL absoluteString] MD5String];
}

- (QVSharedPackageConfig*)readPackageConfig:(NSString**)error
{
    if(![[NSFileManager defaultManager] fileExistsAtPath:[_packagesJsonPath filePathString]]){
        return [[QVSharedPackageConfig alloc] init];
    }
    NSString *json = [NSString stringWithContentsOfURL:_packagesJsonPath encoding:NSUTF8StringEncoding error:nil];
    if(!json){
        *error = @"Failed to read file";
        return nil;
    }
    
    QVSharedPackageConfig *config = [QVSharedPackageConfig yy_modelWithJSON:json];
    if(!config){
        *error = @"Failed to parse file";
        return nil;
    }
    
    return config;
}
- (BOOL)addPackageToConfig:(QVSharedPackageModelInConfig*)package error:(NSString**)error
{
    // read
    NSString *errorInfo = nil;
    QVSharedPackageConfig *config = [self readPackageConfig:&errorInfo];
    if(!config){
        *error = errorInfo;
        return NO;
    }
    
    // add
    [config.packages addObject:package];
    
    
    // save
    config.updatedAt = [NSDate date];
    NSString *json = [config yy_modelToJSONString];
    if(!json){
        *error = @"Failed to serialize config to json";
        return NO;
    }
    if(! [json writeToURL:_packagesJsonPath atomically:YES encoding:NSUTF8StringEncoding error:nil]){
        *error = @"Failed to write file";
        return NO;
    }
    
    return YES;
}
- (BOOL)removePackage:(NSString*)directoryName error:(NSString**)error
{
    // read
    NSString *errorInfo = nil;
    QVSharedPackageConfig *config = [self readPackageConfig:&errorInfo];
    if(!config){
        *error = errorInfo;
        return NO;
    }
    
    // remove
    QVSharedPackageModelInConfig *foundModel = nil;
    for(QVSharedPackageModelInConfig *model in config.packages){
        if([model.directoryName isEqualToString:directoryName]){
            foundModel = model;
            break;
        }
    }
    if(foundModel){
        [config.packages removeObject:foundModel];
    }
    
    // save
    config.updatedAt = [NSDate date];
    NSString *json = [config yy_modelToJSONString];
    if(!json){
        *error = @"Failed to serialize config to json";
        return NO;
    }
    if(! [json writeToURL:_packagesJsonPath atomically:YES encoding:NSUTF8StringEncoding error:nil]){
        *error = @"Failed to write file";
        return NO;
    }
    
    // remove directory
    NSURL *packageUrl = [_packagesDir URLByAppendingPathComponent:directoryName];
    [[NSFileManager defaultManager]removeItemAtURL:packageUrl error:nil];
    
    return YES;
}

- (NSString*)readPackageManifestContent:(NSString*)directoryName
{
    NSURL *packagePath = [_packagesDir URLByAppendingPathComponent:directoryName];
    NSURL *manifestPath = [packagePath URLByAppendingPathComponent:@"manifest.json"];
    if(!manifestPath){
        return nil;
    }
    
    return [NSString stringWithContentsOfURL:manifestPath encoding:NSUTF8StringEncoding error:nil];
}


@end
