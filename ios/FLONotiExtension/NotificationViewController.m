//
//  NotificationViewController.m
//  FLONotiExtension
//
//  Created by 360doc on 2017/2/9.
//  Copyright © 2017年 Flolangka. All rights reserved.
//

#import "NotificationViewController.h"
#import <UserNotifications/UserNotifications.h>
#import <UserNotificationsUI/UserNotificationsUI.h>

#import <WebKit/WebKit.h>

@interface NotificationViewController () <UNNotificationContentExtension>

@end

@implementation NotificationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any required interface initialization here.
}

- (void)didReceiveNotification:(UNNotification *)notification {
    NSDictionary *userInfo = notification.request.content.userInfo;
    if (userInfo[@"WebUrl"]) {
        WKWebView *webV = [[WKWebView alloc] initWithFrame:self.view.bounds];
        [self.view addSubview:webV];
        [webV loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:userInfo[@"WebUrl"]]]];
    }
}

@end
