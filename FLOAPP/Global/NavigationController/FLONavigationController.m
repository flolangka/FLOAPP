//
//  FLONavigationController.m
//  XMPPChat
//
//  Created by admin on 15/11/25.
//  Copyright © 2015年 Flolangka. All rights reserved.
//

#import "FLONavigationController.h"

@interface FLONavigationController ()

@end

@implementation FLONavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationBar.barStyle = UIBarStyleDefault;
    self.navigationBar.tintColor = [UIColor blackColor];  //文字图标颜色
//    self.navigationBar.barTintColor = [UIColor colorWithRed:15/255.0 green:191/255.0 blue:235/255.0 alpha:1.0];  //导航栏背景
    self.navigationBar.translucent = NO;
    self.navigationBar.titleTextAttributes = @{NSFontAttributeName: [UIFont systemFontOfSize:22.0]};
    if (@available(iOS 11.0, *)) {
        //self.navigationBar.prefersLargeTitles = YES;
    } else {
        // Fallback on earlier versions
    }
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
