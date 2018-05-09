//
//  UIImage+FLOUtil.h
//  FLOUtility
//
//  Created by 360doc on 16/7/19.
//  Copyright © 2016年 Flolangka. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (FLOUtil)

+ (UIImage *)flo_imageWithColor:(UIColor *)color;
+ (UIImage *)flo_imageWithColor:(UIColor *)color sizeToFit:(CGSize)size;

//图片圆角
- (UIImage *)flo_drawRectRadius:(CGFloat)radius;
- (UIImage *)flo_drawRectRadius:(CGFloat)radius sizeToFit:(CGSize)sizeToFit;

//压缩图片
- (UIImage *)flo_scaleToSize:(CGSize)newSize;

/**
 *  处理拍照图片旋转问题
 *
 *  @return 处理后图片
 */
- (UIImage *)fixOrientation;

/**
 裁剪、获取目标区域的图片
 
 @param rect 区域
 @return 新的图片
 */
- (UIImage *)clipToRect:(CGRect)rect;

@end
