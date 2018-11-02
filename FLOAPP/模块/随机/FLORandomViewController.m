//
//  FLORandomViewController.m
//  FLOAPP
//
//  Created by 360doc on 2018/10/31.
//  Copyright © 2018 Flolangka. All rights reserved.
//

#import "FLORandomViewController.h"
#import "Random+CoreDataClass.h"
#import "FLORandomEditViewController.h"

@interface FLORandomViewController ()

@end

@implementation FLORandomViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = _randomModel.name;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(editAction:)];
    self.view.backgroundColor = [UIColor whiteColor];
}

#pragma mark - action
/**
 点击修改事件
 */
- (void)editAction:(id)sender {
    FLORandomEditViewController *editVC = [[FLORandomEditViewController alloc] init];
    editVC.editRandom = _randomModel;
    [self.navigationController pushViewController:editVC animated:YES];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
