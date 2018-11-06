//
//  UIView+FLOUtil.m
//  FLOUtility
//
//  Created by 360doc on 16/7/22.
//  Copyright © 2016年 Flolangka. All rights reserved.
//

#import "UIView+FLOUtil.h"
#import <Masonry.h>

#define TAG_TOPLINE    4444400
#define TAG_BOTTOMLINE 4444401
#define TAG_LINE_MAX   4444499

#define LINE_COLOR     COLOR_HEX(0xD8D8D8)

@implementation UIView (FLOUtil)

- (void)flo_setCornerRadius:(CGFloat)radius {
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds cornerRadius:radius];
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = self.bounds;
    maskLayer.path = maskPath.CGPath;
    
    self.layer.mask = maskLayer;
}

- (void)flo_setCornerRadius:(CGFloat)radius roundingCorners:(UIRectCorner)corners {
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds byRoundingCorners:corners cornerRadii:CGSizeMake(radius,radius)];
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = self.bounds;
    maskLayer.path = maskPath.CGPath;
    
    self.layer.mask = maskLayer;
}

/**
 设置虚线边框
 
 @param color 虚线颜色
 */
- (void)flo_dottedBorderWithColor:(UIColor *)color {
    /* 初始化一个layer */
    CAShapeLayer *border = [CAShapeLayer layer];
    border.bounds = self.bounds;//虚线框的大小
    border.position = CGPointMake(CGRectGetMidX(self.bounds),CGRectGetMidY(self.bounds));//虚线框锚点
    
    /* 虚线的颜色 */
    border.strokeColor = color.CGColor;
    /* 填充虚线内的颜色 */
    border.fillColor = nil;
    /* 贝塞尔曲线路径 */
    border.path = [UIBezierPath bezierPathWithRect:border.bounds].CGPath;
    /* 虚线宽度 */
    border.lineWidth = 1;
    //border.frame = view.bounds; /* 这个因为给了路径, 而且用的约束给的控件尺寸, 所以没什么效果 */
    /* 官方API注释:The cap style used when stroking the path. Options are `butt', `round'
     * and `square'. Defaults to `butt'. */
    /* 意思是沿路径画帽时的样式 有三种 屁股 ; 圆; 广场 ,我没感觉有啥区别 可以自己试一下*/
    border.lineCap = @"square";
    /* 虚线的每个点长  和 两个点之间的空隙 */
    border.lineDashPattern = @[@3, @5];
    /* 添加到你的控件上 */
    [self.layer addSublayer:border];
}

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
                   lineColor:(UIColor *)lineColor {
    
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    [shapeLayer setBounds:bounds];
    [shapeLayer setPosition:CGPointMake(CGRectGetWidth(bounds) / 2, CGRectGetHeight(bounds)/2)];
    
    [shapeLayer setStrokeColor:lineColor.CGColor];
    [shapeLayer setLineWidth:1.f];
    //设置线宽，线间距
    [shapeLayer setLineDashPattern:@[@(lineLength), @(lineSpacing)]];
    
    //设置路径
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, startPoint.x, startPoint.y);
    CGPathAddLineToPoint(path, NULL, endPoint.x, endPoint.y);
    
    [shapeLayer setPath:path];
    CGPathRelease(path);
    
    [self.layer addSublayer:shapeLayer];
}

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
                  cornerRadius:(float)cornerRadius {
    
    CAShapeLayer *border = [CAShapeLayer layer];
    [border setBounds:CGRectMake(0, 0, CGRectGetWidth(rect), CGRectGetHeight(rect))];
    [border setPosition:CGPointMake(CGRectGetWidth(rect) / 2, CGRectGetHeight(rect)/2)];
    
    //虚线的颜色
    border.strokeColor = lineColor.CGColor;
    border.fillColor = [UIColor clearColor].CGColor;
    //虚线的宽度
    border.lineWidth = 1.f;
    //虚线的间隔
    border.lineDashPattern = @[@(lineLength), @(lineSpacing)];
    
    //设置路径
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:cornerRadius];
    border.path = path.CGPath;
    
    [self.layer addSublayer:border];
}

#pragma mark - 设置分割线
- (void)flo_topLineHide:(BOOL)hide {
    [[self viewWithTag:TAG_TOPLINE] setHidden:hide];
}
- (void)flo_topLineLeft:(float)left right:(float)right {
    UIView *topLine = [self viewWithTag:TAG_TOPLINE];
    if (topLine) {
        [topLine mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self).offset(left);
            make.right.equalTo(self).offset(right);
        }];
    } else {
        topLine = [[UIView alloc] init];
        topLine.tag = TAG_TOPLINE;
        [self addSubview:topLine];
        [topLine mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(0.5);
            make.top.equalTo(self);
            make.left.equalTo(self).offset(left);
            make.right.equalTo(self).offset(right);
        }];
    }
    topLine.backgroundColor = LINE_COLOR;
}

- (void)flo_bottomLineHide:(BOOL)hide {
    [[self viewWithTag:TAG_BOTTOMLINE] setHidden:hide];
}
- (void)flo_bottomLineLeft:(float)left right:(float)right {
    UIView *bottomLine = [self viewWithTag:TAG_BOTTOMLINE];
    if (bottomLine) {
        [bottomLine mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self).offset(left);
            make.right.equalTo(self).offset(right);
        }];
    } else {
        bottomLine = [[UIView alloc] init];
        bottomLine.tag = TAG_BOTTOMLINE;
        [self addSubview:bottomLine];
        [bottomLine mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(0.5);
            make.bottom.equalTo(self);
            make.left.equalTo(self).offset(left);
            make.right.equalTo(self).offset(right);
        }];
    }
    bottomLine.backgroundColor = LINE_COLOR;
}

- (void)flo_addLineMarginTop:(float)top left:(float)left right:(float)right {
    UIView *line = [[UIView alloc] init];
    line.tag = [self nextLineViewTag];
    [self addSubview:line];
    [line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(0.5);
        make.top.equalTo(self).offset(top);
        make.left.equalTo(self).offset(left);
        make.right.equalTo(self).offset(right);
    }];
    line.backgroundColor = LINE_COLOR;
}
- (void)flo_addLineMarginBottom:(float)bottom left:(float)left right:(float)right {
    UIView *line = [[UIView alloc] init];
    line.tag = [self nextLineViewTag];
    [self addSubview:line];
    [line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(0.5);
        make.bottom.equalTo(self).offset(-bottom);
        make.left.equalTo(self).offset(left);
        make.right.equalTo(self).offset(right);
    }];
    line.backgroundColor = LINE_COLOR;
}
- (NSInteger)nextLineViewTag {
    NSInteger nextTag = TAG_BOTTOMLINE + 1;
    
    NSArray *subV = self.subviews;
    for (UIView *v in subV) {
        if (v.tag >= nextTag && v.tag < TAG_LINE_MAX) {
            nextTag = v.tag + 1;
        }
    }
    
    return nextTag;
}

- (void)flo_setLineColor:(UIColor *)color {
    NSArray *subV = self.subviews;
    for (UIView *v in subV) {
        if (v.tag >= TAG_TOPLINE && v.tag < TAG_LINE_MAX) {
            v.backgroundColor = color;
        }
    }
}

@end
