//
//  FLOAdjustFontSizeView.m
//  XMPPChat
//
//  Created by 360doc on 16/8/25.
//  Copyright © 2016年 Flolangka. All rights reserved.
//

#import "FLOAdjustFontSizeView.h"
#import <Masonry.h>

@interface AdjustFontSizeSlider : UIView

@property (nonatomic, copy) void(^valueChanged)(NSInteger value);
- (void)updateValue:(NSInteger)value;

@end

@implementation FLOAdjustFontSizeView

- (instancetype)init {
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        
        DOCWeakObj(self);
        AdjustFontSizeSlider *fontSizeSlider = [[AdjustFontSizeSlider alloc] initWithFrame:CGRectMake(44, 50, CGRectGetWidth([UIScreen mainScreen].bounds)-88, 44)];
        fontSizeSlider.valueChanged = ^(NSInteger value) {
            [weakself sliderFontSizeValueChanged:value];
        };        
        [self addSubview:fontSizeSlider];
        
        UILabel *smallLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, 30, 8, 20)];
        smallLabel.text = @"A";
        smallLabel.font = [UIFont systemFontOfSize:10];
        [self addSubview:smallLabel];
        
        UILabel *bigLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetWidth([UIScreen mainScreen].bounds)-54, 30, 20, 20)];
        bigLabel.text = @"A";
        bigLabel.font = [UIFont systemFontOfSize:30];
        [self addSubview:bigLabel];
    }
    return self;
}

- (void)sliderFontSizeValueChanged:(NSInteger)value {
    if (_fontSizeChanged) {
        _fontSizeChanged(value*5 + 10);
    }
}

@end

@interface AdjustFontSizeSlider ()

@property (nonatomic, assign) NSInteger size;
@property (nonatomic, assign) float space;
@property (nonatomic, strong) UIImageView *imageV;

@end

@implementation AdjustFontSizeSlider

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.size = 3;
        self.space = ceilf(CGRectGetWidth(frame)/4.);
        
        // 档位条
        self.layer.contents = (id)[AdjustFontSizeSlider imageWithWidth:CGRectGetWidth(frame) height:CGRectGetHeight(frame)].CGImage;
        
        // 滑动圆点
        self.imageV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Slider Bar Knob"]];
        [self addSubview:_imageV];
        [_imageV mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self);
            make.size.mas_equalTo(CGSizeMake(33, 33));
            make.centerX.equalTo(self.mas_left).offset(_size*_space);
        }];
    }
    return self;
}

- (void)updateValue:(NSInteger)value {
    if (_size != value) {
        _size = value;
        
        [_imageV mas_updateConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.mas_left).offset(_size*_space);
        }];
    }
}

#pragma mark - 触摸滑动事件
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    CGPoint point = [touches.allObjects.firstObject locationInView:self];
    
    [_imageV mas_updateConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.mas_left).offset(point.x);
    }];
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    CGPoint point = [touches.allObjects.firstObject locationInView:self];
    
    // 图标中心控制在滑条内
    float centerx = point.x;
    centerx = MIN(centerx, CGRectGetWidth(self.frame));
    centerx = MAX(centerx, 0);
    
    [_imageV mas_updateConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.mas_left).offset(centerx);
    }];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    CGPoint point = [touches.allObjects.firstObject locationInView:self];
    
    NSInteger touchFontSize = [self fontSizeOfPointX:point.x];
    _size = touchFontSize;
    [_imageV mas_updateConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.mas_left).offset(_size*_space);
    }];
    
    if (_valueChanged) {
        _valueChanged(_size);
    }
}

// 根据用户触摸位置获取档位
- (NSInteger)fontSizeOfPointX:(float)pointx {
    NSInteger fontSize = 0;
    float smallSpace = _space/2.;
    
    if (pointx < smallSpace) {
        fontSize = 0;
    } else if (pointx < smallSpace*3) {
        fontSize = 1;
    } else if (pointx < smallSpace*5) {
        fontSize = 2;
    } else if (pointx < smallSpace*7) {
        fontSize = 3;
    } else {
        fontSize = 4;
    }
    return fontSize;
}

#pragma mark - 画背景图
+ (UIImage *)imageWithWidth:(float)width height:(float)height {
    float space = ceilf(width/4.);
    float top = (height-8)/2.;
    
    CGSize size = CGSizeMake(width, height);
    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSetStrokeColorWithColor(ctx, COLOR_HEX(0x979898).CGColor);
    
    {
        const CGPoint points[] = {0, height/2., width, height/2.};
        CGContextAddLines(ctx, points, 2);
    }
    {
        const CGPoint points[] = {1, top, 1, top+8};
        CGContextAddLines(ctx, points, 2);
    }
    {
        const CGPoint points[] = {space, top, space, top+8};
        CGContextAddLines(ctx, points, 2);
    }
    {
        const CGPoint points[] = {2*space, top, 2*space, top+8};
        CGContextAddLines(ctx, points, 2);
    }
    {
        const CGPoint points[] = {3*space, top, 3*space, top+8};
        CGContextAddLines(ctx, points, 2);
    }
    {
        const CGPoint points[] = {width-1, top, width-1, top+8};
        CGContextAddLines(ctx, points, 2);
    }
    
    CGContextStrokePath(ctx);
    
    // 从当前位图上下文中，取出当前画布上的图片
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    // 关闭位图上下文
    UIGraphicsEndImageContext();
    return image;
}

@end
