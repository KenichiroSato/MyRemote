//
//  FirstViewController.m
//  MyRemote
//
//  Created by 佐藤健一朗 on 2014/09/27.
//  Copyright (c) 2014年 Kenichiro Sato. All rights reserved.
//

#import "FirstViewController.h"
#import <IRKit/IRKit.h>
#import "ESTBeaconManager.h"
#import "MYRSignalManager.h"

@interface FirstViewController () <IRNewPeripheralViewControllerDelegate, ESTBeaconManagerDelegate>

@property (nonatomic, strong) ESTBeaconManager* beaconManager;
@property (nonatomic, strong) ESTBeaconRegion* beaconRegion;

@end

@implementation FirstViewController
{
    BOOL _isSent;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    _isSent = false;
    
    self.beaconManager = [[ESTBeaconManager alloc] init];
    self.beaconManager.delegate = self;

    self.beaconRegion = [[ESTBeaconRegion alloc] initWithProximityUUID:ESTIMOTE_IOSBEACON_PROXIMITY_UUID identifier:@"8492E75F-4FD6-469D-B132-043FE94921D8"];
    self.beaconRegion.notifyOnEntry = YES;
    self.beaconRegion.notifyOnExit = YES;
    
    
    [self.beaconManager startMonitoringForRegion:self.beaconRegion];
    [self.beaconManager requestStateForRegion:self.beaconRegion];

    // Do any additional setup after loading the view, typically from a nib.
    if ([ESTBeaconManager authorizationStatus] == kCLAuthorizationStatusNotDetermined)
    {
        /*
         * Request permission to use Location Services. (new in iOS 8)
         * We ask for "always" authorization so that the Notification Demo can benefit as well.
         * Also requires NSLocationAlwaysUsageDescription in Info.plist file.
         *
         * For more details about the new Location Services authorization model refer to:
         * https://community.estimote.com/hc/en-us/articles/203393036-Estimote-SDK-and-iOS-8-Location-Services
         */
        [self.beaconManager requestAlwaysAuthorization];
    }
    if ([UIApplication instancesRespondToSelector:@selector(registerUserNotificationSettings:)]) {
        [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert|UIUserNotificationTypeSound categories:nil]];
    }
    
    
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

-(void)beaconManager:(ESTBeaconManager *)manager didDetermineState:(CLRegionState)state forRegion:(ESTBeaconRegion *)region
{
    if (state == CLRegionStateInside) {
        NSLog(@"inside now.");
        [self.beaconManager startRangingBeaconsInRegion:self.beaconRegion];
    } else if (state == CLRegionStateOutside){
        NSLog(@"outside now.");
    }
}

- (void)beaconManager:(ESTBeaconManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(ESTBeaconRegion *)region
{
    if (!beacons.count) {
        return;
    }
    ESTBeacon *beacon = [beacons objectAtIndex:0];
    
    switch (beacon.proximity) {
        case CLProximityFar:
            NSLog(@"Far");
            break;
        case CLProximityNear:
            NSLog(@"Near");
            break;
        case CLProximityImmediate:
            NSLog(@"Immediate");
            if (!_isSent) {
                _isSent = true;
                UILocalNotification *notification = [[UILocalNotification alloc] init];
                notification.alertBody = @"distance is Immediate!";
                notification.soundName = UILocalNotificationDefaultSoundName;
                [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
                
                [self sendSignalAt:0];
                [self sendSignalAt:1];
            }
            break;
        case CLProximityUnknown:
            NSLog(@"Unknown");
            break;
    }
}

-(void)sendSignalAt:(NSInteger)index
{
    IRSignal *signal = [[MYRSignalManager sharedManager] signalAt:index];
    [signal sendWithCompletion:^(NSError *error) {
        if (error) {
            UIAlertView * alert = [[UIAlertView alloc]
                                   initWithTitle:@""
                                   message:[error description]
                                   delegate:nil
                                   cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
            [alert show];
            _isSent = false;
        } else {
            NSLog(@"sent!!");
            
        }
    }];
}


-(void)beaconManager:(ESTBeaconManager *)manager didEnterRegion:(ESTBeaconRegion *)region
{
    NSLog(@"enter!!!");
    [self.beaconManager startRangingBeaconsInRegion:self.beaconRegion];
}

-(void)beaconManager:(ESTBeaconManager *)manager didExitRegion:(ESTBeaconRegion *)region
{
     NSLog(@"exit!!!");
    [self.beaconManager stopRangingBeaconsInRegion:self.beaconRegion];
}


@end
