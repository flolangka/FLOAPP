//
//  FLOAPPConfig.h
//  FLOAPP
//
//  Created by 360doc on 2018/4/11.
//  Copyright © 2018年 Flolangka. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FLOAPPConfig : NSObject

@property (nonatomic, assign, readonly) CGFloat screenWidth;
@property (nonatomic, assign, readonly) CGFloat screenHeight;
//2倍屏、3倍屏；乘以宽高即为分辨率
@property (nonatomic, assign, readonly) CGFloat screenScale;

@property (nonatomic, assign, readonly) BOOL    isFullScreen;
@property (nonatomic, assign, readonly) CGFloat statusBarHeight;
@property (nonatomic, assign, readonly) CGFloat navigationHeight;
@property (nonatomic, assign, readonly) CGFloat bottomAddHeight;

@property (nonatomic, assign, readonly) float iOSVersion;
@property (nonatomic, assign, readonly) BOOL  isIphone;
@property (nonatomic, assign, readonly) BOOL  isIPAD;

+ (instancetype)shareInstance;

@end
