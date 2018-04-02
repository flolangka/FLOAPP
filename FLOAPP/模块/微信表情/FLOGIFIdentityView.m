//
//  FLOGIFIdentityView.m
//  FLOAPP
//
//  Created by 360doc on 2018/3/12.
//  Copyright © 2018年 Flolangka. All rights reserved.
//

#import "FLOGIFIdentityView.h"

@implementation FLOGIFIdentityView

- (instancetype)init {
    self = [super init];
    if (self) {
        self.bounds = CGRectMake(0, 0, 30, 23);
        
        //灰色背景，白色文字
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(3, 3, 24, 17)];
        label.text = @"GIF";
        label.textColor = COLOR_RGB3SAME(255);
        label.backgroundColor = COLOR_RGB3SAMEAlpha(137, 0.8);
        label.textAlignment = NSTextAlignmentCenter;
        label.font = [UIFont systemFontOfSize:10];
        [self addSubview:label];
        
        //白色圆角边框
        label.layer.cornerRadius = 3;
        label.layer.masksToBounds = YES;
        label.layer.borderWidth = 1;
        label.layer.borderColor = COLOR_RGB3SAME(255).CGColor;
    }
    return self;
}

@end
