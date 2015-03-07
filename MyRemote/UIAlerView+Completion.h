//
//  UIAlerView+Completion.h
//  MyRemote
//
//  Created by KenichiroSato on 2014/09/28.
//  Copyright (c) 2014年 Kenichiro Sato. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface UIAlertView (Completion)

- (void)showWithCompletion:(void(^)(UIAlertView *alertView, NSInteger buttonIndex))completion;

@end
