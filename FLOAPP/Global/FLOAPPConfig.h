//
//  FLOAPPConfig.h
//  FLOAPP
//
//  Created by 360doc on 2018/4/11.
//  Copyright © 2018年 Flolangka. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FLOAPPConfig : NSObject

@property (nonatomic, assign, readonly) float screenWidth;
@property (nonatomic, assign, readonly) float screenHeight;

@property (nonatomic, assign, readonly) BOOL iPhoneX;
@property (nonatomic, assign, readonly) float statusBarHeight;
@property (nonatomic, assign, readonly) float navigationBarHeight;
@property (nonatomic, assign, readonly) float iPhoneXBottomHeight;

+ (instancetype)shareInstance;

@end
