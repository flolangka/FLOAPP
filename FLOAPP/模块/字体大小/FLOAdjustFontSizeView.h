//
//  FLOAdjustFontSizeView.h
//  XMPPChat
//
//  Created by 360doc on 16/8/25.
//  Copyright © 2016年 Flolangka. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FLOAdjustFontSizeView : UIView

@property (nonatomic, copy) void(^fontSizeChanged)(CGFloat);

@end
