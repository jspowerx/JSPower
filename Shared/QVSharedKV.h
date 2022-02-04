//
//  QVSharedKV.h
//  JSPower
//
//  Created by everettjf on 2018/11/7.
//  Copyright © 2018 everettjf. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface QVSharedKV : NSObject

+ (instancetype)sharedKV;

- (void)setObject:(id)obj forKey:(NSString*)key;
- (id)objectForKey:(NSString*)key;

@end

NS_ASSUME_NONNULL_END
