//
//  QVPackageManager.h
//  ToolBox
//
//  Created by everettjf on 2018/11/2.
//  Copyright © 2018 everettjf. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QVPackage.h"

NS_ASSUME_NONNULL_BEGIN

@interface QVPackageManager : NSObject

@property (nonatomic, strong) NSArray<QVMenu*> *menuItems;
@property (nonatomic, strong) NSDictionary<NSString*,QVPackage*> *packageMap; // <command id, package>

+ (instancetype)sharedManager;

- (BOOL)load;

@end

NS_ASSUME_NONNULL_END
