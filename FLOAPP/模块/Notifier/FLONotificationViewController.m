//
//  FLONotificationViewController.m
//  FLOAPP
//
//  Created by 360doc on 2017/2/9.
//  Copyright © 2017年 Flolangka. All rights reserved.
//

#import "FLONotificationViewController.h"

#import <UserNotifications/UserNotifications.h>

@interface FLONotificationViewController ()

@end

@implementation FLONotificationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    [[UIApplication sharedApplication].delegate performSelector:@selector(registerNotifer)];
#pragma clang diagnostic pop
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)LocalPushArticle:(NSInteger)artID Title:(NSString *)title desc:(NSString *)desc {
    UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
    content.userInfo = @{@"url":@"http://www.360doc.com/content/17/0208/00/32773547_627529509.shtml"};
    content.sound = [UNNotificationSound defaultSound];
    content.title = title;
    content.body = desc;
    content.categoryIdentifier = @"myNotificationCategory";
    
    // 延时不能为0，会崩溃
    UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:@"123" content:content trigger:[UNTimeIntervalNotificationTrigger triggerWithTimeInterval:5 repeats:NO]];
    [[UNUserNotificationCenter currentNotificationCenter] addNotificationRequest:request withCompletionHandler:nil];
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
