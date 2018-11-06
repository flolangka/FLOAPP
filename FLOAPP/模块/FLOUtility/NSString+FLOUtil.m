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
 限宽时需要的高度
 
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

/**
 限高时需要的宽度
 
 @param limitH 限高
 @param fontSize 字号
 @return 宽度
 */
- (float)widthWithLimitHeight:(float)limitH fontSize:(float)fontSize {
    if (self == nil || self.length == 0) {
        return 0;
    }
    
    NSDictionary *attribute = @{NSFontAttributeName: [UIFont systemFontOfSize:fontSize]};
    float width = [self boundingRectWithSize:CGSizeMake(MAXFLOAT, limitH) options:NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading  attributes:attribute context:nil].size.width;
    return ceilf(width);
}


/**
 字符串添加属性
 
 @param font 字体
 @param lineSpacing 行间距
 @param paragraphSpacing 段间距
 @param lineBreakMode 文字过长时的显示方式；NSLineBreakByTruncatingTail:末尾显示...（在显示2行超出显示...时才设置，否则YYTextLayout布局会出现问题)
 @param alignment 对齐方式，默认左对齐; NSTextAlignmentJustified:两端对齐
 @return 属性字符串
 */
- (NSAttributedString *)attributedFont:(UIFont *)font
                           lineSpacing:(float)lineSpacing
                      paragraphSpacing:(float)paragraphSpacing
                         lineBreakMode:(NSLineBreakMode)lineBreakMode
                             alignment:(NSTextAlignment)alignment {
    NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
    if (lineSpacing) {
        paragraphStyle.lineSpacing = lineSpacing - (font.lineHeight - font.pointSize);
    }
    if (paragraphSpacing) {
        paragraphStyle.paragraphSpacing = paragraphSpacing;
    }
    if (lineBreakMode) {
        paragraphStyle.lineBreakMode = lineBreakMode;
    }
    if (alignment) {
        paragraphStyle.alignment = alignment;
    }
    
    NSMutableDictionary *attributes = [NSMutableDictionary dictionary];
    [attributes setObject:paragraphStyle forKey:NSParagraphStyleAttributeName];
    [attributes setObject:font forKey:NSFontAttributeName];
    
    return [[NSAttributedString alloc] initWithString:self attributes:attributes];
}

/**
 字符串添加属性
 
 @param font 字体
 @param lineSpacing 行间距
 @param alignment 对齐方式，默认左对齐; NSTextAlignmentJustified:两端对齐
 @return 属性字符串
 */
- (NSAttributedString *)attributedFont:(UIFont *)font
                           lineSpacing:(float)lineSpacing
                             alignment:(NSTextAlignment)alignment {
    return [self attributedFont:font
                    lineSpacing:lineSpacing
               paragraphSpacing:0
                  lineBreakMode:0
                      alignment:alignment];
}

/**
 字符串添加属性
 
 @param font 字体
 @param paragraphSpacing 段间距
 @param alignment 对齐方式，默认左对齐; NSTextAlignmentJustified:两端对齐
 @return 属性字符串
 */
- (NSAttributedString *)attributedFont:(UIFont *)font
                      paragraphSpacing:(float)paragraphSpacing
                             alignment:(NSTextAlignment)alignment {
    return [self attributedFont:font
                    lineSpacing:0
               paragraphSpacing:paragraphSpacing
                  lineBreakMode:0
                      alignment:alignment];
}

@end
