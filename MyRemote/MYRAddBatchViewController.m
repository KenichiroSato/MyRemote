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
@property (weak, nonatomic) IBOutlet UITableView *batchTableView;
@property (weak, nonatomic) IBOutlet UIPickerView *signalPickerView;

@end

@implementation MYRAddBatchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.batchTableView.dataSource = self;
    self.batchTableView.delegate = self;
    self.signalPickerView.delegate = self;
    self.signalPickerView.dataSource = self;
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
    return @"new batch signals";
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.batchSignals.sendables.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}


#pragma mark - Picker View

// returns the number of 'columns' to display.
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

// returns the # of rows in each component..
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return [[[MYRSignalManager sharedManager] signals] count];
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    IRSignal *signal = [[MYRSignalManager sharedManager] signalAt:row];
    return signal.name;
}

- (IBAction)addSendable:(id)sender {
    NSInteger index = [self.signalPickerView selectedRowInComponent:0];
    IRSignal *signal = [[MYRSignalManager sharedManager] signalAt:index];
    MYRSignal *myrSignal= [[MYRSignal alloc] initWithSignal:signal];
    [self.batchSignals.sendables addObject:myrSignal];
    [self.batchTableView reloadData];
}

- (IBAction)closeKeyborad:(id)sender
{
    [self.textField resignFirstResponder];
}

- (IBAction)cancel:(id)sender {
    [[self parentViewController] dismissViewControllerAnimated:YES completion:nil];
}

@end
