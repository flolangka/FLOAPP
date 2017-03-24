//
//  UIView+FLOUtil.h
//  FLOUtility
//
//  Created by 360doc on 16/7/22.
//  Copyright © 2016年 Flolangka. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (FLOUtil)

- (void)flo_setCornerRadius:(CGFloat)radius;

/**
 *  指定几个角设置圆角
 *
 *  @param radius  半径
 *  @param corners 哪几个角 UIRectCornerBottomLeft | UIRectCornerBottomRight | UIRectCornerTopLeft | UIRectCornerTopRight | UIRectCornerAllCorners
 */
- (void)flo_setCornerRadius:(CGFloat)radius roundingCorners:(UIRectCorner)corners;


@end
