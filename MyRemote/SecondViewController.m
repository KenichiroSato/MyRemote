//
//  SecondViewController.m
//  MyRemote
//
//  Created by 佐藤健一朗 on 2014/09/27.
//  Copyright (c) 2014年 Kenichiro Sato. All rights reserved.
//

#import "SecondViewController.h"
#import "UIAlerView+Completion.h"

#import <IRKit/IRHTTPClient.h>
#import <IRKit/IRKit.h>

static NSString * const USER_DEFAULT_KEY_SIGNALS = @"signals";

@interface SecondViewController ()<UITableViewDelegate, UITableViewDataSource>
{
    NSMutableArray *_signals;
    IRHTTPClient *_httpClient;
}
@end

@implementation SecondViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadSignals];
    if (!_signals) {
        _signals = [NSMutableArray array];
    }
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
    
    __weak SecondViewController *me = self;
    if (!_httpClient) {
        _httpClient = [IRHTTPClient waitForSignalWithCompletion:^(NSHTTPURLResponse *res, IRSignal *signal, NSError *error) {
            if (signal) {
                [me didReceiveSignal:signal];
            }
        }];
    }
}

- (void)didReceiveSignal:(IRSignal *)signal
{
    //WZSignalLog *log = [[WZSignalLog alloc] initWithSignal:signal];
    [_signals insertObject:signal atIndex:0];
    [self showNameEditDialog:signal];
    NSLog( @"signal: %@", signal );
    
    _httpClient = nil;
    [self startCapturing];
}

- (void)showNameEditDialog:(IRSignal *)signal
{
    UIAlertView * alert = [[UIAlertView alloc]
                           initWithTitle:@"Name"
                           message:@"Please enter the name:"
                           delegate:nil
                           cancelButtonTitle:@"Cancel"
                           otherButtonTitles:@"OK", nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    UITextField * alertTextField = [alert textFieldAtIndex:0];
    alertTextField.placeholder = @"Enter your name";
    alertTextField.text = signal.name;
    [alert showWithCompletion:^(UIAlertView *alertView, NSInteger buttonIndex) {
        if (buttonIndex == 0) { //Cancel
            //[_signals removeObjectAtIndex:0];
        } else { //OK
            UITextField * alertTextField = [alertView textFieldAtIndex:0];
            signal.name = alertTextField.text;
            [self.tableView reloadData];
            [self saveSignals];
        }
    }];
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 0) { //Cancel
        [_signals removeObjectAtIndex:0];
    } else { //OK
        UITextField * alertTextField = [alertView textFieldAtIndex:0];
        IRSignal *signal = [_signals objectAtIndex:0];
        signal.name = alertTextField.text;
        [self.tableView reloadData];
        [self saveSignals];
    }
}

- (void)saveSignals
{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [ud setObject:[NSKeyedArchiver archivedDataWithRootObject:_signals] forKey:USER_DEFAULT_KEY_SIGNALS];
    [ud synchronize];
}

- (void)loadSignals
{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSData *data = [ud objectForKey:USER_DEFAULT_KEY_SIGNALS];
    NSArray *retrievedArray = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    _signals = [retrievedArray mutableCopy];
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _signals.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    IRSignal *signal = _signals[indexPath.row];
    cell.textLabel.text = signal.name;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.editing) {
        [self showNameEditDialog:_signals[indexPath.row]];
    } else {
        IRSignal *signal =_signals[indexPath.row];
        [signal sendWithCompletion:^(NSError *error) {
            NSLog(@"sent error: %@", error);
        }];
    }
}

//移動スタイル　２メソッド実装
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
    if(fromIndexPath.section == toIndexPath.section) {
        // fromIndexPathは移動前のIndex
        // toIndexPathは移動後のIndex
    }
}

@end
