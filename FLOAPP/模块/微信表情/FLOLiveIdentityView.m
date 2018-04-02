//
//  FLOLiveIdentityView.m
//  FLOAPP
//
//  Created by 360doc on 2018/3/12.
//  Copyright © 2018年 Flolangka. All rights reserved.
//

#import "FLOLiveIdentityView.h"

@implementation FLOLiveIdentityView

- (instancetype)init {
    self = [super init];
    if (self) {
        self.bounds = CGRectMake(0, 0, 45, 20);
        self.backgroundColor = COLOR_RGB3SAMEAlpha(255, 0.7);
        
        UIImageView *imageV = [[UIImageView alloc] initWithFrame:CGRectMake(3, 3, 14, 14)];
        imageV.image = [UIImage imageNamed:@"icon_live_photo"];
        [self addSubview:imageV];
        
        //LIVE文字有一些偏下，so提高一点
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(20, -2, 22, 20)];
        label.text = @"LIVE";
        label.textColor = COLOR_RGB3SAME(137);
        label.textAlignment = NSTextAlignmentCenter;
        label.adjustsFontSizeToFitWidth = YES;
        [self addSubview:label];
    }
    return self;
}

@end
