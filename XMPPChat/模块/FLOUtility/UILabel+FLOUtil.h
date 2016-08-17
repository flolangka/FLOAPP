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

@end
