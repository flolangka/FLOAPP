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

#define DEVICE_NETWORK_CHANGE_NOTIFICATION         @"DeviceNetworkChangeNotification"
#define DEVICE_NETWORK_CHANGE_2_NONE_NOTIFICATION    @"DeviceNetworkChange2NoneNotification"
#define DEVICE_NETWORK_CHANGE_2_WIFI_NOTIFICATION    @"DeviceNetworkChange2WifiNotification"
#define DEVICE_NETWORK_CHANGE_2_VIAWWAN_NOTIFICATION @"DeviceNetworkChange2ViaWWANNotification"

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

/**
 *  在Caches下查找文件name地址
 *  @param name 文件名
 *  @return 文件地址
 */
+ (NSString *)FilePathInCachesWithName:(NSString *)name;

/**
 删除文件
 
 @param Path 文件路径
 */
+ (void)DropFilePath:(NSString *)Path;

//在Caches下创建文件夹name
+ (void)CreatFilePathInCachesWithName:(NSString *)name;

/**
 *  检测网络状态
 *
 *  @return 0:无网络 1:Wifi 2:2/3/4G
 */
+ (NSInteger)networkStatus;

@end

#pragma mark - NSArray
@interface NSArray (FLOJSON)
- (NSData *)flo_JSONData;
- (NSString *)flo_JSONString;
@end

#pragma mark - NSDictionary
@interface NSDictionary (FLOJSON)
- (NSData *)flo_JSONData;
- (NSString *)flo_JSONString;
@end

#pragma mark - NSData
@interface NSData (FLOJSON)
- (id)flo_objectFromJSONData;
- (NSString *)flo_JSONString;
@end

#pragma mark - NSString
@interface NSString (FLOJSON)
- (id)flo_objectFromJSONString;
- (NSData *)flo_JSONData;
@end
