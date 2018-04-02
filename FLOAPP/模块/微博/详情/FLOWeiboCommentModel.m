//
//  FLOWeiboCommentModel.m
//  XMPPChat
//
//  Created by admin on 15/12/20.
//  Copyright © 2015年 Flolangka. All rights reserved.
//

#import "FLOWeiboCommentModel.h"
#import "FLOWeiboUserModel.h"
#import "FLOWeiboStatusModel.h"

@implementation FLOWeiboCommentModel

-(instancetype)initWithDictionary:(NSDictionary *)dic
{
    self = [super init];
    if (self) {
        self.source = [self sourceWithString:dic[@"source"]];
        self.commentsID = dic[@"id"];
        self.commentsText = dic[@"text"];
        self.userInfo = [[FLOWeiboUserModel alloc] initWithDictionary:dic[@"user"]];
        self.status = [[FLOWeiboStatusModel alloc] initWithDictionary:dic[@"status"]];
        
        NSDate *date = [self dateWithDateString:dic[@"created_at"]];
        NSTimeInterval time = -[date timeIntervalSinceNow];
        if (time < 60) {
            self.time = @"刚刚";
        }else if (time < 3600) {
            self.time = [NSString stringWithFormat:@"%ld 分钟前", (NSInteger)time/60];
        }else if (time < 3600 * 24) {
            self.time = [NSString stringWithFormat:@"%ld 小时前", (NSInteger)time/3600];
        }else if (time < 3600 * 24 * 30){
            self.time = [NSString stringWithFormat:@"%ld 天前", (NSInteger)time/(3600 * 24)];
        }else{
            self.time = [NSDateFormatter localizedStringFromDate:date dateStyle:NSDateFormatterMediumStyle timeStyle:NSDateFormatterNoStyle];
        }
    }
    return self;
}

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

- (NSDate *)dateWithDateString:(NSString *)string
{
    //将时间字符串转化为时间
    //"Sun Apr 26 09:06:27 +0800 2015"
    
    /*
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    //构造时间格式字符串
    NSString *formatterString = @"EEE MMM dd HH:mm:ss zzz yyyy";
    [formatter setDateFormat:formatterString];
    NSDate *date = [formatter dateFromString:string];
    return date;
    */
    
    struct tm tm;
    time_t t;
    string = [string substringFromIndex:4];
    strptime([string cStringUsingEncoding:NSUTF8StringEncoding], "%b %d %H:%M:%S %z %Y", &tm);
    tm.tm_isdst = -1;
    t = mktime(&tm);
    
    return [NSDate dateWithTimeIntervalSince1970:t];
}

@end
