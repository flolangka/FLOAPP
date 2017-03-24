//
//  UILabel+FLOUtil.h
//  FLOUtility
//
//  Created by 360doc on 16/7/22.
//  Copyright © 2016年 Flolangka. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UILabel (FLOUtil)

/**
 *  固定左、右位置，设置内容后自适应宽度
 *
 *  @param text 内容
 */
- (void)flo_fixLeftAdaptWidthSetText:(NSString *)text;
- (void)flo_fixRightAdaptWidthSetText:(NSString *)text;

/**
 *  设置文字、字体大小，调整宽高
 *
 *  @param text      文本
 *  @param font      字体大小
 *  @param maxWidth  最大宽
 *  @param maxHeight 最大高
 */
- (void)flo_adjustBoundsWithText:(NSString *)text font:(UIFont *)font maxWidth:(CGFloat)maxWidth maxHeight:(CGFloat)maxHeight;

@end
