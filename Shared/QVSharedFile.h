//
//  QVSharedFile.h
//  JSPower
//
//  Created by everettjf on 2018/11/7.
//  Copyright © 2018 everettjf. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

//    [[QVSharedFile sharedFile] writeFile:@"/hello.txt" content:@"testing"];
//    [[QVSharedFile sharedFile] writeFile:@"/hello.txt" content:@"testingbbbbbb"];
//    [[QVSharedFile sharedFile] writeFile:@"/a/b/c/hello.txt" content:@"testing"];
//    [[QVSharedFile sharedFile] writeFile:@"/a/b/c/hello.txt" content:@"testingccccccc"];
//
//    NSLog(@"%@",[[QVSharedFile sharedFile] readFile:@"/hello.txt"]);
//    NSLog(@"%@",[[QVSharedFile sharedFile] readFile:@"/hello.txt"]);
//    NSLog(@"%@",[[QVSharedFile sharedFile] readFile:@"/a/b/c/hello.txt"]);
//    NSLog(@"%@",[[QVSharedFile sharedFile] readFile:@"/a/b/c/hello.txt"]);


/*
 relativePath :
 /
 /filename.txt
 /dira/dirb/dirc
 /dira/dirb/dirc/hello.txt
 */
@interface QVSharedFile : NSObject
@property (nonatomic, copy) NSURL *rootPath;

+ (instancetype)sharedFile;

- (BOOL)writeFile:(NSString*)relativePath content:(NSString*)content;
- (NSString*)readFile:(NSString*)relativePath;
- (NSDictionary*)readJSON:(NSString*)relativePath;

- (BOOL)createDirectory:(NSString*)relativePath;
- (BOOL)removeDirectory:(NSString*)relativePath;

@end

NS_ASSUME_NONNULL_END
