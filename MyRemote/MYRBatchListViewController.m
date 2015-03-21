//
//  FirstViewController.m
//  MyRemote
//
//  Created by Kenichiro Sato on 2014/09/27.
//  Copyright (c) 2014年 Kenichiro Sato. All rights reserved.
//

#import "MYRBatchListViewController.h"
#import "MYRAddBatchViewController.h"
#import <IRKit/IRKit.h>
#import "ESTBeaconManager.h"
#import "MYRSignalManager.h"
#import "MYRBatchManager.h"
#import "MYRSignal.h"

static NSString * const kInsideIdentifier = @"purple";
static NSString * const kOutsideIdentifier = @"blue";

static NSString * const kComeHomeName = @"帰宅";

@interface MYRBatchListViewController () <IRNewPeripheralViewControllerDelegate, ESTBeaconManagerDelegate>

@property (nonatomic, strong) ESTBeaconManager* beaconManager;

@end

@implementation MYRBatchListViewController
{
    BOOL _isSent;
    NSDate *_timeInside;
    NSDate *_timeOutside;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tableView reloadData];
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
        
        IRNewPeripheralViewController *vc = [[IRNewPeripheralViewController alloc] init];
        vc.delegate = self;
        [self presentViewController:vc
                           animated:YES
                         completion:^{
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
    return [[[MYRBatchManager sharedManager] batches] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    MYRBatchSignals *batch = [[[MYRBatchManager sharedManager] batches] objectAtIndex:indexPath.row];
    cell.textLabel.text = batch.name;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    MYRBatchSignals *batch= [[MYRBatchManager sharedManager] batchAt:indexPath.row];
    if (self.editing) {
        [self showEditBatchSignal:batch];
    } else {
        [batch operate];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

- (void)showEditBatchSignal:(MYRBatchSignals *)signals
{
    [self performSegueWithIdentifier:kEditBatchSegueIdentifier sender:self];
    /*
     MYRAddBatchViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"MYRAdd"];
    controller.batchSignals = signals;
    [self.navigationController presentViewController:controller
                                            animated:YES
                                          completion:nil];
     */
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
        for (MYRBatchSignals *batch in [[MYRBatchManager sharedManager] batches]) {
            if ([batch.name isEqualToString:kComeHomeName]) {
                [batch operate];
                return;
            }
        }
    }
}

- (void)updateDate:(ESTBeaconRegion *)region
{
    if ([region.identifier isEqualToString:kInsideIdentifier]) {
        _timeInside = [NSDate date];
    }
    if ([region.identifier isEqualToString:kOutsideIdentifier]) {
        _timeOutside = [NSDate date];
        _isSent = false;
    }
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    notification.alertBody = [@"enter retion! %@" stringByAppendingString:region.identifier];
    notification.soundName = UILocalNotificationDefaultSoundName;
    [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
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
    //[self.beaconManager stopRangingBeaconsInRegion:self.beaconRegion];
}

- (IBAction)mainViewReturnActionForSegue:(UIStoryboardSegue *)segue
{
    [self.tableView reloadData];
}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [[MYRBatchManager sharedManager] removeBatchAt:indexPath.row];
        [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // leave here empty for now.
    }
}

// move
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
    if(fromIndexPath.section != toIndexPath.section) {
        return;
    }
    [[MYRBatchManager sharedManager] moveBatchFrom:fromIndexPath.row To:toIndexPath.row];
}

#pragma mark - Segue
static NSString * const kEditBatchSegueIdentifier = @"editBatch";

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:kEditBatchSegueIdentifier]) {
        MYRAddBatchViewController *controller = segue.destinationViewController;
        NSInteger selectedIndex = [self.tableView indexPathForSelectedRow].row;
        MYRBatchSignals *selected = [[MYRBatchManager sharedManager] batchAt:selectedIndex];
        controller.batchSignals = selected;
    }
}

@end
