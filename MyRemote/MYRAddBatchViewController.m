//
//  MYRAddBatchViewController.m
//  MyRemote
//
//  Created by KenichiroSato on 2014/10/27.
//  Copyright (c) 2014年 Kenichiro Sato. All rights reserved.
//

#import "MYRAddBatchViewController.h"

@interface MYRAddBatchViewController ()

@property (weak, nonatomic) IBOutlet UIBarButtonItem *doneButton;
@property (weak, nonatomic) IBOutlet UITextField *textField;

@end

@implementation MYRAddBatchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
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
        self.batchSignals = [[MYRBatchSignals alloc] init];
        self.batchSignals.name = self.textField.text;
    }
}



@end
