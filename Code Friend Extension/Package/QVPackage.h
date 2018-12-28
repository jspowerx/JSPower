//
//  QVPackage.h
//  ToolBox
//
//  Created by everettjf on 2018/11/2.
//  Copyright © 2018 everettjf. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface QVMenu : NSObject

@property (nonatomic, copy) NSString *identifier;
@property (nonatomic, copy) NSString *name;

@property (nonatomic, copy) NSURL *path;
@property (nonatomic, copy) NSURL *entryPath;
@property (nonatomic, copy) NSString *globalIdentifier;

@end

@interface QVPackage : NSObject

@property (nonatomic, copy) NSURL *path;
@property (nonatomic, copy) NSURL *manifestPath;
@property (nonatomic, copy) NSString *group;

@property (nonatomic, strong) NSArray<QVMenu *> *menuItems;
@property (nonatomic, strong) NSDictionary<NSString *,QVMenu *> *menuMap; // <global identifier , menu>

+ (QVPackage*)loadPackageFromPath:(NSURL *)path group:(NSString*)group;

@end

NS_ASSUME_NONNULL_END
