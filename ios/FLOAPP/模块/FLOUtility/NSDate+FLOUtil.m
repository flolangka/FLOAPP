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
+ (NSString *)getNotTime {
    static NSDateFormatter *getNotTimeDateFormatter;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        getNotTimeDateFormatter = [[NSDateFormatter alloc] init];
        [getNotTimeDateFormatter setDateFormat:@"hh:mm:ss.SSS"];
    });
    
    return [getNotTimeDateFormatter stringFromDate:[NSDate date]];
}

@end
