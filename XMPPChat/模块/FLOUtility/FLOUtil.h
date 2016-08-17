//
//  FLOUtil.h
//  FLOUtility
//
//  Created by 360doc on 16/7/22.
//  Copyright © 2016年 Flolangka. All rights reserved.
//

#import <Foundation/Foundation.h>
@class UIViewController;

#define DEVICE_IPAD [[[UIDevice currentDevice] model] isEqualToString:@"iPad"]
#define DEVICE_IPHONE [[[UIDevice currentDevice] model] isEqualToString:@"iPhone"]
#define DEVICE_IPODTOUCH [[[UIDevice currentDevice] model] isEqualToString:@"iPod touch"]
#define DEVICE_IOS_VERSION [[UIDevice currentDevice].systemVersion floatValue]

#define DEVICE_SCREEN_WIDTH CGRectGetWidth([UIScreen mainScreen].bounds)
#define DEVICE_SCREEN_HEIGHT CGRectGetHeight([UIScreen mainScreen].bounds)
//2倍屏、3倍屏；乘以宽高即为分辨率
#define DEVICE_SCREEN_SCALE [UIScreen mainScreen].scale


//UIColor
#define COLOR_RGB(A,B,C) [UIColor colorWithRed:(A)/255.0 green:(B)/255.0 blue:(C)/255.0 alpha:1.0]
#define COLOR_RGB3SAME(A) [UIColor colorWithRed:(A)/255.0 green:(A)/255.0 blue:(A)/255.0 alpha:1.0]

#define COLOR_RGBAlpha(A,B,C,AL) [UIColor colorWithRed:(A)/255.0 green:(B)/255.0 blue:(C)/255.0 alpha:AL]
#define COLOR_RGB3SAMEAlpha(A,AL) [UIColor colorWithRed:(A)/255.0 green:(A)/255.0 blue:(A)/255.0 alpha:AL]

#define COLOR_HEX(hexColor) [UIColor colorWithRed:(((CGFloat)((hexColor & 0xFF0000) >> 16)) / 255.0) green:(((CGFloat)((hexColor & 0xFF00) >> 8)) / 255.0) blue:(((CGFloat)(hexColor & 0xFF)) / 255.0) alpha:1.0]
#define COLOR_HEXAlpha(hexColor,falpha) [UIColor colorWithRed:(((CGFloat)((hexColor & 0xFF0000) >> 16)) / 255.0) green:(((CGFloat)((hexColor & 0xFF00) >> 8)) / 255.0) blue:(((CGFloat)(hexColor & 0xFF)) / 255.0) alpha:(falpha)]

@interface FLOUtil : NSObject

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
