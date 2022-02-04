//
//  AddPackageLogic.m
//  JSPower
//
//  Created by everettjf on 2018/11/10.
//  Copyright © 2018 everettjf. All rights reserved.
//

#import "AddPackageLogic.h"
#import "QVSharedUtil.h"



@implementation AddPackageLogic

- (void)onError:(NSString*)error
{
    if(self.delegate){
        [self.delegate addPackageLogic:self error:error];
    }
}

- (void)onInfo:(NSString*)info
{
    if(self.delegate){
        [self.delegate addPackageLogic:self info:info];
    }
}

- (void)onSucceed
{
    if(self.delegate){
        [self.delegate addPackageLogicSucceed:self];
    }
}

- (void)startAddPackage:(NSString*)packageUrlString
{
    packageUrlString = [packageUrlString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if(packageUrlString.length == 0){
        [self onError:@"Empty package url"];
        return;
    }
    
    // ensure backslash is last letter
    if(![[packageUrlString substringFromIndex:packageUrlString.length-1] isEqualToString:@"/"]){
        packageUrlString = [packageUrlString stringByAppendingString:@"/"];
    }
    
    self.addingPackageUrl = [NSURL URLWithString:packageUrlString];
    if(!self.addingPackageUrl){
        [self onError:@"Not a valid url"];
        return;
    }
    self.addingPackageDirectoryName = [[QVSharedPackageManager sharedManager] getPackageName:self.addingPackageUrl];
    
    NSURL *localUrl = [[QVSharedPackageManager sharedManager].packagesDir URLByAppendingPathComponent:self.addingPackageDirectoryName];
    
    if([[NSFileManager defaultManager] fileExistsAtPath:[localUrl filePathString]]){
        [self onError:@"Package already exist"];
        return;
    }
    
    if(![[NSFileManager defaultManager] createDirectoryAtURL:localUrl withIntermediateDirectories:YES attributes:nil error:nil]){
        [self onError:[NSString stringWithFormat:@"Failed to create directory at %@",localUrl]];
        return;
    }
    
    self.downloader = [[QVPackageDownloader alloc]init];
    self.downloader.delegate = self;
    [self.downloader startDownloadPackage:self.addingPackageUrl to:localUrl];
    
}


- (void)qvPackageDownloaderStart:(QVPackageDownloader *)downloader
{
    [self onInfo:@"Start to download"];
}

- (void)qvPackageDownloader:(QVPackageDownloader *)downloader processing:(NSString *)info
{
    [self onInfo:info];
}

- (void)qvPackageDownloader:(QVPackageDownloader *)downloader completed:(NSString *)error
{
    if(error){
        [self onError:error];
        
        // clean
        [[NSFileManager defaultManager] removeItemAtURL:downloader.localURL error:nil];
        return;
    }
    
    [self onInfo:@"Succeed download package"];
    
    QVSharedPackageModelInConfig *modelInConfig = [[QVSharedPackageModelInConfig alloc] init];
    modelInConfig.packageUrl = self.addingPackageUrl;
    modelInConfig.directoryName = self.addingPackageDirectoryName;
    modelInConfig.name = downloader.manifest.name;
    modelInConfig.author = downloader.manifest.author;
    modelInConfig.website = downloader.manifest.website;
    modelInConfig.desc = downloader.manifest.desc;
    NSString *errorAdd = nil;
    if(![[QVSharedPackageManager sharedManager] addPackageToConfig:modelInConfig error:&errorAdd]){
        [self onError:errorAdd];
        
        // clean
        [[NSFileManager defaultManager] removeItemAtURL:downloader.localURL error:nil];
        
        return;
    }
    [self onInfo:@"All Succeed :) 😊"];
    [self onSucceed];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"index.package.reload" object:nil];
}
@end
