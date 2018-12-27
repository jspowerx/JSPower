//
//  QVSystemJSObject.h
//  ToolBox
//
//  Created by everettjf on 2018/11/4.
//  Copyright © 2018 everettjf. All rights reserved.
//

#import <Foundation/Foundation.h>
@import JavaScriptCore;
#import <XcodeKit/XcodeKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol QVSystemJSExport <JSExport>

+ (instancetype)createSystemObject;

- (void)log:(NSString*)log;
- (void)openURL:(NSString*)url;

@end

@interface QVSystemJSObject : NSObject <QVSystemJSExport>

@end

NS_ASSUME_NONNULL_END
