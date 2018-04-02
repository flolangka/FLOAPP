//
//  AppDelegate.m
//  XMPPChat
//
//  Created by admin on 15/11/25.
//  Copyright © 2015年 Flolangka. All rights reserved.
//

#import "AppDelegate.h"

#import "FLOSideMenu.h"
#import "FLODownloadManager.h"

#import "FLOWebViewController.h"
#import "FLONetWorkTableViewController.h"
#import "FLODownloadTableViewController.h"

#import <WXApi.h>
#import <MBProgressHUD.h>
#import <AFNetworkReachabilityManager.h>
#import <UserNotifications/UserNotifications.h>

@interface AppDelegate ()<UNUserNotificationCenterDelegate, WXApiDelegate>

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [self networkMonitor];
    [[FLODownloadManager manager] checkKilledDownloadService];
    
    //注册微信，不开启MTA数据上报
    //[WXApi registerApp:WXAppKey enableMTA:NO];
        
    return YES;
}

#pragma mark 网络状态监听
- (void)networkMonitor
{
    AFNetworkReachabilityManager *networkManager = [AFNetworkReachabilityManager sharedManager];
    [networkManager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        NSString *networkStatus = nil;
        switch (status) {
            case AFNetworkReachabilityStatusUnknown:
                networkStatus = DEVICE_NETWORK_CHANGE_2_NONE_NOTIFICATION;
                break;
            case AFNetworkReachabilityStatusNotReachable:
                networkStatus = DEVICE_NETWORK_CHANGE_2_NONE_NOTIFICATION;
                break;
            case AFNetworkReachabilityStatusReachableViaWiFi:
                networkStatus = DEVICE_NETWORK_CHANGE_2_WIFI_NOTIFICATION;
                break;
            case AFNetworkReachabilityStatusReachableViaWWAN:
                networkStatus = DEVICE_NETWORK_CHANGE_2_VIAWWAN_NOTIFICATION;
                break;
            default:
                break;
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
           [[NSNotificationCenter defaultCenter] postNotificationName:DEVICE_NETWORK_CHANGE_NOTIFICATION object:[UIApplication sharedApplication] userInfo:@{@"NetworkChange":networkStatus}]; 
        });
    }];
    [networkManager startMonitoring];
}

//接收主屏幕图标3D Touch事件
- (void)application:(UIApplication *)application performActionForShortcutItem:(UIApplicationShortcutItem *)shortcutItem completionHandler:(void (^)(BOOL))completionHandler
{
    if (completionHandler) {
        DLog(@"成功");
    }
    
    DLog(@"标题>>%@", shortcutItem.localizedTitle);
    DLog(@"Type>>%@", shortcutItem.type);
    DLog(@"userInfo>>%@", shortcutItem.userInfo);
    
    FLOSideMenu *sideMenu = (FLOSideMenu *)application.keyWindow.rootViewController;
    UINavigationController *NavController = (UINavigationController *)sideMenu.contentViewController;
    [NavController dismissViewControllerAnimated:NO completion:nil];
    [NavController popToRootViewControllerAnimated:NO];
    
    NSString *touchType = (NSString *)shortcutItem.userInfo[@"touchkey_touch"];
    if ([touchType isEqualToString:@"qrcodeValue"]) {
        Class ob = NSClassFromString(@"FLOCodeViewController");
        UIViewController *viewController = [[ob alloc] init];
        [NavController pushViewController:viewController animated:YES];
    } else if ([touchType isEqualToString:@"bookmarkValue"]) {
        [NavController pushViewController:[[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"SBIDBookMarkTableViewController"] animated:YES];
    } else if ([touchType isEqualToString:@"weiboValue"]) {
        [NavController pushViewController:[[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"SBIDWeiboTableViewController"] animated:YES];
    } else if ([touchType isEqualToString:@"mapValue"]) {
        Class ob = NSClassFromString(@"FLOBDMapViewController");
        UIViewController *viewController = [[ob alloc] init];
        viewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        
        [NavController.topViewController presentViewController:viewController animated:NO completion:nil];
    } else if ([touchType isEqualToString:@"notifyValue"]) {
        Class ob = NSClassFromString(@"FLONotificationTimeTableViewController");
        UIViewController *viewController = [[ob alloc] init];
        [NavController pushViewController:viewController animated:YES];
    } else {
        return;
    }
}

//响应FlolangkaWidget、其他app调起
- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options {
    DLog(@"%@", options);
    DLog(@"%@", url);
    
    NSString *strURL = url.absoluteString;
    
    UIViewController *viewController = nil;
    if ([strURL hasPrefix:@"FloAPPBrowser://"]) {
        FLOWebViewController *webViewController = [[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"SBIDWebViewController"];
        webViewController.webViewAddress = [strURL substringFromIndex:16];
        viewController = webViewController;
    } else if ([strURL hasPrefix:@"FloAPPRequest://"]) {
        FLONetWorkTableViewController *networkVC = [[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"SBIDNetWorkTableViewController"];
        networkVC.URLStr = [strURL substringFromIndex:16];
        viewController = networkVC;
    } else if ([strURL hasPrefix:@"FloAPPDownload://"]) {
        FLODownloadTableViewController *downloadVC = [[FLODownloadTableViewController alloc] init];
        downloadVC.URLStr = [strURL substringFromIndex:17];
        viewController = downloadVC;
    }
    
    if (viewController) {
        FLOSideMenu *sideMenu = (FLOSideMenu *)app.keyWindow.rootViewController;
        UINavigationController *NavController = (UINavigationController *)sideMenu.contentViewController;
        [NavController dismissViewControllerAnimated:NO completion:nil];
        [NavController popToRootViewControllerAnimated:NO];
        [NavController pushViewController:viewController animated:YES];
    } else {
        //微信
        [WXApi handleOpenURL:url delegate:self];
    }
    
    return YES;
}

#pragma mark - WXApiDelegate
/*! @brief 收到一个来自微信的请求，第三方应用程序处理完后调用sendResp向微信发送结果
 *
 * 收到一个来自微信的请求，异步处理完成后必须调用sendResp发送处理结果给微信。
 * 可能收到的请求有GetMessageFromWXReq、ShowMessageFromWXReq等。
 * @param req 具体请求内容，是自动释放的
 */
- (void)onReq:(BaseReq*)req {
    NSString *logStr = [NSString stringWithFormat:@"\n微信请求： %@\n    type：%d\n   openID：%@", NSStringFromClass([req class]), req.type, req.openID];
    DLog(@"%@", logStr);
    
    [WXApi sendResp:nil];
}

/*! @brief 发送一个sendReq后，收到微信的回应
 *
 * 收到一个来自微信的处理结果。调用一次sendReq后会收到onResp。
 * 可能收到的处理结果有SendMessageToWXResp、SendAuthResp等。
 * @param resp具体的回应内容，是自动释放的
 */
- (void)onResp:(BaseResp*)resp {
    NSString *logStr = [NSString stringWithFormat:@"\n微信回应： %@\n    type：%d\n   errCode：%d\n    errStr：%@", NSStringFromClass([resp class]), resp.type, resp.errCode, resp.errStr];
    DLog(@"%@", logStr);
}


#pragma mark - app 生命周期
- (void)applicationWillResignActive:(UIApplication *)application {
    
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark - 通知
- (void)registerNotifer {
    //iOS10特有
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    // 必须写代理，不然无法监听通知的接收与点击
    center.delegate = self;
    [center requestAuthorizationWithOptions:(UNAuthorizationOptionAlert | UNAuthorizationOptionBadge | UNAuthorizationOptionSound) completionHandler:^(BOOL granted, NSError * _Nullable error) {
        if (granted) {
            // 点击允许
            [center getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings * _Nonnull settings) {
                DLog(@"%@", settings);
            }];
        } else {
            // 点击不允许
        }
    }];
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(nonnull NSData *)deviceToken {
    NSString *token = [[[[deviceToken description]
                         stringByReplacingOccurrencesOfString:@"<" withString:@""]
                        stringByReplacingOccurrencesOfString:@">" withString:@""]
                       stringByReplacingOccurrencesOfString:@" " withString:@""];
    DLog(@"Token：%@", token);
}

#pragma mark - 收到推送消息
// iOS 10收到通知,只有在应用运行时且在前台会调用
- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions options))completionHandler{
    
    completionHandler(UNNotificationPresentationOptionBadge|UNNotificationPresentationOptionSound|UNNotificationPresentationOptionAlert); // 需要执行这个方法，选择是否提醒用户，有Badge、Sound、Alert三种类型可以设置
}

// iOS 10通知的点击事件(启动、未启动都会走)
- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void(^)(void))completionHandler{
    
    completionHandler();  // 系统要求执行这个方法
}


@end
