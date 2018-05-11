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
