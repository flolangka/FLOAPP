//
//  NSString+FLOUtil.h
//  FLOUtility
//
//  Created by 360doc on 16/8/15.
//  Copyright © 2016年 Flolangka. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (FLOUtil)

// 删除末尾空格
- (NSString *)flo_stringByDeleteLastSpace;

- (NSString *)StringEncoded2UTF8String;

- (NSString *)StringDecoded2UTF8String;

//普通字符串转换为十六进制的
- (NSString *)hexString;

@end
