//
//  QVSharedKV.m
//  JSPower
//
//  Created by everettjf on 2018/11/7.
//  Copyright © 2018 everettjf. All rights reserved.
//

#import "QVSharedKV.h"
#import "QVSharedHeader.h"

@interface QVSharedKV ()
@property (nonatomic, strong) NSUserDefaults *conf;
@end

@implementation QVSharedKV

+ (instancetype)sharedKV
{
    static QVSharedKV * obj;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        obj = [[QVSharedKV alloc] init];
    });
    return obj;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        NSString *groupId = [NSString stringWithUTF8String:kAppGroupIdentifier];
        _conf = [[NSUserDefaults alloc] initWithSuiteName:groupId];
    }
    return self;
}

- (void)setObject:(id)obj forKey:(NSString*)key
{
    [self.conf setObject:obj forKey:key];
}
- (id)objectForKey:(NSString*)key
{
    return [self.conf objectForKey:key];
}

@end
