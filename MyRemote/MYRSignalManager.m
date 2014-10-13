//
//  MYRSignalManager.m
//  MyRemote
//
//  Created by 佐藤健一朗 on 2014/10/13.
//  Copyright (c) 2014年 Kenichiro Sato. All rights reserved.
//

#import "MYRSignalManager.h"

static NSString * const USER_DEFAULT_KEY_SIGNALS = @"signals";

@implementation MYRSignalManager

+ (id)sharedManager
{
    static id sManager;
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        sManager = [MYRSignalManager new];
    });
    return sManager;
}

- (id)init
{
    self = [super init];
    if (self) {
        [self loadSignals];
        if (!_signals) {
            _signals = [NSMutableArray array];
        }
    }
    return self;
}

- (void)saveSignals
{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [ud setObject:[NSKeyedArchiver archivedDataWithRootObject:_signals] forKey:USER_DEFAULT_KEY_SIGNALS];
    [ud synchronize];
}

- (void)loadSignals
{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSData *data = [ud objectForKey:USER_DEFAULT_KEY_SIGNALS];
    NSArray *retrievedArray = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    _signals = [retrievedArray mutableCopy];
}

- (void)addSignal:(IRSignal *)signal at:(NSInteger)index
{
    [_signals insertObject:signal atIndex:index];
    [self saveSignals];
}

- (void)removeSignalAt:(NSInteger)index
{
    [_signals removeObjectAtIndex:index];
    [self saveSignals];
}

- (void)moveSignalFrom:(NSInteger)from To:(NSInteger)to
{
    if (!_signals) {
        return;
    }
    if (from < 0 || from > _signals.count - 1 ||
        to < 0 || to > _signals.count - 1) {
        return;
    }
    id item = [_signals objectAtIndex:from];
    [_signals removeObject:item];
    [_signals insertObject:item atIndex:to];
    [self saveSignals];
}

- (IRSignal *)signalAt:(NSInteger)index
{
    if (index < 0 || index > _signals.count -1) {
        return nil;
    }
    return _signals[index];
}

@end
