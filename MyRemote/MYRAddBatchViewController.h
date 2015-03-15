//
//  MYRAddBatchViewController.h
//  MyRemote
//
//  Created by KenichiroSato on 2014/10/27.
//  Copyright (c) 2014年 Kenichiro Sato. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MYRSignal.h"

@interface MYRAddBatchViewController : UIViewController
<
UITableViewDataSource,
UITableViewDelegate,
UIPickerViewDataSource,
UIPickerViewDelegate
>

@property MYRBatchSignals *batchSignals;

@end
