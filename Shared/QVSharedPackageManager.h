//
//  QVSharedPackageManager.h
//  JSPower
//
//  Created by everettjf on 2018/11/8.
//  Copyright © 2018 everettjf. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface QVSharedPackageManifestMenuItemuModel : NSObject
@property (nonatomic, copy) NSString *identifier;
@property (nonatomic, copy) NSString *name;
@end

@interface QVSharedPackageManifestModel : NSObject
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *version;
@property (nonatomic, copy) NSString *author;
@property (nonatomic, copy) NSString *website;
@property (nonatomic, copy) NSString *desc;
@property (nonatomic, strong) NSArray<QVSharedPackageManifestMenuItemuModel*> *menu;
@end


@interface QVSharedPackageModelInConfig : NSObject
@property (nonatomic, copy) NSURL *packageUrl;
@property (nonatomic, copy) NSString *directoryName;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *version;
@property (nonatomic, copy) NSString *author;
@property (nonatomic, copy) NSString *website;
@property (nonatomic, copy) NSString *desc;
@end

@interface QVSharedPackageConfig : NSObject

@property (nonatomic, copy) NSDate *updatedAt;
@property (nonatomic, strong) NSMutableArray<QVSharedPackageModelInConfig*> *packages;

@end

@interface QVSharedPackageManager : NSObject

@property (nonatomic, copy) NSURL *documentDir;
@property (nonatomic, copy) NSURL *packagesDir;
@property (nonatomic, copy) NSURL *packagesJsonPath;

+ (instancetype)sharedManager;

/**
 hash for the package url

 @param packageURL https url for package
 @return local name
 */
- (NSString*)getPackageName:(NSURL*)packageURL;

- (QVSharedPackageConfig*)readPackageConfig:(NSString**)error;
- (BOOL)addPackageToConfig:(QVSharedPackageModelInConfig*)package error:(NSString**)error;
- (BOOL)removePackage:(NSString*)directoryName error:(NSString**)error;

- (NSString*)readPackageManifestContent:(NSString*)directoryName;

@end

NS_ASSUME_NONNULL_END
