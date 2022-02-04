//
//  AddPackageLogic.h
//  JSPower
//
//  Created by everettjf on 2018/11/10.
//  Copyright © 2018 everettjf. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QVPackageDownloader.h"

NS_ASSUME_NONNULL_BEGIN

@class AddPackageLogic;
@protocol AddPackageLogicDelegate <NSObject>

- (void)addPackageLogicSucceed:(AddPackageLogic*)logic;
- (void)addPackageLogic:(AddPackageLogic*)logic error:(NSString*)error;
- (void)addPackageLogic:(AddPackageLogic*)logic info:(NSString*)info;

@end

@interface AddPackageLogic : NSObject <QVPackageDownloaderDelegate>

@property (nonatomic,weak) id<AddPackageLogicDelegate> delegate;

@property (nonatomic,strong) QVPackageDownloader *downloader;

@property (nonatomic,copy) NSURL *addingPackageUrl;
@property (nonatomic,copy) NSString *addingPackageDirectoryName;

- (void)startAddPackage:(NSString*)packageUrlString;

@end

NS_ASSUME_NONNULL_END
