//
//  FLOAccountManager.h
//  XMPPChat
//
//  Created by admin on 15/11/26.
//  Copyright © 2015年 Flolangka. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FLOAccountManager : NSObject

+ (instancetype)shareManager;


//登录页调用
- (BOOL)logInWithName:(NSString *)name password:(NSString *)password;


//注销,清除UD的密码记录
- (void)logOut;


//首页调用--检查是否有记住的用户名密码
- (BOOL)checkLoginState;


@end


/*
    当前登录用户的用户名与密码存储在UD
    登录过得用户数据存储到数据库
*/
