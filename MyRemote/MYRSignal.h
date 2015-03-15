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

@interface MYRSignal : NSObject <Sendable, NSCoding>

@property (nonatomic, strong) IRSignal* signal;
- (id)initWithSignal:(IRSignal *)signal;
- (NSString *)name;
@end

@interface MYRBatchSignals : NSObject <Sendable, NSCoding>

@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSMutableArray *sendables;

@end
