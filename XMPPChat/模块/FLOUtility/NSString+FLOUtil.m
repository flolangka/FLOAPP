//
//  NSString+FLOUtil.m
//  FLOUtility
//
//  Created by 360doc on 16/8/15.
//  Copyright © 2016年 Flolangka. All rights reserved.
//

#import "NSString+FLOUtil.h"

@implementation NSString (FLOUtil)

// 删除末尾空格
- (NSString *)flo_stringByDeleteLastSpace {
    NSString *sourceStr = [self copy];
    while ([sourceStr hasSuffix:@" "]) {
        sourceStr = [sourceStr substringWithRange:NSMakeRange(0, sourceStr.length-1)];
    }
    return sourceStr;
}

@end
