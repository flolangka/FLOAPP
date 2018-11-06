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

/**
 限宽时需要的高度

 @param limitW 限宽
 @param fontSize 字号
 @return 高度
 */
- (float)heightWithLimitWidth:(float)limitW fontSize:(float)fontSize;

/**
 限高时需要的宽度
 
 @param limitH 限高
 @param fontSize 字号
 @return 宽度
 */
- (float)widthWithLimitHeight:(float)limitH fontSize:(float)fontSize;


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
                             alignment:(NSTextAlignment)alignment;

/**
 字符串添加属性

 @param font 字体
 @param lineSpacing 行间距
 @param alignment 对齐方式，默认左对齐; NSTextAlignmentJustified:两端对齐
 @return 属性字符串
 */
- (NSAttributedString *)attributedFont:(UIFont *)font
                           lineSpacing:(float)lineSpacing
                             alignment:(NSTextAlignment)alignment;

/**
 字符串添加属性

 @param font 字体
 @param paragraphSpacing 段间距
 @param alignment 对齐方式，默认左对齐; NSTextAlignmentJustified:两端对齐
 @return 属性字符串
 */
- (NSAttributedString *)attributedFont:(UIFont *)font
                      paragraphSpacing:(float)paragraphSpacing
                             alignment:(NSTextAlignment)alignment;

@end
