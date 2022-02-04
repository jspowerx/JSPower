//
//  QVPackageDownloader.h
//  JSPower
//
//  Created by everettjf on 2018/11/8.
//  Copyright © 2018 everettjf. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QVSharedPackageManager.h"


@class QVPackageDownloader;

@protocol QVPackageDownloaderDelegate <NSObject>

@required
- (void)qvPackageDownloaderStart:(QVPackageDownloader*)downloader;
- (void)qvPackageDownloader:(QVPackageDownloader*)downloader processing:(NSString*)info;
- (void)qvPackageDownloader:(QVPackageDownloader*)downloader completed:(NSString*)error;

@end

@interface QVPackageDownloader : NSObject

@property (nonatomic, strong) id<QVPackageDownloaderDelegate> delegate;

@property (nonatomic, copy) NSURL *packageURL;
@property (nonatomic, copy) NSURL *localURL;
@property (nonatomic, strong) QVSharedPackageManifestModel *manifest;

/*
 packageURL = https://jspowerx.github.io/packages/everettjf
 localDirectory = .../Packages/hashofeverettjf
*/
- (void)startDownloadPackage:(NSURL*)packageURL to:(NSURL*)localDirectory;

@end

