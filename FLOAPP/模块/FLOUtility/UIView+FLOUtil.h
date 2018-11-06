//
//  UIView+FLOUtil.h
//  FLOUtility
//
//  Created by 360doc on 16/7/22.
//  Copyright © 2016年 Flolangka. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (FLOUtil)

/**
 设置圆角

 @param radius 半径
 */
- (void)flo_setCornerRadius:(CGFloat)radius;

/**
 *  指定几个角设置圆角
 *
 *  @param radius  半径
 *  @param corners 哪几个角 UIRectCornerBottomLeft | UIRectCornerBottomRight | UIRectCornerTopLeft | UIRectCornerTopRight | UIRectCornerAllCorners
 */
- (void)flo_setCornerRadius:(CGFloat)radius roundingCorners:(UIRectCorner)corners;

/**
 设置虚线边框

 @param color 虚线颜色
 */
- (void)flo_dottedBorderWithColor:(UIColor *)color;

/**
 在两点间绘制虚线
 
 @param bounds 自身区域大小
 @param startPoint 起点
 @param endPoint 终点
 @param lineLength 虚线的宽度
 @param lineSpacing 虚线的间距
 @param lineColor 虚线的颜色
 */
- (void)drawDashLineInBounds:(CGRect)bounds
                  startPoint:(CGPoint)startPoint
                    endPoint:(CGPoint)endPoint
                  lineLength:(int)lineLength
                 lineSpacing:(int)lineSpacing
                   lineColor:(UIColor *)lineColor;

/**
 绘制虚线矩形
 
 @param rect 虚线矩形位置、大小
 @param lineLength 虚线的宽度
 @param lineSpacing 虚线的间距
 @param lineColor 虚线的颜色
 @param cornerRadius 圆角
 */
- (void)drawDashLineBorderRect:(CGRect)rect
                    lineLength:(int)lineLength
                   lineSpacing:(int)lineSpacing
                     lineColor:(UIColor *)lineColor
                  cornerRadius:(float)cornerRadius;

#pragma mark - 设置分割线
- (void)flo_topLineHide:(BOOL)hide;
- (void)flo_topLineLeft:(float)left right:(float)right;

- (void)flo_bottomLineHide:(BOOL)hide;
- (void)flo_bottomLineLeft:(float)left right:(float)right;

- (void)flo_addLineMarginTop:(float)top left:(float)left right:(float)right;
- (void)flo_addLineMarginBottom:(float)bottom left:(float)left right:(float)right;

- (void)flo_setLineColor:(UIColor *)color;

@end
