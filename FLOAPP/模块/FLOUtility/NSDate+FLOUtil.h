//
//  NSDate+FLOUtil.h
//  FLOAPP
//
//  Created by 360doc on 2017/4/17.
//  Copyright © 2017年 Flolangka. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (FLOUtil)

/**
 *  获取当前 时:分:秒.毫秒
 *
 *  @return 时:分:秒.毫秒
 */
+ (NSString *)getNowTime;

/**
 HH:mm:ss
 昨天 HH:mm:ss
 yyyy-MM-dd HH:mm:ss
 
 @param timeinterval 时间戳
 @return 时间
 */
+ (NSString *)timeinterval2StringForDetail:(double)timeinterval;

@end
