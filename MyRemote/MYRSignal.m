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

- (id)initWithSignal:(IRSignal *)signal
{
    self = [super init];
    if (self != nil)
    {
        self.signal = signal;
    }
    return self;
}


- (void)operate
{
    [_signal sendWithCompletion:^(NSError *error) {
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

- (NSString *)name
{
    return self.signal.name;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:_signal forKey:key_signal];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self){
        _signal = [aDecoder decodeObjectForKey:key_signal];
    }
    return self;
}

@end

@implementation MYRBatchSignals

static NSString *const key_name = @"name";
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

