//
//  QVCommandAction.m
//  ToolBox
//
//  Created by everettjf on 2018/11/3.
//  Copyright © 2018 everettjf. All rights reserved.
//

#import "QVCommandAction.h"
#import "QVSharedSandbox.h"
#import "QVSharedUtil.h"
#import <AppKit/AppKit.h>
#import "JSObject/QVCommandInvocationJSObject.h"
#import "JSObject/QVSystemJSObject.h"


@implementation QVCommandAction

- (BOOL)fire
{
    QVSharedSandbox *sandbox = [[QVSharedSandbox alloc] init];
    
    BOOL result = [sandbox loadFile:self.menu.entryPath];
    if(! result){
        self.error = [QVSharedUtil createInternalError: [NSString stringWithFormat: @"Could not load file : %@", [self.menu.entryPath absoluteString]]];
        return NO;
    }
    
    [sandbox exportClass:[QVCommandInvocationJSObject class] name:@"invocation"];
    
    NSArray<NSString*> *entries = [sandbox readArray:@"entry"];
    NSLog(@"menu files %@", entries);
    
    if(entries.count > 0) {
        for(NSString *fileName in entries){
            NSURL *filePath = [self.menu.path URLByAppendingPathComponent:fileName];
            NSLog(@"part file path %@", filePath);
            
            result = [sandbox loadFile:filePath];
            if(! result){
                self.error = sandbox.error;
                return NO;
            }
        }
    }
    
    NSString *unboxedIdentifier = nil;
    NSString *group = nil;
    [QVSharedUtil unboxingIdentifier:self.invocation.commandIdentifier identifier:&unboxedIdentifier group:&group];
    
    NSLog(@"contentUTI = %@", self.invocation.buffer.contentUTI);
    NSLog(@"indentationWidth = %@", @(self.invocation.buffer.indentationWidth));
    NSLog(@"usesTabsForIndentation = %@", @(self.invocation.buffer.usesTabsForIndentation));
    NSLog(@"tabWidth = %@", @(self.invocation.buffer.tabWidth));
    
    QVCommandInvocationJSObject *commandInvocation = [[QVCommandInvocationJSObject alloc] init];
    commandInvocation.invocation = self.invocation;
    [sandbox exportInstance:commandInvocation name:@"invocation"];
    
    QVSystemJSObject *systemJSObject = [[QVSystemJSObject alloc]init];
    [sandbox exportInstance:systemJSObject name:@"system"];
    
    NSDictionary *dict = [sandbox call:@"onMenuClicked" arguments:@[unboxedIdentifier]];
    
    if(!dict){
        NSLog(@"function onMenuClicked throws exception or not found");
        self.error = sandbox.error;
        return NO;
    }
    
    if(![dict isKindOfClass:NSDictionary.class]) {
        NSLog(@"result is not dictionary");
        self.error = [QVSharedUtil createInternalError:@"function onMenuClicked result is not a dictionary"];
        return NO;
    }
    
    NSNumber *resultFromScript = dict[@"result"];
    if(! resultFromScript){
        self.error = [QVSharedUtil createInternalError:@"no \"result\" field in function onMenuClicked result"];
        return NO;
    }
    
    if( ! resultFromScript.boolValue) {
        NSString *errorMsg = dict[@"error"];
        if(errorMsg){
            self.error = [QVSharedUtil createInformationError:errorMsg];
        }else{
//            self.error = [QVSharedUtil createInformationError:@"Maybe failed (without error message)"];
        }
        return NO;
    }
    
    return YES;
}

@end
