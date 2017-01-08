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
    [self.view addSubview:textV];
    
    [MQTTService shareService].eventAction = ^(NSInteger event, NSString *str){
        if (textV.text.length) {
            textV.text = [NSString stringWithFormat:@"%@\n%@: %@", textV.text, [self getNotTime], str];
        } else {
            textV.text = [NSString stringWithFormat:@"%@: %@", [self getNotTime], str];
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

/**
 *  获取当前 时:分:秒.毫秒
 *
 *  @return 时:分:秒.毫秒
 */
- (NSString *)getNotTime {
    static NSDateFormatter *getNotTimeDateFormatter;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        getNotTimeDateFormatter = [[NSDateFormatter alloc] init];
        [getNotTimeDateFormatter setDateFormat:@"HH:mm:ss.SSS"];
    });
    
    return [getNotTimeDateFormatter stringFromDate:[NSDate date]];
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
