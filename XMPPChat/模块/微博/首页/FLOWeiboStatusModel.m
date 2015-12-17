//
//  FLOWeiboStatusModel.m
//  XMPPChat
//
//  Created by admin on 15/12/17.
//  Copyright © 2015年 Flolangka. All rights reserved.
//

#import "FLOWeiboStatusModel.h"
#import "FLOWeiboUserModel.h"
#import <AFHTTPSessionManager.h>
#import "FLOWeiboAuthorization.h"

@implementation FLOWeiboStatusModel

-(instancetype)initWithDictionary:(NSDictionary *)statusInfo
{
    self = [super init];
    if (self) {
        //设置属性
        //设置user属性
        NSDictionary *userInfo = statusInfo[@"user"];
        self.user = [[FLOWeiboUserModel alloc] initWithDictionary:userInfo];
        
        self.source = [self sourceWithString:statusInfo[@"source"]];
        self.created_at = [self dateWithDateString:statusInfo[@"created_at"]];
        self.text = statusInfo[@"text"];
        
        // 最多显示8张图片
        NSMutableArray *picArray = [NSMutableArray arrayWithArray:statusInfo[@"pic_urls"]];
        if (picArray.count > 8) {
            [picArray removeObjectAtIndex:picArray.count-1];
        }
        self.pic_urls = picArray;
        self.reposts_count = [statusInfo[@"reposts_count"] integerValue];
        self.comments_count = [statusInfo[@"comments_count"] integerValue];
        self.attitudes_count = [statusInfo[@"attitudes_count"] integerValue];
        
        //根据有无转发微博，创建微博对象
        // 注意可能存在 NSNull
        NSDictionary *reStatusInfo = statusInfo[@"retweeted_status"];
        if (reStatusInfo && ![reStatusInfo isKindOfClass:[NSNull class]]) {
            self.reStatus = [[FLOWeiboStatusModel alloc] initWithDictionary:reStatusInfo];
        }
        
        // id作为微博请求参数
        self.statusID = statusInfo[@"id"];
    }
    
    return self;
}
//重写get方法
-(NSString *)timeAgo{
    //计算跟当前时间的时间差
    NSTimeInterval time = -[self.created_at timeIntervalSinceNow];
    
    if (time < 60) {
        return @"刚刚";
    }else if (time < 3600) {
        return [NSString stringWithFormat:@"%ld 分钟前", (NSInteger)time/60];
    }else if (time < 3600 * 24) {
        return [NSString stringWithFormat:@"%ld 小时前", (NSInteger)time/3600];
    }else if (time < 3600 * 24 * 30){
        return [NSString stringWithFormat:@"%ld 天前", (NSInteger)time/(3600 * 24)];
    }else{
        return [NSDateFormatter localizedStringFromDate:self.created_at dateStyle:NSDateFormatterMediumStyle timeStyle:NSDateFormatterNoStyle];
    }
}

//"<a href=\"http://app.weibo.com/t/feed/5yiHuw\" rel=\"nofollow\">iPhone 6 Plus</a>"
//从这其中找出正文
//">.*<"

-(NSString *)sourceWithString:(NSString *)string{
    NSString *soure = nil;//保存结果；
    //定义的正则表达式字符串
    NSString *regExStr = @">.*<";
    //排除无效的情况
    if ([string isKindOfClass:[NSNull class]] || string == nil || [string isEqualToString:@""]) {
        return @"";
    }
    //构造正则
    NSRegularExpression *expression = [NSRegularExpression regularExpressionWithPattern:regExStr options:0 error:nil];
    //查询出结果
    NSTextCheckingResult *result = [expression firstMatchInString:string options:0 range:NSMakeRange(0, string.length -1)];
    
    //取出子字符串
    if (result) {
        NSRange range = [result rangeAtIndex:0];
        soure = [string substringWithRange:NSMakeRange(range.location + 1, range.length - 2)];
    }
    return soure;
}

+ (void)favoriteStatus:(NSString *)statusID success:(void (^)())success failure:(void (^)())failure
{
    FLOWeiboAuthorization *authorization = [FLOWeiboAuthorization sharedAuthorization];
    if (authorization.isLogin) {
        NSDictionary *parameters = @{kAccessToken:authorization.token,
                                     @"id":statusID};
        AFHTTPSessionManager *managr = [AFHTTPSessionManager manager];
        [managr POST:@"https://api.weibo.com/2/favorites/create.json" parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            success();
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            failure();
        }];
    } else {
        return;
    }
}

+ (void)cancelFavoriteStatus:(NSString *)statusID success:(void (^)())success failure:(void (^)())failure
{
    FLOWeiboAuthorization *authorization = [FLOWeiboAuthorization sharedAuthorization];
    if (authorization.isLogin) {
        NSDictionary *parameters = @{kAccessToken:authorization.token,
                                     @"id":statusID};        
        AFHTTPSessionManager *managr = [AFHTTPSessionManager manager];
        [managr POST:@"https://api.weibo.com/2/favorites/destroy.json" parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            success();
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            failure();
        }];
    } else {
        return;
    }
}

- (NSDate *)dateWithDateString:(NSString *)string
{
    //将时间字符串转化为时间
    //"Sun Apr 26 09:06:27 +0800 2015"
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    //构造时间格式字符串
    NSString *formatterString = @"EEE MMM dd HH:mm:ss zzz yyyy";
    [formatter setDateFormat:formatterString];
    NSDate *date = [formatter dateFromString:string];
    return date;
}

@end
