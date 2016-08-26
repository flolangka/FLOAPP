//
//  UILabel+FLOUtil.m
//  FLOUtility
//
//  Created by 360doc on 16/7/22.
//  Copyright © 2016年 Flolangka. All rights reserved.
//

#import "UILabel+FLOUtil.h"

@implementation UILabel (FLOUtil)

- (void)flo_adjustBoundsWithText:(NSString *)text font:(UIFont *)font maxWidth:(CGFloat)maxWidth maxHeight:(CGFloat)maxHeight {
    self.font = font;
    self.text = text;
    
    CGSize size = [self sizeThatFits:CGSizeMake(maxWidth, maxHeight)];
    
    CGRect frame = self.frame;
    frame.size = size;
    self.frame = frame;
}

@end
