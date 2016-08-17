//
//  FLOColorViewController.m
//  XMPPChat
//
//  Created by 沈敏 on 16/8/16.
//  Copyright © 2016年 Flolangka. All rights reserved.
//

#import "FLOColorViewController.h"
#import "FLOUtil.h"

@interface FLOColorViewController ()

@end

@implementation FLOColorViewController

- (instancetype)init {
    self = [super init];
    if (self) {
        self.title = @"UIColor";
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
