//
//  FLOAdjustFontSizeLabel.m
//  XMPPChat
//
//  Created by 360doc on 16/8/25.
//  Copyright © 2016年 Flolangka. All rights reserved.
//

#import "FLOAdjustFontSizeLabel.h"

@implementation FLOAdjustFontSizeLabel

- (instancetype)init {
    self = [super init];
    if (self) {
        self.numberOfLines = 0;
        self.edgeInsets = UIEdgeInsetsMake(10, 10, 10, 10);
    }
    return self;
}

//设置内间距
- (CGRect)textRectForBounds:(CGRect)bounds limitedToNumberOfLines:(NSInteger)numberOfLines {
    UIEdgeInsets insets = self.edgeInsets;
    CGRect rect = [super textRectForBounds:UIEdgeInsetsInsetRect(bounds, insets)
                    limitedToNumberOfLines:numberOfLines];
    
    rect.origin.x    -= insets.left;
    rect.origin.y    -= insets.top;
    rect.size.width  += (insets.left + insets.right);
    rect.size.height += (insets.top + insets.bottom);
    
    return rect;
}

- (void)drawTextInRect:(CGRect)rect {
    [super drawTextInRect:UIEdgeInsetsInsetRect(rect, self.edgeInsets)];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
