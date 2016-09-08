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
#import <CoreData/CoreData.h>
#import <MBProgressHUD.h>

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
            MBProgressHUD *progress = [MBProgressHUD showHUDAddedTo:_window animated:YES];
            progress.mode = MBProgressHUDModeText;
            progress.labelText = @"网络异常，请检查网络连接";
            [progress show:YES];
            [progress hide:YES afterDelay:2];
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

#pragma mark - coreData
- (NSManagedObjectContext *)managedObjectContext{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator{
    NSString *libsPath = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES)[0];
    NSURL *storeURL = [NSURL fileURLWithPath:[libsPath stringByAppendingPathComponent:@"TestApp.sqlite"]];
    
    NSError *error = nil;
    NSPersistentStoreCoordinator *persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    return persistentStoreCoordinator;
}

- (NSManagedObjectModel *)managedObjectModel{
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"FLOCoreData" withExtension:@"momd"];
    NSManagedObjectModel *managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return managedObjectModel;
}

@end
