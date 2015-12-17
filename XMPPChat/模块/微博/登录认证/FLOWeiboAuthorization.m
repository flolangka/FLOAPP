//
//  FLOWeiboAuthorization.m
//  XMPPChat
//
//  Created by admin on 15/12/16.
//  Copyright © 2015年 Flolangka. All rights reserved.
//

#import "FLOWeiboAuthorization.h"
#import "FLODataBaseEngin.h"

static FLOWeiboAuthorization *authorization;
static NSString * userAuthorizationFilePath;

@implementation FLOWeiboAuthorization

+ (FLOWeiboAuthorization *)sharedAuthorization
{
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        // 判断归档文件是否存在，存在就从文件中读取数据
        NSString *docPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
        userAuthorizationFilePath = [docPath stringByAppendingPathComponent:@"WeiboUserAuthorization"];
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if ([fileManager fileExistsAtPath:userAuthorizationFilePath]) {
            authorization = [NSKeyedUnarchiver unarchiveObjectWithFile:userAuthorizationFilePath];
        } else {
            authorization = [[self alloc] init];
        }
    });
    return authorization;
}

- (void)loginSuccess:(NSDictionary *)dic
{
    self.token = dic[kAccessToken];
    self.expiresDate = [NSDate dateWithTimeIntervalSinceNow:[dic[kTokenTime] doubleValue]];
    self.UID = dic[kUID];
    
    // 本地归档保存authorization
    [NSKeyedArchiver archiveRootObject:self toFile:userAuthorizationFilePath];
}

- (BOOL)isLogin
{
    if (self.token) {
        return YES;
    }
    return NO;
}

- (void)logout
{
    self.token = nil;
    self.expiresDate = nil;
    self.UID = nil;
    
    // 删除数据
    [[FLODataBaseEngin shareInstance] clearWeiboData];
    [[NSFileManager defaultManager] removeItemAtPath:userAuthorizationFilePath error:nil];
}

#pragma mark - NSCoding
// 解档
- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super init]) {
        self.expiresDate = [aDecoder decodeObjectForKey:kTokenTime];
        if ([[NSDate date] compare:self.expiresDate] < 0) {
            self.token = [aDecoder decodeObjectForKey:kAccessToken];
            self.UID = [aDecoder decodeObjectForKey:kUID];
        } else {
            // 登陆超时，重新登陆
            return nil;
        }
    }
    return self;
}

// 归档
- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.token forKey:kAccessToken];
    [aCoder encodeObject:self.expiresDate forKey:kTokenTime];
    [aCoder encodeObject:self.UID forKey:kUID];
}

@end
