//
//  SecondViewController.m
//  MyRemote
//
//  Created by KenichiroSato on 2014/09/27.
//  Copyright (c) 2014年 Kenichiro Sato. All rights reserved.
//

#import "MYRSignalListViewController.h"
#import "UIAlerView+Completion.h"
#import "MYRSignalManager.h"

#import <IRKit/IRHTTPClient.h>
#import <IRKit/IRKit.h>

@interface MYRSignalListViewController ()
{
    IRHTTPClient *_httpClient;
}
@end

@implementation MYRSignalListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
     self.navigationItem.rightBarButtonItem = self.editButtonItem;

    // Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self startCapturing];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)startCapturing
{
    if ([IRKit sharedInstance].countOfReadyPeripherals == 0) {
        return;
    }
    
    __weak MYRSignalListViewController *me = self;
    if (!_httpClient) {
        _httpClient = [IRHTTPClient waitForSignalWithCompletion:^(NSHTTPURLResponse *res, IRSignal *signal, NSError *error) {
            if (signal) {
                [me didReceiveSignal:signal];
            }
        }];
    }
}

- (void)didReceiveSignal:(IRSignal *)irSignal
{
    if (self.editing) {
        MYRSignal *signal = [[MYRSignal alloc] initWithSignal:irSignal];
        [[MYRSignalManager sharedManager] addSignal:signal at:0];
        [self showNameEditDialog:signal];
        NSLog( @"signal: %@", signal );
    }
    _httpClient = nil;
    [self startCapturing];
}

- (void)showNameEditDialog:(MYRSignal *)signal
{
    UIAlertView * alert = [[UIAlertView alloc]
                           initWithTitle:@"Name"
                           message:@"Please enter signal name:"
                           delegate:nil
                           cancelButtonTitle:@"Cancel"
                           otherButtonTitles:@"OK", nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    UITextField * alertTextField = [alert textFieldAtIndex:0];
    alertTextField.placeholder = @"Enter signal name";
    alertTextField.text = signal.name;
    
    [alert showWithCompletion:^(UIAlertView *alertView, NSInteger buttonIndex) {
        if (buttonIndex == 0) { //Cancel
            //[_signals removeObjectAtIndex:0];
        } else { //OK
            UITextField * alertTextField = [alertView textFieldAtIndex:0];
            signal.name = alertTextField.text;
            [self.tableView reloadData];
            [[MYRSignalManager sharedManager] saveSignals];
        }
    }];
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
    return [[[MYRSignalManager sharedManager] signals] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:CellIdentifier];
    }
    
    MYRSignal *signal = [[MYRSignalManager sharedManager] signalAt:indexPath.row];
    cell.textLabel.text = signal.name;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    MYRSignal *signal = [[MYRSignalManager sharedManager] signalAt:indexPath.row];
    if (self.editing) {
        [self showNameEditDialog:signal];
    } else {
        [signal operateWithCompletion:^(NSError *error) {
            if (error) {
                UIAlertView * alert = [[UIAlertView alloc]
                                       initWithTitle:@""
                                       message:[error description]
                                       delegate:nil
                                       cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
                [alert show];
            }
        }];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [[MYRSignalManager sharedManager] removeSignalAt:indexPath.row];
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

- (void)tableView:(UITableView *)tableView
moveRowAtIndexPath:(NSIndexPath *)fromIndexPath
      toIndexPath:(NSIndexPath *)toIndexPath
{
    if(fromIndexPath.section != toIndexPath.section) {
        return;
    }
    [[MYRSignalManager sharedManager] moveSignalFrom:fromIndexPath.row To:toIndexPath.row];
}

@end
