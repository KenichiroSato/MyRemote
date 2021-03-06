//
//  MYRSignalManager.h
//  MyRemote
//
//  Created by KenichiroSato on 2014/10/13.
//  Copyright (c) 2014年 Kenichiro Sato. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MYRSignal.h"

@interface MYRSignalManager : NSObject

@property (readonly, nonatomic) NSMutableArray *signals;

+ (id)sharedManager;
- (void)saveSignals;
- (void)loadSignals;
- (void)addSignal:(MYRSignal *)signal at:(NSInteger)index;
- (void)removeSignalAt:(NSInteger)index;
- (void)moveSignalFrom:(NSInteger)from To:(NSInteger)to;
- (MYRSignal *)signalAt:(NSInteger)index;

@end
