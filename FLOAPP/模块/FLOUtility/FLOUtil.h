//
//  FLOUtil.h
//  FLOUtility
//
//  Created by 360doc on 16/7/22.
//  Copyright © 2016年 Flolangka. All rights reserved.
//

#import <Foundation/Foundation.h>
@class UIViewController;

//UIColor
#define COLOR_RGB(R,G,B) [UIColor colorWithRed:(R)/255.0 green:(G)/255.0 blue:(B)/255.0 alpha:1.0]
#define COLOR_RGB3SAME(S) [UIColor colorWithRed:(S)/255.0 green:(S)/255.0 blue:(S)/255.0 alpha:1.0]

#define COLOR_RGBAlpha(R,G,B,A) [UIColor colorWithRed:(R)/255.0 green:(G)/255.0 blue:(B)/255.0 alpha:A]
#define COLOR_RGB3SAMEAlpha(S,A) [UIColor colorWithRed:(S)/255.0 green:(S)/255.0 blue:(S)/255.0 alpha:A]

#define COLOR_HEX(hexColor) [UIColor colorWithRed:(((CGFloat)((hexColor & 0xFF0000) >> 16)) / 255.0) green:(((CGFloat)((hexColor & 0xFF00) >> 8)) / 255.0) blue:(((CGFloat)(hexColor & 0xFF)) / 255.0) alpha:1.0]
#define COLOR_HEXAlpha(hexColor,falpha) [UIColor colorWithRed:(((CGFloat)((hexColor & 0xFF0000) >> 16)) / 255.0) green:(((CGFloat)((hexColor & 0xFF00) >> 8)) / 255.0) blue:(((CGFloat)(hexColor & 0xFF)) / 255.0) alpha:(falpha)]

#define DEVICE_NETWORK_CHANGE_NOTIFICATION           @"DeviceNetworkChangeNotification"
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

/**
 在Caches下创建文件夹

 @param path 文件夹路径
 */
+ (void)CreatFilePathInCaches:(NSString *)path;

/**
 文件属性

 @param path 路径
 @return 属性
 */
+ (NSDictionary *)FileAttributesInCachesPath:(NSString *)path;

/**
 bytes转21.1K/21.1M/21.1G
 
 @param bytes bytes
 @return str
 */
+ (NSString *)FileSizeWithBytes:(unsigned long long)bytes;

/**
 时间转换

 @param second 秒数
 @return 00:00:00
 */
+ (NSString *)timeH_M_SWithSecond:(NSInteger)second;

/**
 整数以万为单位
 
 @param count 整数
 @return 9999、1.1万
 */
+ (NSString *)integerStr_10000:(NSInteger)count;

/**
 *  检测网络状态
 *
 *  @return 0:无网络 1:Wifi 2:2/3/4G
 */
+ (NSInteger)networkStatus;

/**
 解析迅雷地址等转http地址

 @param path 迅雷地址等
 @return http地址
 */
+ (NSString *)parseDownloadPath:(NSString *)path;

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

#pragma mark - NSObject
@interface NSObject (FLOUtility)
/**
 全屏显示图片

 @param image 图片
 @param time 显示时间
 @param animated 隐藏动画
 */
- (void)flo_showCurtImage:(UIImage *)image time:(NSTimeInterval)time hideAnimated:(BOOL)animated;
@end


