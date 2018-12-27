//
//  QVPackageListController.h
//  Code Friend
//
//  Created by everettjf on 2018/11/7.
//  Copyright © 2018 everettjf. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>
#import "QVSharedPackageManager.h"

@class PackageListController;
@protocol PackageListControllerDelegate <NSObject>

- (void)packageListControllerSelectedPackageChanged:(PackageListController*)controller;

@end


@interface PackageListController : NSObject

@property (atomic, weak) id<PackageListControllerDelegate> delegate;

@property (atomic, strong) NSArray<QVSharedPackageModelInConfig*> *packages;
@property (atomic, strong) QVSharedPackageModelInConfig *selectedPackage;
@property (atomic, assign) NSUInteger selectedRow;

@property (weak) NSTableView *packageTableView;
@property (unsafe_unretained) NSTextView *contentTextView;

- (void)setup;

- (void)reload;

@end

