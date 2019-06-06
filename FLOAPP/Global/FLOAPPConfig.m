//
//  FLOAPPConfig.m
//  FLOAPP
//
//  Created by 360doc on 2018/4/11.
//  Copyright © 2018年 Flolangka. All rights reserved.
//

#import "FLOAPPConfig.h"

@interface FLOAPPConfig ()

@property (nonatomic, assign, readwrite) CGFloat screenWidth;
@property (nonatomic, assign, readwrite) CGFloat screenHeight;
//2倍屏、3倍屏；乘以宽高即为分辨率
@property (nonatomic, assign, readwrite) CGFloat screenScale;

@property (nonatomic, assign, readwrite) BOOL    isFullScreen;
@property (nonatomic, assign, readwrite) CGFloat statusBarHeight;
@property (nonatomic, assign, readwrite) CGFloat navigationHeight;
@property (nonatomic, assign, readwrite) CGFloat bottomAddHeight;

@property (nonatomic, assign, readwrite) float iOSVersion;
@property (nonatomic, assign, readwrite) BOOL  isIphone;
@property (nonatomic, assign, readwrite) BOOL  isIPAD;


@end

@implementation FLOAPPConfig

static FLOAPPConfig *shareAppConfig;
+ (instancetype)shareInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareAppConfig = [[FLOAPPConfig alloc] init];
        [shareAppConfig config];
    });
    return shareAppConfig;
}

- (void)config {
    _screenWidth = CGRectGetWidth([UIScreen mainScreen].bounds);
    _screenHeight = CGRectGetHeight([UIScreen mainScreen].bounds);
    _screenScale = [UIScreen mainScreen].scale;
    
    _iOSVersion = [[UIDevice currentDevice].systemVersion floatValue];
    _isIPAD     = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad;
    _isIphone   = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone;
    
    _statusBarHeight = [UIApplication sharedApplication].statusBarFrame.size.height;
    _navigationHeight = ((_isIPAD && _iOSVersion >= 12.0) ? 50 : 44) + _statusBarHeight;
    _isFullScreen = ({
        BOOL fullScreen = NO;
        if (@available(iOS 11.0, *))
            if ([UIApplication sharedApplication].delegate.window.safeAreaInsets.bottom != 0)
                fullScreen = YES;
        
        fullScreen;
    });
    _bottomAddHeight = ({
        float bottom = 0;
        if (@available(iOS 11.0, *))
            bottom = [UIApplication sharedApplication].delegate.window.safeAreaInsets.bottom;
        
        bottom;
    });    
}

@end
