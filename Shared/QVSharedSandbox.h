//
//  QVSandbox.h
//  ToolBox
//
//  Created by everettjf on 2018/11/1.
//  Copyright © 2018 everettjf. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface QVSharedSandbox : NSObject

@property (nonatomic, strong) NSError *error;

- (BOOL)loadFile:(NSURL*)localFile;

- (NSString*)readString:(NSString*)varName;
- (NSArray*)readArray:(NSString*)varName;

- (NSDictionary*)call:(NSString*)functionName arguments:(NSArray*)arguments;

- (void)exportClass:(Class)cls name:(NSString*)name;
- (void)exportInstance:(id)obj name:(NSString*)name;
- (void)evaluateJavaScript:(NSString*)js;

@end

NS_ASSUME_NONNULL_END
