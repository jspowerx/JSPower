//
//  QVSystemJSObject.m
//  ToolBox
//
//  Created by everettjf on 2018/11/4.
//  Copyright © 2018 everettjf. All rights reserved.
//

#import "QVSystemJSObject.h"
#import <AppKit/AppKit.h>

@implementation QVSystemJSObject

+ (instancetype)createSystemObject
{
    QVSystemJSObject *obj = [[QVSystemJSObject alloc]init];
    return obj;
}

- (void)log:(NSString*)log
{
    NSLog(@"CODEFRIEND_JSLOG:%@",log);
}

- (void)openURL:(NSString*)url
{
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:url]];
}

@end
