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
- (NSString *)name;

@end

@interface MYRSignal : NSObject <Sendable, NSCoding>
@property (nonatomic, strong) IRSignal* irSignal;
@property (strong, nonatomic) NSString *name;
- (id)initWithSignal:(IRSignal *)signal;
- (void)operateWithCompletion:(void (^)(NSError *error))completion;
@end

@interface MYRBatchSignals : NSObject <Sendable, NSCoding>
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSMutableArray *sendables;
@end

@interface MYRWait : NSObject <Sendable, NSCoding>
- (id)initWithWaitTime:(NSInteger)waitTime;
@property (nonatomic) NSInteger waitTime;
@end
