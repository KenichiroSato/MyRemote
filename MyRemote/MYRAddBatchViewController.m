//
//  MYRAddBatchViewController.m
//  MyRemote
//
//  Created by KenichiroSato on 2014/10/27.
//  Copyright (c) 2014年 Kenichiro Sato. All rights reserved.
//

#import "MYRAddBatchViewController.h"
#import "MYRSignalManager.h"
#import "MYRBatchManager.h"
#import "MYRSignal.h"

@interface MYRAddBatchViewController ()

@property (weak, nonatomic) IBOutlet UIBarButtonItem *doneButton;
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UITableView *signalTableView;
@property (weak, nonatomic) IBOutlet UITableView *batchTableView;

@end

@implementation MYRAddBatchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.signalTableView.dataSource = self;
    self.signalTableView.delegate = self;
    self.batchTableView.dataSource = self;
    self.batchTableView.delegate = self;
    self.batchSignals = [MYRBatchSignals new];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if (sender != self.doneButton) {
        NSLog(@"not addButton");
        return;
    }
    if (self.textField.text.length > 0) {
        self.batchSignals.name = self.textField.text;
        [[MYRBatchManager sharedManager] addBatch:self.batchSignals at:0];
    }
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (tableView == self.batchTableView) {
        return @"new batch signals";
    } else {
        return @"select signal you want to add";
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.batchTableView) {
        return self.batchSignals.sendables.count;
    } else {
        return [[[MYRSignalManager sharedManager] signals] count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.batchTableView) {
        return [self cellForBatchTableView:tableView indexPath:indexPath];
    } else {
        return [self cellForSignalTableView:tableView indelPath:indexPath];
    }
}

- (UITableViewCell *)cellForBatchTableView:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"batchCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    MYRSignal *signal = (MYRSignal *)[self.batchSignals.sendables objectAtIndex:indexPath.row];
    cell.textLabel.text = signal.name;
    return cell;
}

- (UITableViewCell *)cellForSignalTableView:(UITableView *)tableView indelPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"signalCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    IRSignal *signal = [[MYRSignalManager sharedManager] signalAt:indexPath.row];
    cell.textLabel.text = signal.name;
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.signalTableView) {
        IRSignal *signal = [[MYRSignalManager sharedManager] signalAt:indexPath.row];
        MYRSignal *myrSignal= [[MYRSignal alloc] initWithSignal:signal];
        [self.batchSignals.sendables addObject:myrSignal];
        [self.batchTableView reloadData];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

- (IBAction)closeKeyborad:(id)sender
{
    [self.textField resignFirstResponder];
}


@end
