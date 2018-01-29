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

- (NSString *)StringEncoded2UTF8String
{
    if (self == nil || self.length == 0) {
        return @"";
    }
    NSCharacterSet *charset = [[NSCharacterSet characterSetWithCharactersInString:@"!*'();:@&=+$,/?%#[]"]invertedSet];
    NSString *encodedString = [self stringByAddingPercentEncodingWithAllowedCharacters:charset];
    return encodedString;
}

- (NSString *)StringDecoded2UTF8String
{
    if (self == nil || self.length == 0) {
        return @"";
    }
    NSString *decodedString = [self stringByRemovingPercentEncoding];
    if (Def_CheckStringClassAndLength(decodedString)) {
        return decodedString;
    }
    return self;
}

//普通字符串转换为十六进制的
- (NSString *)hexString {
    NSData *myD = [self dataUsingEncoding:NSUTF8StringEncoding];
    Byte *bytes = (Byte *)[myD bytes];
    //下面是Byte 转换为16进制。
    NSString *hexStr=@"";
    for(int i=0;i<[myD length];i++) {
        NSString *newHexStr = [NSString stringWithFormat:@"%x",bytes[i]&0xff];///16进制数
        
        if([newHexStr length]==1) {
            hexStr = [NSString stringWithFormat:@"%@0%@",hexStr,newHexStr];
        } else {
            hexStr = [NSString stringWithFormat:@"%@%@",hexStr,newHexStr];
        }
    }
    return hexStr;
}

/**
 限款是需要的高度
 
 @param limitW 限宽
 @param fontSize 字号
 @return 高度
 */
- (float)heightWithLimitWidth:(float)limitW fontSize:(float)fontSize {
    if (self == nil || self.length == 0) {
        return 0;
    }
    
    NSDictionary *attribute = @{NSFontAttributeName: [UIFont systemFontOfSize:fontSize]};
    float height = [self boundingRectWithSize:CGSizeMake(limitW, MAXFLOAT) options:NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading  attributes:attribute context:nil].size.height;
    return ceilf(height);
}

@end
