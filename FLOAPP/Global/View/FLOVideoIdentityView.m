//
//  FLOVideoIdentityView.m
//  FLOAPP
//
//  Created by 360doc on 2018/4/13.
//  Copyright © 2018年 Flolangka. All rights reserved.
//

#import "FLOVideoIdentityView.h"

@implementation FLOVideoIdentityView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

+ (instancetype)videoIdentityView {
    FLOVideoIdentityView *view = [[FLOVideoIdentityView alloc] initWithFrame:CGRectMake(0, 0, 55, 55)];
    view.image = [UIImage imageNamed:@"video_interact_icon_play"];
    view.layer.cornerRadius = 55/2.;
    view.layer.masksToBounds = YES;
    view.backgroundColor = COLOR_RGB3SAMEAlpha(0, 0.3);
    
    return view;
}

@end
