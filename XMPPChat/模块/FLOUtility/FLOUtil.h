//
//  FLOUtil.h
//  FLOUtility
//
//  Created by 360doc on 16/7/22.
//  Copyright © 2016年 Flolangka. All rights reserved.
//

#import <Foundation/Foundation.h>
@class UIViewController;

extern BOOL DEVICE_IPAD;
extern BOOL DEVICE_IPHONE;
extern BOOL DEVICE_IPODTOUCH;
extern float DEVICE_IOS_VERSION;

extern float DEVICE_SCREEN_WIDTH;
extern float DEVICE_SCREEN_HEIGHT;
extern float DEVICE_SCREEN_SCALE;   //2倍屏、3倍屏；乘以宽高即为分辨率

//UIColor
#define COLOR_RGB(A,B,C) [UIColor colorWithRed:(A)/255.0 green:(B)/255.0 blue:(C)/255.0 alpha:1.0]
#define COLOR_RGB3SAME(A) [UIColor colorWithRed:(A)/255.0 green:(A)/255.0 blue:(A)/255.0 alpha:1.0]

#define COLOR_RGBAlpha(A,B,C,AL) [UIColor colorWithRed:(A)/255.0 green:(B)/255.0 blue:(C)/255.0 alpha:AL]
#define COLOR_RGB3SAMEAlpha(A,AL) [UIColor colorWithRed:(A)/255.0 green:(A)/255.0 blue:(A)/255.0 alpha:AL]

#define COLOR_HEX(hexColor) [UIColor colorWithRed:(((CGFloat)((hexColor & 0xFF0000) >> 16)) / 255.0) green:(((CGFloat)((hexColor & 0xFF00) >> 8)) / 255.0) blue:(((CGFloat)(hexColor & 0xFF)) / 255.0) alpha:1.0]
#define COLOR_HEXAlpha(hexColor,falpha) [UIColor colorWithRed:(((CGFloat)((hexColor & 0xFF0000) >> 16)) / 255.0) green:(((CGFloat)((hexColor & 0xFF00) >> 8)) / 255.0) blue:(((CGFloat)(hexColor & 0xFF)) / 255.0) alpha:(falpha)]

@interface FLOUtil : NSObject

//配置全局变量，在程序启动时调用一次
+ (void)setup;

/**
 *  弹框，适配iOS8以前及iOS8以后，按钮为“知道了”
 *
 *  @param title 标题
 *  @param msg   信息
 *  @param VC    源VC
 */
+ (void)flo_alertWithMessage:(NSString *)msg fromVC:(UIViewController *)VC;
+ (void)flo_alertWithTitle:(NSString *)title message:(NSString *)msg fromVC:(UIViewController *)VC;

@end

#pragma mark - NSArray
@interface NSArray (FLOUtil)
- (NSData *)flo_JSONData;
- (NSString *)flo_JSONString;
@end

#pragma mark - NSDictionary
@interface NSDictionary (FLOUtil)
- (NSData *)flo_JSONData;
- (NSString *)flo_JSONString;
@end

#pragma mark - NSData
@interface NSData (FLOUtil)
- (id)flo_objectFromJSONData;
- (NSString *)flo_JSONString;
@end

#pragma mark - NSString
@interface NSString (FLOUtil)
- (id)flo_objectFromJSONString;
- (NSData *)flo_JSONData;
@end
