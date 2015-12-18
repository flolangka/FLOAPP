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

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    return YES;
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
    } else if ([touchType isEqualToString:@"chatValue"]) {
        [sideMenu setContentViewController:[[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"SBIDFLOTabBarVCID"]];
    } else {
        return;
    }
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
