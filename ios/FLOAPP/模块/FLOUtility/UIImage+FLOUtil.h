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

- (UIImage *)flo_drawRectRadius:(CGFloat)radius;
- (UIImage *)flo_drawRectRadius:(CGFloat)radius sizeToFit:(CGSize)sizeToFit;

//压缩图片
- (UIImage *)flo_scaleToSize:(CGSize)newSize;

@end
