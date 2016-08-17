//
//  AppDelegate.m
//  XMPPChat
//
//  Created by admin on 15/11/25.
//  Copyright © 2015年 Flolangka. All rights reserved.
//

#import "AppDelegate.h"
#import "FLOSideMenu.h"
#import "FLOCodeViewController.h"
#import <AFNetworkReachabilityManager.h>
#import <BaiduMapAPI_Base/BMKMapManager.h>
#import <BaiduMapAPI_Map/BMKMapView.h>
#import "FLOUtil.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [self networkMonitor];
    
    //注册百度地图
    BMKMapManager *bdManager = [[BMKMapManager alloc]init];
    [bdManager start:@"ZbXFn3fQqGNxn3TYmtqRhUUB" generalDelegate:nil];
    
    return YES;
}

#pragma mark 网络状态监听
- (void)networkMonitor
{
    AFNetworkReachabilityManager *networkManager = [AFNetworkReachabilityManager sharedManager];
    [networkManager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        if (status == AFNetworkReachabilityStatusNotReachable) {
            UIAlertView *alertV = [[UIAlertView alloc] initWithTitle:@"网络异常" message:@"请检查网络连接" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alertV show];
        }
    }];
    [networkManager startMonitoring];
}

//接收主屏幕图标3D Touch事件
- (void)application:(UIApplication *)application performActionForShortcutItem:(UIApplicationShortcutItem *)shortcutItem completionHandler:(void (^)(BOOL))completionHandler
{
    if (completionHandler) {
        NSLog(@"成功");
    }
    
    NSLog(@"标题>>%@", shortcutItem.localizedTitle);
    NSLog(@"Type>>%@", shortcutItem.type);
    NSLog(@"userInfo>>%@", shortcutItem.userInfo);
    
    FLOSideMenu *sideMenu = (FLOSideMenu *)application.keyWindow.rootViewController;
    UINavigationController *NavController = (UINavigationController *)sideMenu.contentViewController;
    NSString *touchType = (NSString *)shortcutItem.userInfo[@"touchkey_touch"];
    if ([touchType isEqualToString:@"qrcodeValue"]) {
        [NavController pushViewController:[[FLOCodeViewController alloc] init] animated:YES];
    } else if ([touchType isEqualToString:@"bookmarkValue"]) {
        [NavController pushViewController:[[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"SBIDBookMarkTableViewController"] animated:YES];
    } else if ([touchType isEqualToString:@"weiboValue"]) {
        [NavController pushViewController:[[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"SBIDWeiboTableViewController"] animated:YES];
    } else if ([touchType isEqualToString:@"mapValue"]) {
        Class ob = NSClassFromString(@"FLOBDMapViewController");
        UIViewController *viewController = [[ob alloc] init];
        viewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        
        [NavController.topViewController presentViewController:viewController animated:NO completion:nil];
    } else {
        return;
    }
}

- (void)applicationWillResignActive:(UIApplication *)application {
    [BMKMapView willBackGround];//当应用即将后台时调用，停止一切调用opengl相关的操作
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    [BMKMapView didForeGround];//当应用恢复前台状态时调用，回复地图的渲染和opengl相关的操作
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
