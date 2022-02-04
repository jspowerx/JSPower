//
//  QVPackageDownloader.m
//  JSPower
//
//  Created by everettjf on 2018/11/8.
//  Copyright © 2018 everettjf. All rights reserved.
//

#import "QVPackageDownloader.h"
#import <AFNetworking.h>
#import "QVSharedUtil.h"
#import "QVSharedSandbox.h"
#import <YYModel.h>

@interface QVPackageDownloader ()
@property (nonatomic, strong) dispatch_queue_t queue;

@end

@implementation QVPackageDownloader

- (instancetype)init
{
    self = [super init];
    if (self) {
        _queue = dispatch_queue_create("com.everettjf.codefriend.download", DISPATCH_QUEUE_CONCURRENT);
    }
    return self;
}
- (void)startDownloadPackage:(NSURL*)packageURL to:(NSURL*)localDirectory
{
    self.packageURL = packageURL;
    self.localURL = localDirectory;
    
    NSURL *manifestUrl = [packageURL URLByAppendingPathComponent:@"manifest.json"];
    NSURL *manifestLocalPath = [localDirectory URLByAppendingPathComponent:@"manifest.json"];
    
    [self onStart];
    
    __weak typeof(self) ws = self;
    [self download:manifestUrl to:manifestLocalPath completion:^(NSURL *filePath, NSError *error) {
        if(error){
            [self onError:[NSString stringWithFormat:@"Failed to download : %@ , error :%@",manifestUrl, error]];
            return;
        }
        
        [ws onProcessing:[NSString stringWithFormat:@"Succeed download %@", manifestUrl]];
        
        [ws parseManifest:manifestUrl];
    }];
}

- (void)parseManifest:(NSURL*)manifestFilePath
{
    NSString *json = [NSString stringWithContentsOfURL:manifestFilePath encoding:NSUTF8StringEncoding error:nil];
    if(!json){
        [self onError:[NSString stringWithFormat:@"Failed to read : %@", manifestFilePath]];
        return;
    }
    
    self.manifest = [QVSharedPackageManifestModel yy_modelWithJSON:json];
    if(!self.manifest){
        [self onError:[NSString stringWithFormat:@"Failed to parse : %@", manifestFilePath]];
        return;
    }
    
    NSString *error = nil;
    if(![self checkManifestJson:self.manifest error:&error]){
        [self onError:error];
        return;
    }
    
    [self onProcessing:@"Parsing menu"];
    
    [self downloadManifestMenuItems:self.manifest];
    
}

- (void)downloadManifestMenuItems:(QVSharedPackageManifestModel*)model
{
    NSArray *menuItems = model.menu;
    if(menuItems.count == 0){
        [self onError:@"No menu found"];
        return;
    }
    for(QVSharedPackageManifestMenuItemuModel *menu in menuItems){
        NSString *identifier = menu.identifier;
        NSString *name = menu.name;
        identifier = [identifier stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        name = [name stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        if(identifier.length == 0){
            [self onError:@"No valid menu id found"];
            return;
        }
        if(name.length == 0){
            [self onError:@"No valid menu name found"];
            return;
        }
    }
    
    [self onProcessing:@"Downloading menu items"];
    
    NSMutableArray *menuDirectoryNames = [[NSMutableArray alloc] init];
    for(QVSharedPackageManifestMenuItemuModel *menu in menuItems){
        NSString *identifier = menu.identifier;
        NSString *menuDirectoryName = identifier;
        NSArray *parts = [identifier componentsSeparatedByString:@"."];
        if(parts.count > 0){
            menuDirectoryName = parts[0];
        }
        [menuDirectoryNames addObject:menuDirectoryName];
    }

    NSMutableArray<NSString*> *errors = [[NSMutableArray alloc]init];
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    
    for(NSString *menuDirectoryName in menuDirectoryNames){
        
        [self onProcessing:[NSString stringWithFormat:@"Downloading menu %@",menuDirectoryName]];
        
        [self downloadMenu:menuDirectoryName callback:^(NSString *error) {
            if(error){
                [errors addObject:error];
            }
            
            dispatch_semaphore_signal(semaphore);
        }];
    }
    
    for(NSUInteger idx = 0; idx < menuItems.count; ++idx){
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    }
    
    if(errors.count > 0){
        [self onError:errors.firstObject];
    } else {
        [self onSucceed];
    }
}

- (void)downloadMenu:(NSString*)menuDirectoryName callback:(void(^)(NSString *error))callback
{
    NSURL *menuUrl = [self.packageURL URLByAppendingPathComponent:menuDirectoryName];
    // create menu directory
    NSURL *menuLocalDirectory = [self.localURL URLByAppendingPathComponent:menuDirectoryName];
    if(![[NSFileManager defaultManager]createDirectoryAtURL:menuLocalDirectory withIntermediateDirectories:YES attributes:nil error:nil]){
        callback([NSString stringWithFormat:@"Failed to create menu directory : %@",menuLocalDirectory]);
        return;
    }
    
    NSURL *entryUrl = [menuUrl URLByAppendingPathComponent:@"entry.js"];
    NSURL *entryLocalPath = [menuLocalDirectory URLByAppendingPathComponent:@"entry.js"];
    
    [self onProcessing:[NSString stringWithFormat:@"Downloading menu entry %@",entryUrl]];
    
    __weak typeof(self) ws = self;
    [self download:entryUrl to:entryLocalPath completion:^(NSURL *filePath, NSError *error) {
        if(error){
            [self onError:[NSString stringWithFormat:@"Failed to download : %@ , error :%@",entryUrl, error]];
            return;
        }
        
        [ws onProcessing:[NSString stringWithFormat:@"Succeed download menu entry %@", entryUrl]];
        
        [ws parseEntry:entryLocalPath menuUrl:menuUrl menuLocalDirectory:menuLocalDirectory callback:^(NSString *error) {
            callback(error);
        }];
    }];
}


- (void)parseEntry:(NSURL*)filePath menuUrl:(NSURL*)menuUrl menuLocalDirectory:(NSURL*)menuLocalDirectory callback:(void(^)(NSString *error))callback
{
    QVSharedSandbox *sandbox = [[QVSharedSandbox alloc] init];
    if(![sandbox loadFile:filePath]){
        callback([NSString stringWithFormat:@"Failed to load js : %@",filePath]);
        return;
    }
    
    NSArray *fileNames = [sandbox readArray:@"entry"];
    
    if(fileNames.count == 0){
        callback([NSString stringWithFormat:@"No entry in file : %@",filePath]);
        return;
    }
    
    NSMutableArray<NSError*> *errors = [[NSMutableArray alloc]init];
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    
    for(NSString *fileName in fileNames){
        NSURL *fileUrl = [menuUrl URLByAppendingPathComponent:fileName];
        NSURL *localUrl = [menuLocalDirectory URLByAppendingPathComponent:fileName];
        
        [self onProcessing:[NSString stringWithFormat:@"Downloading file %@",fileUrl]];

        [self download:fileUrl to:localUrl completion:^(NSURL *filePath, NSError *error) {
            if(error){
                [errors addObject:error];
            }
            [self onProcessing:[NSString stringWithFormat:@"Succeed download file %@",fileUrl]];

            dispatch_semaphore_signal(semaphore);
        }];
    }
    
    for(NSUInteger idx = 0; idx < fileNames.count; ++idx){
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    }
        
    if(errors.count > 0){
        NSString *errorInfo = [NSString stringWithFormat:@"%@",errors.firstObject];
        callback(errorInfo);
    } else {
        callback(nil);
    }
}

- (BOOL)checkManifestJson:(QVSharedPackageManifestModel*)model error:(NSString**)error
{
    if(!model.name) { *error = @"Missing field : name"; return NO; }
    if(!model.version) { *error = @"Missing field : version"; return NO; }
    if(!model.author) { *error = @"Missing field : author"; return NO; }
    if(!model.website) { *error = @"Missing field : website"; return NO; }
    if(!model.desc) { *error = @"Missing field : description"; return NO; }
    if(!model.menu) { *error = @"Missing field : menu"; return NO; }
    return YES;
}

- (void)onStart
{
    [QVSharedUtil mainThreadCall:^{
        [self.delegate qvPackageDownloaderStart:self];
    }];
}

- (void)onError:(NSString*)error
{
    [QVSharedUtil mainThreadCall:^{
        [self.delegate qvPackageDownloader:self completed:error];
    }];
}

- (void)onSucceed
{
    [QVSharedUtil mainThreadCall:^{
        [self.delegate qvPackageDownloader:self completed:nil];
    }];
}
- (void)onProcessing:(NSString*)info
{
    [QVSharedUtil mainThreadCall:^{
        [self.delegate qvPackageDownloader:self processing:info];
    }];
}

- (void)download:(NSURL *)url to:(NSURL*)localPath completion:(void (^)(NSURL *filePath,NSError *error))completion {
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    NSURLSessionDownloadTask *downloadTask = [manager downloadTaskWithRequest:request progress:nil destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
        return localPath;
    } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
        dispatch_async(self.queue, ^{
            completion(filePath, error);
        });
    }];
    [downloadTask resume];
}

@end
