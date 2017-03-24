//
//  FLOAdjustFontSizeView.m
//  XMPPChat
//
//  Created by 360doc on 16/8/25.
//  Copyright © 2016年 Flolangka. All rights reserved.
//

#import "FLOAdjustFontSizeView.h"

@implementation FLOAdjustFontSizeView

- (instancetype)init {
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        
        UISlider *slider = [[UISlider alloc] initWithFrame:CGRectMake(44, 44, CGRectGetWidth([UIScreen mainScreen].bounds)-88, 44)];
        slider.minimumValue = 10;
        slider.maximumValue = 30;
        slider.value = 22.;
        [slider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
        
        [self addSubview:slider];
        
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

- (void)sliderValueChanged:(UISlider *)slider {
    if (_fontSizeChanged) {
        _fontSizeChanged(slider.value);
    }
}

@end
