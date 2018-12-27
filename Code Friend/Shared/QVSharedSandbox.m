//
//  QVSandbox.m
//  ToolBox
//
//  Created by everettjf on 2018/11/1.
//  Copyright © 2018 everettjf. All rights reserved.
//

#import "QVSharedSandbox.h"
#import "QVSharedUtil.h"
@import JavaScriptCore;

@interface QVSharedSandbox()
@property (nonatomic, strong) JSContext *context;
@end

@implementation QVSharedSandbox

- (instancetype)init
{
    self = [super init];
    if (self) {
        _context = [[JSContext alloc] init];
        
        __weak __typeof(self) ws = self;
        _context.exceptionHandler = ^(JSContext *context, JSValue *exception) {
            NSLog(@"JS Error: %@", exception);
            ws.error = [QVSharedUtil createJavaScriptError:[NSString stringWithFormat:@"%@",exception]];
        };
    }
    return self;
}

- (BOOL)loadFile:(NSURL *)localFile
{
    NSError *error = nil;
    NSString *jsContent = [NSString stringWithContentsOfURL:localFile encoding:NSUTF8StringEncoding error:& error];
    if( jsContent == nil) {
        NSLog(@"Can not read js file : %@ , error = %@", localFile, error);
        self.error = [QVSharedUtil createInternalError:[NSString stringWithFormat:@"failed to read file = %@ , error = %@",localFile,error]];
        return NO;
    }
    
    [self.context evaluateScript:jsContent];
    return YES;
}



- (NSString*)readString:(NSString*)varName
{
    return [self.context[varName] toString];
}
- (NSArray*)readArray:(NSString*)varName
{
    return [self.context[varName] toArray];
}

- (NSDictionary*)call:(NSString*)functionName arguments:(NSArray*)arguments
{
    JSValue *function = self.context[functionName];
    if(!function || [function isUndefined]){
        self.error = [QVSharedUtil createInternalError:[NSString stringWithFormat:@"failed to find function %@",functionName]];
        return nil;
    }
    JSValue *result = [function callWithArguments:arguments];
    if(!result){
        self.error = [QVSharedUtil createInternalError:[NSString stringWithFormat:@"failed to call function"]];
        return nil;
    }
    
    return [result toDictionary];
}

- (void)exportClass:(Class)cls name:(NSString*)name
{
    self.context[name] = cls;
}

- (void)evaluateJavaScript:(NSString*)js
{
    [self.context evaluateScript:js];
}
- (void)exportInstance:(id)obj name:(NSString*)name
{
    self.context[name] = obj;
}

@end
