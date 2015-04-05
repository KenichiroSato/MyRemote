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

@property (weak, nonatomic) IBOutlet UITableView *batchTableView;

@end

@implementation RemoteExtensionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.batchTableView.dataSource = self;
    self.batchTableView.delegate = self;
    self.preferredContentSize = CGSizeMake(0, 200);
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

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

/*
- (NSString *)tableView:(UITableView *)tableView
titleForHeaderInSection:(NSInteger)section
{
    return @"new batch signals";
}
 */

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
    return 3;
    //return self.batchSignals.sendables.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"batchCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:CellIdentifier];
    }
    cell.textLabel.text = @"test";
    cell.textLabel.textColor = [UIColor whiteColor];
    MYRSignal *signal = (MYRSignal *)[self.batchSignals.sendables objectAtIndex:indexPath.row];
    cell.textLabel.text = signal.name;

 return cell;

 }

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}


@end
