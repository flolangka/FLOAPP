//
//  FLOWeiboStatusModel.h
//  XMPPChat
//
//  Created by admin on 15/12/17.
//  Copyright © 2015年 Flolangka. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FLOWeiboUserModel;

@interface FLOWeiboStatusModel : NSObject

@property (nonatomic, strong) FLOWeiboUserModel   *user;
@property (nonatomic, strong) NSString            *source;
@property (nonatomic, strong) NSDate              *created_at;
@property (nonatomic, strong) NSString            *text;
@property (nonatomic, strong) NSArray             *pic_urls;
@property (nonatomic        ) NSInteger           reposts_count;
@property (nonatomic        ) NSInteger           comments_count;
@property (nonatomic        ) NSInteger           attitudes_count;
@property (nonatomic, strong) FLOWeiboStatusModel *reStatus;
@property (nonatomic, strong) NSString            *statusID;
@property (nonatomic, strong) NSDictionary        *weiboDictionary;

//显示的多长时间前创建的微博
@property(nonatomic, copy) NSString *timeAgo;

//初始化model
- (instancetype)initWithDictionary:(NSDictionary *)statusInfo;
- (NSDictionary *)infoDictionary;

// 收藏微博
+ (void)favoriteStatus:(NSString *)statusID success:(void(^)())success failure:(void(^)())failure;
+ (void)cancelFavoriteStatus:(NSString *)statusID success:(void(^)())success failure:(void(^)())failure;

@end
