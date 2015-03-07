//
//  MYRSignal.h
//  MyRemote
//
//  Created by KenichiroSato on 2014/10/26.
//  Copyright (c) 2014年 Kenichiro Sato. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <IRKit/IRKit.h>

@protocol Sendable <NSObject>

@required

- (void)operate;

@end

@interface MYRSignal : NSObject <Sendable>

@property (nonatomic, strong) IRSignal* signal;

@end

@interface MYRBatchSignals : NSObject <Sendable>

@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSArray *sendables;

@end
