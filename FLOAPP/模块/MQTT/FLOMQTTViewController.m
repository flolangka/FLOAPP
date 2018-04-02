//
//  FLOMQTTViewController.m
//  FLOAPP
//
//  Created by 沈敏 on 2017/1/8.
//  Copyright © 2017年 Flolangka. All rights reserved.
//

#import "FLOMQTTViewController.h"
#import "MQTTService.h"

@interface FLOMQTTViewController ()

{
    UITextView *textV;
}

@end

@implementation FLOMQTTViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"MQTT";
    self.view.backgroundColor = [UIColor whiteColor];
    
    textV = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, DEVICE_SCREEN_WIDTH, DEVICE_SCREEN_HEIGHT-64)];
    textV.editable = NO;
    [self.view addSubview:textV];
    
    [MQTTService shareService].eventAction = ^(NSInteger event, NSString *str){
        if (textV.text.length) {
            textV.text = [NSString stringWithFormat:@"%@\n%@: %@", textV.text, [NSDate getNowTime], str];
        } else {
            textV.text = [NSString stringWithFormat:@"%@: %@", [NSDate getNowTime], str];
        }
        
    };
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [[MQTTService shareService] connectToServer];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [[MQTTService shareService] close];
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
