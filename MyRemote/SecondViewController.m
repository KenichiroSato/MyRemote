//
//  SecondViewController.m
//  MyRemote
//
//  Created by 佐藤健一朗 on 2014/09/27.
//  Copyright (c) 2014年 Kenichiro Sato. All rights reserved.
//

#import "SecondViewController.h"

#import <IRKit/IRHTTPClient.h>
#import <IRKit/IRKit.h>

@interface SecondViewController ()<UITableViewDelegate, UITableViewDataSource>
{
    NSMutableArray *_signals;
    IRHTTPClient *_httpClient;
}
@end

@implementation SecondViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _signals = [NSMutableArray array];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;

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
    
    UIAlertView * alert = [[UIAlertView alloc]
                           initWithTitle:@"Name"
                           message:@"Please enter the name:"
                           delegate:self
                           cancelButtonTitle:@"Cancel"
                           otherButtonTitles:@"OK", nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    UITextField * alertTextField = [alert textFieldAtIndex:0];
    alertTextField.placeholder = @"Enter your name";
    [alert show];
    
    NSLog( @"signal: %@", signal );
    
    _httpClient = nil;
    [self startCapturing];
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 0) {
        [_signals removeObjectAtIndex:0];
    } else {
        UITextField * alertTextField = [alertView textFieldAtIndex:0];
        IRSignal *signal = [_signals objectAtIndex:0];
        signal.name = alertTextField.text;
        [self.tableView reloadData];
    }
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
    IRSignal *signal =_signals[indexPath.row];
    [signal sendWithCompletion:^(NSError *error) {
            NSLog(@"sent error: %@", error);
        }];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70.0f;
}

@end
