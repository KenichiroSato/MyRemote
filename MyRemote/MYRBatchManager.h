//
//  MYRBatchManager.h
//  MyRemote
//
//  Created by KenichiroSato on 2015/03/15.
//  Copyright (c) 2015年 Kenichiro Sato. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MYRSignal.h"

@interface MYRBatchManager : NSObject

@property (readonly, nonatomic) NSMutableArray *batches;

+ (id)sharedManager;
- (void)saveBatches;
- (void)loadBatches;
- (void)addBatch:(MYRBatchSignals *)batch at:(NSInteger)index;
- (void)removeBatchAt:(NSInteger)index;
- (void)moveBatchFrom:(NSInteger)from To:(NSInteger)to;
- (MYRBatchSignals *)batchAt:(NSInteger)index;

@end
