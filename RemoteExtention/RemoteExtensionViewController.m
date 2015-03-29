//
//  TodayViewController.m
//  RemoteExtention
//
//  Created by 佐藤健一朗 on 2015/03/29.
//  Copyright (c) 2015年 Kenichiro Sato. All rights reserved.
//

#import "RemoteExtensionViewController.h"
#import <NotificationCenter/NotificationCenter.h>

@interface RemoteExtensionViewController () <NCWidgetProviding>

@end

@implementation RemoteExtensionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)widgetPerformUpdateWithCompletionHandler:(void (^)(NCUpdateResult))completionHandler {
    // Perform any setup necessary in order to update the view.
    
    // If an error is encountered, use NCUpdateResultFailed
    // If there's no update required, use NCUpdateResultNoData
    // If there's an update, use NCUpdateResultNewData

    completionHandler(NCUpdateResultNewData);
}

@end
