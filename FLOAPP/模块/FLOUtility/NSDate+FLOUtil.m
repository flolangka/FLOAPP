//
//  NSDate+FLOUtil.m
//  FLOAPP
//
//  Created by 360doc on 2017/4/17.
//  Copyright © 2017年 Flolangka. All rights reserved.
//

#import "NSDate+FLOUtil.h"

@implementation NSDate (FLOUtil)

/**
 *  获取当前 时:分:秒.毫秒
 *
 *  @return 时:分:秒.毫秒
 */
+ (NSString *)getNowTime {
    static NSDateFormatter *getNotTimeDateFormatter;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        getNotTimeDateFormatter = [[NSDateFormatter alloc] init];
        [getNotTimeDateFormatter setDateFormat:@"hh:mm:ss.SSS"];
    });
    
    return [getNotTimeDateFormatter stringFromDate:[NSDate date]];
}

/**
 HH:mm:ss
 昨天 HH:mm:ss
 yyyy-MM-dd HH:mm:ss

 @param timeinterval 时间戳
 @return 时间
 */
+ (NSString *)timeinterval2StringForDetail:(double)timeinterval {
    if (timeinterval > 0) {
        NSString *ShowTime = @"";
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:timeinterval];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateStyle:NSDateFormatterMediumStyle];
        [formatter setTimeStyle:NSDateFormatterShortStyle];
        [formatter setTimeZone:[NSTimeZone localTimeZone]];
        
        [formatter setDateFormat:@"yyyy-MM-dd"];
        NSString *String_Month = [formatter stringFromDate:date];
        
        [formatter setDateFormat:@"HH:mm"];
        NSString *String_time_HH = [formatter stringFromDate:date];
        
        NSDate *date_now = [NSDate date];
        double now = [date_now timeIntervalSince1970];
        if (now - timeinterval < 8 * 24 * 60 * 60) {
            NSCalendar *cal = [NSCalendar currentCalendar];
            unsigned int unitFlag = NSCalendarUnitDay | NSCalendarUnitHour |NSCalendarUnitMinute;
            
            [formatter setDateFormat:@"yyyy-MM-dd"];
            NSString *String_datenow_YMD = [formatter stringFromDate:date_now];
            NSString *String_datenow_end = [String_datenow_YMD stringByAppendingString:@" 23:59:59"];
            [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
            NSDate    *datenow_end = [formatter dateFromString:String_datenow_end];
            
            NSDateComponents *gap = [cal components:unitFlag fromDate:datenow_end toDate:date options:0];//计算时间差
            NSInteger ABSGD = ABS([gap day]);
            
            if (ABSGD >= 0){
                if (ABSGD == 0) {
                    //今天
                    ShowTime = String_time_HH;
                }else if (ABSGD == 1) {
                    ShowTime = [NSString stringWithFormat:@"%@ %@",@"昨天",String_time_HH];
                }else {
                    ShowTime = [NSString stringWithFormat:@"%@ %@",String_Month,String_time_HH];
                }
            }else{
                ShowTime = [NSString stringWithFormat:@"%@ %@",String_Month,String_time_HH];
            }
        }else{
            ShowTime = [NSString stringWithFormat:@"%@ %@",String_Month,String_time_HH];
        }
        return ShowTime;
    }else{
        return @"";
    }
}

@end
