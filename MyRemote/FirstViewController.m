//
//  FirstViewController.m
//  MyRemote
//
//  Created by Kenichiro Sato on 2014/09/27.
//  Copyright (c) 2014年 Kenichiro Sato. All rights reserved.
//

#import "FirstViewController.h"
#import <IRKit/IRKit.h>
#import "ESTBeaconManager.h"
#import "MYRSignalManager.h"
#import "MYRSignal.h"
//#import "MYRAddBatchViewController.h"

static NSString * const kInsideIdentifier = @"purple";
static NSString * const kOutsideIdentifier = @"blue";

@interface FirstViewController () <IRNewPeripheralViewControllerDelegate, ESTBeaconManagerDelegate>

@property (nonatomic, strong) ESTBeaconManager* beaconManager;

@end

@implementation FirstViewController
{
    BOOL _isSent;
    NSMutableArray *_batches;
    NSDate *_timeInside;
    NSDate *_timeOutside;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    _batches = [[NSMutableArray alloc] init];
    _isSent = true;
    MYRBatchSignals *signal = [[MYRBatchSignals alloc] init];
    signal.name = @"initial purple";
    [_batches addObject:signal];
    MYRBatchSignals *signal2 = [[MYRBatchSignals alloc] init];
    signal2.name = @"initial blue";
    [_batches addObject:signal2];

}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    self.beaconManager = [[ESTBeaconManager alloc] init];
    self.beaconManager.delegate = self;

    ESTBeaconRegion* region1 = [[ESTBeaconRegion alloc] initWithProximityUUID:ESTIMOTE_PROXIMITY_UUID
                                                                        major:37959
                                                                        minor:20361
                                                                   identifier:kInsideIdentifier];
    region1.notifyOnEntry = YES;
    region1.notifyOnExit = YES;
    [self.beaconManager startMonitoringForRegion:region1];
    ESTBeaconRegion* region2 = [[ESTBeaconRegion alloc] initWithProximityUUID:ESTIMOTE_PROXIMITY_UUID
                                                                        major:12045
                                                                        minor:3311
                                                                   identifier:kOutsideIdentifier];
    region2.notifyOnEntry = YES;
    region2.notifyOnExit = YES;
    [self.beaconManager startMonitoringForRegion:region2];
    
    //[self.beaconManager requestStateForRegion:self.beaconRegion];

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


#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_batches count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    MYRBatchSignals *batch = [_batches objectAtIndex:indexPath.row];
    cell.textLabel.text = batch.name;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
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
        NSLog(@"inside now. %@", region.identifier);
        [self updateDate:region];
        //[self.beaconManager startRangingBeaconsInRegion:self.beaconRegion];
    } else if (state == CLRegionStateOutside){
        NSLog(@"outside now. %@", region.identifier);
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
            break;
        case CLProximityUnknown:
            NSLog(@"Unknown");
            break;
    }
}

-(void)sendComeHomeSignal
{
    if (!_isSent) {
        _isSent = true;
        [self sendSignalAt:0];
        [self sendSignalAt:1];
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

- (void)updateDate:(ESTBeaconRegion *)region
{
    if ([region.identifier isEqualToString:kInsideIdentifier]) {
        _timeInside = [NSDate date];
        [self updateTableCell:0 withTitle:[@"enter" stringByAppendingString:[_timeInside description]]];
    }
    if ([region.identifier isEqualToString:kOutsideIdentifier]) {
        _timeOutside = [NSDate date];
        [self updateTableCell:1 withTitle:[@"enter" stringByAppendingString:[_timeOutside description]]];
        _isSent = false;
    }
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    notification.alertBody = [@"enter retion! %@" stringByAppendingString:region.identifier];
    notification.soundName = UILocalNotificationDefaultSoundName;
    [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
}

- (void)updateTableCell:(NSInteger)index withTitle:(NSString *)title
{
    if (index < 0 || index > [_batches count] - 1) {
        return;
    }
    MYRBatchSignals *batch = [_batches objectAtIndex:index];
    batch.name = title;
    [self.tableView reloadData];
}

-(void)beaconManager:(ESTBeaconManager *)manager didEnterRegion:(ESTBeaconRegion *)region
{
    NSLog(@"enter!!! minor=%d, %@, %@", [region.minor unsignedIntValue], region.identifier, region.minor);
    [self updateDate:region];
    if (!_timeInside || !_timeOutside) {
        return;
    }
    NSComparisonResult result = [_timeInside compare:_timeOutside];
    if (result == NSOrderedDescending) {
        [self sendComeHomeSignal];
    }
    //[self.beaconManager startRangingBeaconsInRegion:self.beaconRegion];
}

-(void)beaconManager:(ESTBeaconManager *)manager didExitRegion:(ESTBeaconRegion *)region
{
     NSLog(@"exit!!!");
    if ([region.identifier isEqualToString:kInsideIdentifier]) {
        [self updateTableCell:0 withTitle:@"exit"];
    }
    if ([region.identifier isEqualToString:kOutsideIdentifier]) {
        [self updateTableCell:1 withTitle:@"exit"];
    }
    //[self.beaconManager stopRangingBeaconsInRegion:self.beaconRegion];
}

- (IBAction)mainViewReturnActionForSegue:(UIStoryboardSegue *)segue
{
}

@end
