//
//  QVCommandAction.h
//  ToolBox
//
//  Created by everettjf on 2018/11/3.
//  Copyright © 2018 everettjf. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <XcodeKit/XcodeKit.h>
#import "QVPackage.h"

NS_ASSUME_NONNULL_BEGIN


@interface QVCommandAction : NSObject

@property (nonatomic, strong) QVMenu *menu;
@property (nonatomic, strong) XCSourceEditorCommandInvocation *invocation;
@property (nonatomic, strong) NSError *error;

- (BOOL)fire;

@end

NS_ASSUME_NONNULL_END
