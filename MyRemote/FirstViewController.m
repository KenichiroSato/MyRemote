//
//  FirstViewController.m
//  MyRemote
//
//  Created by 佐藤健一朗 on 2014/09/27.
//  Copyright (c) 2014年 Kenichiro Sato. All rights reserved.
//

#import "FirstViewController.h"
#import <IRKit/IRKit.h>

@interface FirstViewController () <IRNewPeripheralViewControllerDelegate>

@end

@implementation FirstViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    // find IRKit if none is known
    if ([IRKit sharedInstance].countOfReadyPeripherals == 0) {
        
        //__weak WZMasterViewController *me = self;
        
        IRNewPeripheralViewController *vc = [[IRNewPeripheralViewController alloc] init];
        vc.delegate = self;
        [self presentViewController:vc
                           animated:YES
                         completion:^{
                             //[me startCapturing];
                             NSLog(@"complete!");
                         }];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - IRNewPeripheralViewControllerDelegate

- (void)newPeripheralViewController:(IRNewPeripheralViewController *)viewController
            didFinishWithPeripheral:(IRPeripheral *)peripheral
{
    NSLog( @"peripheral: %@", peripheral );
    [self dismissViewControllerAnimated:YES
                             completion:^{
                                 NSLog(@"dismissed");
                             }];
}


@end
