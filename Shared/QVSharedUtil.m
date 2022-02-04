//
//  QVSharedUtil.m
//  JSPower
//
//  Created by everettjf on 2018/11/9.
//  Copyright © 2018 everettjf. All rights reserved.
//

#import "QVSharedUtil.h"
#import <pthread.h>
#import <CommonCrypto/CommonDigest.h>
#import <Cocoa/Cocoa.h>

static NSString * const kCommandIdentifierPrefix = @"com.everettjf.qvcodefriend";


@implementation NSString (MD5)
- (NSString *)MD5String {
    const char *cStr = [self UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5( cStr, (CC_LONG)strlen(cStr), result );
    
    return [NSString stringWithFormat:
            @"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
            result[0], result[1], result[2], result[3],
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]
            ];
}
@end

@implementation NSURL (FilePath)
- (NSString *)filePathString
{
    NSString *result = self.absoluteString;
    if(result.length > 7){
        NSString *prefix = [result substringToIndex:7];
        if([prefix isEqualToString:@"file://"]){
            result = [result substringFromIndex:7];
        }
    }
    result = [result stringByReplacingOccurrencesOfString:@"%20" withString:@" "];
    
    return result;
}
@end


@implementation QVSharedUtil


+ (NSDictionary*)parseJSONFile:(NSURL*)path
{
    NSError *error = nil;
    NSString *content = [[NSString alloc] initWithContentsOfURL:path encoding:NSUTF8StringEncoding error:&error];
    if(!content){
        return nil;
    }
    return [self parseJSON:content];
}

+ (NSDictionary*)parseJSON:(NSString*)json
{
    NSData *data = [json dataUsingEncoding:NSUTF8StringEncoding];
    if(!data){
        return nil;
    }
    
    NSError *error = nil;
    NSDictionary * dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
    if(!dict){
        return nil;
    }
    return dict;
}

+ (void)mainThreadCall:(void(^)(void))block
{
    if(pthread_main_np() != 0){
        block();
    }else{
        dispatch_async(dispatch_get_main_queue(), ^{
            block();
        });
    }
}


+ (NSString *)boxingIdentifier:(NSString*)identifier group:(NSString*)group
{
    return [NSString stringWithFormat:@"%@.%@.%@",kCommandIdentifierPrefix,group,identifier];
}
+ (void)unboxingIdentifier:(NSString*)realIdentifier identifier:(NSString**)identifier group:(NSString**)group
{
    NSString *appPrefix = [NSString stringWithFormat:@"%@.",kCommandIdentifierPrefix];
    NSString *groupAndId = [realIdentifier stringByReplacingOccurrencesOfString:appPrefix withString:@""];
    
    *group = [groupAndId componentsSeparatedByString:@"."][0];
    NSString *groupPrefix = [NSString stringWithFormat:@"%@.",*group];
    *identifier = [groupAndId stringByReplacingOccurrencesOfString:groupPrefix withString:@""];
}
+ (NSError *)createError:(NSString *)info
{
    return [NSError errorWithDomain:NSCocoaErrorDomain code:6 userInfo:@{
                                                                         NSLocalizedDescriptionKey : info
                                                                         }];
}

+ (NSError*)createInformationError:(NSString*)info
{
    return [QVSharedUtil createError:[NSString stringWithFormat:@"INFORMATION : %@",info]];
}
+ (NSError*)createInternalError:(NSString*)info
{
    return [QVSharedUtil createError:[NSString stringWithFormat:@"INTERNAL ERROR : %@",info]];
}
+ (NSError*)createJavaScriptError:(NSString*)info
{
    return [QVSharedUtil createError:[NSString stringWithFormat:@"JAVASCRIPT ERROR : %@",info]];
}

+ (void)openURL:(NSString *)url
{
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:url]];
}

+ (BOOL)isSystemDarkMode
{
    NSAppearance *appearance = NSAppearance.currentAppearance;
    if (@available(*, macOS 10.14)) {
        return appearance.name == NSAppearanceNameDarkAqua;
    }
    
    return NO;
}

@end
