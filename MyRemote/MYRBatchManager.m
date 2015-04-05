//
//  MYRBatchManager.m
//  MyRemote
//
//  Created by SatoSato on 2015/03/15.
//  Copyright (c) 2015年 Kenichiro Sato. All rights reserved.
//

#import "MYRBatchManager.h"

static NSString * const USER_DEFAULT_KEY_BATCHES = @"batches";

@implementation MYRBatchManager

+ (id)sharedManager
{
    static id sManager;
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        sManager = [MYRBatchManager new];
    });
    return sManager;
}

- (id)init
{
    self = [super init];
    if (self) {
        [self loadBatches];
        if (!_batches) {
            _batches = [NSMutableArray array];
        }
    }
    return self;
}

- (void)saveBatches
{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [ud setObject:[NSKeyedArchiver archivedDataWithRootObject:_batches]
           forKey:USER_DEFAULT_KEY_BATCHES];
    [ud synchronize];
}

- (void)loadBatches
{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSData *data = [ud objectForKey:USER_DEFAULT_KEY_BATCHES];
    NSArray *retrievedArray = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    _batches = [retrievedArray mutableCopy];
}

- (void)addBatch:(MYRBatchSignals *)batch at:(NSInteger)index
{
    [_batches insertObject:batch atIndex:index];
    [self saveBatches];
}

- (void)removeBatchAt:(NSInteger)index
{
    [_batches removeObjectAtIndex:index];
    [self saveBatches];
}

- (void)moveBatchFrom:(NSInteger)from To:(NSInteger)to
{
    if (!_batches) {
        return;
    }
    if (from < 0 || from > _batches.count - 1 ||
        to < 0 || to > _batches.count - 1) {
        return;
    }
    id item = [_batches objectAtIndex:from];
    [_batches removeObject:item];
    [_batches insertObject:item atIndex:to];
    [self saveBatches];
}

- (MYRBatchSignals *)batchAt:(NSInteger)index
{
    if (![_batches count]) {
        return nil;
    }
    if (index < 0 || index > _batches.count -1) {
        return nil;
    }
    return _batches[index];
}

@end
