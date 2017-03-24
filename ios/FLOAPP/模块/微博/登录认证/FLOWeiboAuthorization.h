//
//  FLOWeiboAuthorization.h
//  XMPPChat
//
//  Created by admin on 15/12/16.
//  Copyright © 2015年 Flolangka. All rights reserved.
//

#import <Foundation/Foundation.h>

static NSString * const kGrantType = @"authorization_code";
static NSString * const kAccessToken = @"access_token";
static NSString * const kTokenTime = @"expires_in";
static NSString * const kUID = @"uid";

@interface FLOWeiboAuthorization : NSObject

@property (nonatomic, copy  ) NSString *token;
@property (nonatomic, strong) NSDate   *expiresDate;    //token生命周期
@property (nonatomic, copy  ) NSString *UID;

+ (FLOWeiboAuthorization *)sharedAuthorization;

- (void)loginSuccess:(NSDictionary *)dic;
- (BOOL)isLogin;
- (void)logout;

@end
