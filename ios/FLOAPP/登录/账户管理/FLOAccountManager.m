//
//  FLOAccountManager.m
//  XMPPChat
//
//  Created by admin on 15/11/26.
//  Copyright © 2015年 Flolangka. All rights reserved.
//

#import "FLOAccountManager.h"

static FLOAccountManager *_accountManager;

static NSString * const userDefaultsKey_userName = @"username";
static NSString * const userDefaultsKey_password = @"password";

@implementation FLOAccountManager

+ (instancetype)shareManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _accountManager = [[self alloc] init];
    });
    return _accountManager;
}

//登录页调用
- (BOOL)logInWithName:(NSString *)name password:(NSString *)password
{
    BOOL loginSuccess = YES;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if (loginSuccess) {
            NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
            [userDefault setObject:name forKey:userDefaultsKey_userName];
            [userDefault setObject:password forKey:userDefaultsKey_password];
            [userDefault synchronize];
        }
    });
    
    return loginSuccess;
}

/**
 *  注销
 */
- (void)logOut
{
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    [userDefault setObject:@"" forKey:userDefaultsKey_password];
    [userDefault synchronize];
}

//首页调用--检查是否有记住的用户名密码
- (BOOL)checkLoginState
{
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSString *userName = [userDefault objectForKey:userDefaultsKey_userName];
    NSString *password = [userDefault objectForKey:userDefaultsKey_password];
    
    if (userName && password && userName.length > 0 && password.length > 0) {
        return YES;
    } else {
        return NO;
    }
}

@end
