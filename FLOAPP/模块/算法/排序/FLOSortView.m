//
//  FLOSortView.m
//  FLOAPP
//
//  Created by 360doc on 2018/4/27.
//  Copyright © 2018年 Flolangka. All rights reserved.
//

#import "FLOSortView.h"

@implementation FLOSortView

- (void)updateHeight:(CGFloat)height {
    [self setFrame:CGRectMake(self.left, self.superview.height - height, self.width, height)];
    [self setBackgroundColor:[UIColor colorWithHue:self.height/self.superview.height saturation:1 brightness:1 alpha:1]];
}

@end
