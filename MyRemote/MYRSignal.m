//
//  MYRSignal.m
//  MyRemote
//
//  Created by KenichiroSato on 2014/10/26.
//  Copyright (c) 2014年 Kenichiro Sato. All rights reserved.
//

#import "MYRSignal.h"

@implementation MYRSignal

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

@end

@implementation MYRBatchSignals

- (id)init
{
    self = [super init];
    if (self != nil)
    {
        self.sendables = [NSMutableArray new];
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

