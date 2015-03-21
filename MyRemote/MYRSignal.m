//
//  MYRSignal.m
//  MyRemote
//
//  Created by KenichiroSato on 2014/10/26.
//  Copyright (c) 2014年 Kenichiro Sato. All rights reserved.
//

#import "MYRSignal.h"

@implementation MYRSignal

static NSString *const key_signal = @"signal";
static NSString *const key_name = @"name";

- (id)initWithSignal:(IRSignal *)irSignal
{
    self = [super init];
    if (self != nil)
    {
        self.irSignal = irSignal;
    }
    return self;
}


- (void)operate
{
    [self.irSignal sendWithCompletion:^(NSError *error) {
        if (error) {
            UIAlertView * alert = [[UIAlertView alloc]
                                   initWithTitle:@""
                                   message:[error description]
                                   delegate:nil
                                   cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
            [alert show];
        }
    }];
}

- (void)operateWithCompletion:(void (^)(NSError *error))completion;
{
    [self.irSignal sendWithCompletion:completion];
}


- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:_irSignal forKey:key_signal];
    [aCoder encodeObject:_name forKey:key_name];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self){
        _irSignal = [aDecoder decodeObjectForKey:key_signal];
        _name = [aDecoder decodeObjectForKey:key_name];
    }
    return self;
}

@end

@implementation MYRBatchSignals

static NSString *const key_sendables = @"sendables";

- (id)init
{
    self = [super init];
    if (self != nil)
    {
        self.sendables = [NSMutableArray new];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:_name forKey:key_name];
    [aCoder encodeObject:_sendables forKey:key_sendables];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self){
        _name = [aDecoder decodeObjectForKey:key_name];
        _sendables = [aDecoder decodeObjectForKey:key_sendables];
    }
    return self;
}

- (void)operate
{
    for (id<Sendable> sendable in _sendables) {
        [sendable operate];
    }
}

@end


@implementation MYRWait

static NSString *const key_wait_time = @"wait_time";

- (id)initWithWaitTime:(NSInteger)waitTime
{
    self = [super init];
    if (self != nil)
    {
        self.waitTime = waitTime;
    }
    return self;
}

- (void)operate
{
    [NSThread sleepForTimeInterval:self.waitTime];
}

- (NSString *)name
{
    return [NSString stringWithFormat:@"%ld秒ウェイト", (long)self.waitTime];
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeInteger:_waitTime forKey:key_wait_time];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self){
        _waitTime = [aDecoder decodeIntegerForKey:key_wait_time];
    }
    return self;
}


@end


