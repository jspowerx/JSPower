//
//  QVSharedFile.m
//  Code Friend
//
//  Created by everettjf on 2018/11/7.
//  Copyright © 2018 everettjf. All rights reserved.
//

#import "QVSharedFile.h"
#import "QVSharedHeader.h"
#import "QVSharedUtil.h"

@interface QVSharedFile ()
@end

@implementation QVSharedFile

+ (instancetype)sharedFile
{
    static QVSharedFile *obj;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        obj = [[QVSharedFile alloc] init];
    });
    return obj;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        NSString *groupId = [NSString stringWithUTF8String:kAppGroupIdentifier];
        _rootPath = [[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:groupId];
    }
    return self;
}

- (NSURL*)resolveFullPath:(NSString*)relativePath
{
    NSURL *result = self.rootPath;
    NSArray<NSString*> *names = [relativePath componentsSeparatedByString:@"/"];
    for(NSString *name in names){
        if(name.length > 0){
            result = [result URLByAppendingPathComponent:name];
        }
    }
    return result;
}

- (void)ensureFileDirectoryExist:(NSURL*)filePath
{
    NSURL *dirPath = [filePath URLByDeletingLastPathComponent];
    if(![[NSFileManager defaultManager] fileExistsAtPath:[dirPath absoluteString]]){
        [[NSFileManager defaultManager] createDirectoryAtURL:dirPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
}

- (BOOL)writeFile:(NSString*)relativePath content:(NSString*)content
{
    NSURL *filePath = [self resolveFullPath:relativePath];
    [self ensureFileDirectoryExist:filePath];
    return [content writeToURL:filePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
}

- (NSString*)readFile:(NSString*)relativePath
{
    NSURL *filePath = [self resolveFullPath:relativePath];
    NSString *content = [NSString stringWithContentsOfURL:filePath encoding:NSUTF8StringEncoding error:nil];
    return content;
}

- (NSDictionary*)readJSON:(NSString*)relativePath
{
    NSURL *filePath = [self resolveFullPath:relativePath];

    NSError *error = nil;
    NSString *content = [[NSString alloc] initWithContentsOfURL:filePath encoding:NSUTF8StringEncoding error:&error];
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
    return dict;
}


- (BOOL)createDirectory:(NSString*)relativePath
{
    NSURL *dirPath = [self resolveFullPath:relativePath];
    return [[NSFileManager defaultManager] createDirectoryAtURL:dirPath withIntermediateDirectories:YES attributes:nil error:nil];
}

- (BOOL)removeDirectory:(NSString*)relativePath
{
    NSURL *dirPath = [self resolveFullPath:relativePath];
    return [[NSFileManager defaultManager] removeItemAtURL:dirPath error:nil];
}
@end
