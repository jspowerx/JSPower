//
//  QVSharedUtil.h
//  JSPower
//
//  Created by everettjf on 2018/11/9.
//  Copyright © 2018 everettjf. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (MD5)
- (NSString *)MD5String;
@end

@interface NSURL (FilePath)
- (NSString *)filePathString;
@end

@interface QVSharedUtil : NSObject


+ (NSDictionary*)parseJSONFile:(NSURL*)path;
+ (NSDictionary*)parseJSON:(NSString*)json;

+ (void)mainThreadCall:(void(^)(void))block;

+ (NSString *)boxingIdentifier:(NSString*)identifier group:(NSString*)group;
+ (void)unboxingIdentifier:(NSString*)realIdentifier identifier:(NSString**)identifier group:(NSString**)group;

+ (NSError*)createError:(NSString*)info;
+ (NSError*)createInformationError:(NSString*)info;
+ (NSError*)createInternalError:(NSString*)info;
+ (NSError*)createJavaScriptError:(NSString*)info;

+ (void)openURL:(NSString*)url;

+ (BOOL)isSystemDarkMode;

@end

NS_ASSUME_NONNULL_END
