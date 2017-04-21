//
//  FLOUtil.m
//  FLOUtility
//
//  Created by 360doc on 16/7/22.
//  Copyright © 2016年 Flolangka. All rights reserved.
//

#import "FLOUtil.h"
#import <UIKit/UIKit.h>
#import <AFNetworkReachabilityManager.h>

@implementation FLOUtil

+ (void)flo_alertWithMessage:(NSString *)msg fromVC:(UIViewController *)VC {
    if (DEVICE_IOS_VERSION >= 8 && DEVICE_IPHONE) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:msg preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleCancel handler:nil]];
        [VC presentViewController:alertController animated:YES completion:nil];
    }
}

+ (void)flo_alertWithTitle:(NSString *)title message:(NSString *)msg fromVC:(UIViewController *)VC {
    if (DEVICE_IOS_VERSION >= 8 && DEVICE_IPHONE) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:msg preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleCancel handler:nil]];
        [VC presentViewController:alertController animated:YES completion:nil];
    }
}

/**
 *  在Caches下查找文件name地址
 *
 *  @param name 文件名
 *
 *  @return 文件地址
 */
+ (NSString *)FilePathInCachesWithName:(NSString *)name {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *LibraryDirectory = [paths objectAtIndex:0];
    return [LibraryDirectory stringByAppendingPathComponent:name];
}

/**
 删除文件

 @param Path 文件路径
 */
+ (void)DropFilePath:(NSString *)Path {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager removeItemAtPath:Path error:nil];
}

//在Caches下创建文件夹name
+ (void)CreatFilePathInCaches:(NSString *)path {
    NSString *imageDir = [self FilePathInCachesWithName:path];
    BOOL isDir = NO;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL existed = [fileManager fileExistsAtPath:imageDir isDirectory:&isDir];
    if ( !(isDir == YES && existed == YES) ){
        [fileManager createDirectoryAtPath:imageDir withIntermediateDirectories:YES attributes:nil error:nil];
    }
}

/**
 文件属性
 
 @param path 路径
 @return 属性
 */
+ (NSDictionary *)FileAttributesInCachesPath:(NSString *)path {
    return [[NSFileManager defaultManager] attributesOfItemAtPath:[self FilePathInCachesWithName:path] error:nil];
}

/**
 bytes转21.1K/21.1M/21.1G

 @param bytes bytes
 @return str
 */
+ (NSString *)FileSizeWithBytes:(unsigned long long)bytes {
    NSString *size;
    if (bytes < 1024) {
        size = [NSString stringWithFormat:@"%llubytes",bytes];
    } else if (bytes < 1024*1024) {
        size = [NSString stringWithFormat:@"%.1fKB",bytes/1024.];
    } else if (bytes >= 1024*1024 && bytes < 1024*1024*1024){
        size = [NSString stringWithFormat:@"%.1fM",bytes/1024.0/1024.0];
    } else {
        size = [NSString stringWithFormat:@"%.1fG",bytes/1024.0/1024.0/1024.0];
    }
    return size;
}

/**
  *  检测网络状态
  *
  *  @return 0:无网络 1:Wifi 2:2/3/4G
  */
+ (NSInteger)networkStatus {
    AFNetworkReachabilityStatus status = [AFNetworkReachabilityManager sharedManager].networkReachabilityStatus;
    
    if (status == AFNetworkReachabilityStatusReachableViaWiFi) {
        return 1;
    } else if (status == AFNetworkReachabilityStatusReachableViaWWAN) {
        return 2;
    } else {
        return 0;
    }
}

/**
 解析迅雷地址等转http地址
 
 @param path 迅雷地址等
 @return http地址
 */
+ (NSString *)parseDownloadPath:(NSString *)path {
    NSString *strUrl = path;
    // 解析迅雷
    if ([strUrl hasPrefix:@"thunder://"]) {
        NSData *data = [self dataWithBase64String:[strUrl substringFromIndex:10]];
        
        NSString *parseUrl = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
        strUrl = [parseUrl substringWithRange:NSMakeRange(2, parseUrl.length-4)];
    }
    
    if ([strUrl hasPrefix:@"http://"] || [strUrl hasPrefix:@"https://"]) {
        return strUrl;
    } else if ([strUrl hasPrefix:@"ed2k://"]) {
        Def_MBProgressString(@"暂不支持电驴资源");
        return nil;
    } else {
        return path;
    }
}
+ (NSData *)dataWithBase64String:(NSString *)str {
    NSData *data = nil;
    NSString *s = str;
    do {
        data = [[NSData alloc] initWithBase64EncodedString:s options:0];
        s = [s stringByAppendingString:@"="];
    } while (data == nil);
    return data;
}

@end

#pragma mark - NSArray
@implementation NSArray (FLOJSON)
- (NSData *)flo_JSONData {
    if (self == nil) {return nil;}
    if ([NSJSONSerialization isValidJSONObject:self])
    {
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:self options:NSJSONWritingPrettyPrinted error:nil];
        return jsonData;
    }
    return nil;
}

- (NSString *)flo_JSONString {
    if (self == nil) {return nil;}
    if ([NSJSONSerialization isValidJSONObject:self])
    {
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:self options:NSJSONWritingPrettyPrinted error:nil];
        NSString *json =[[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        return json;
    }
    return nil;
}
@end

#pragma mark - NSDictionary
@implementation NSDictionary (FLOJSON)
- (NSData *)flo_JSONData {
    if (self == nil) {return nil;}
    if ([NSJSONSerialization isValidJSONObject:self])
    {
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:self options:NSJSONWritingPrettyPrinted error:nil];
        return jsonData;
    }
    return nil;
}

- (NSString *)flo_JSONString {
    if (self == nil) {return nil;}
    if ([NSJSONSerialization isValidJSONObject:self])
    {
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:self options:NSJSONWritingPrettyPrinted error:nil];
        NSString *json =[[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        return json;
    }
    return nil;
}
@end

#pragma mark - NSData
@implementation NSData (FLOJSON)
- (id)flo_objectFromJSONData {
    if (self == nil) {return nil;}
    id result = [NSJSONSerialization JSONObjectWithData:self options:NSJSONReadingAllowFragments error:nil];
    return result;
}

- (NSString *)flo_JSONString {
    if (self == nil) {return nil;}
    NSString *json =[[NSString alloc] initWithData:self encoding:NSUTF8StringEncoding];
    return json;
}
@end

#pragma mark - NSString
@implementation NSString (FLOJSON)
- (id)flo_objectFromJSONString {
    if (self == nil) {return nil;}
    NSMutableString *string_self = [[NSMutableString alloc] initWithCapacity:1];
    if (self.length > 1) {
        if ([self characterAtIndex:0] == '(' && [self characterAtIndex:(self.length - 1) == ')']) {
            [string_self appendString:[self stringByPaddingToLength:(self.length - 1) withString:@"" startingAtIndex:1]];
            NSRange rang = [string_self rangeOfString:@"("];
            [string_self deleteCharactersInRange:rang];
        }else{
            [string_self appendString:self];
        }
    }else{
        [string_self appendString:@""];
    }
    
    [string_self replaceOccurrencesOfString:@"\n"
                                 withString:@""
                                    options:NSLiteralSearch
                                      range:NSMakeRange(0, [string_self length])];
    [string_self replaceOccurrencesOfString:@"\r"
                                 withString:@""
                                    options:NSLiteralSearch
                                      range:NSMakeRange(0, [string_self length])];
    [string_self replaceOccurrencesOfString:@"\t"
                                 withString:@""
                                    options:NSLiteralSearch
                                      range:NSMakeRange(0, [string_self length])];
    [string_self replaceOccurrencesOfString:@"\b"
                                 withString:@""
                                    options:NSLiteralSearch
                                      range:NSMakeRange(0, [string_self length])];
    
    NSData* data = [string_self dataUsingEncoding:NSUTF8StringEncoding];
    
    return [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
}

- (NSData *)flo_JSONData {
    if (self == nil) {return nil;}
    NSMutableString *string_self = [[NSMutableString alloc] initWithCapacity:1];
    if (self.length > 1) {
        if ([self characterAtIndex:0] == '(' && [self characterAtIndex:(self.length - 1) == ')']) {
            [string_self appendString:[self stringByPaddingToLength:(self.length - 1) withString:@"" startingAtIndex:1]];
            NSRange rang = [string_self rangeOfString:@"("];
            [string_self deleteCharactersInRange:rang];
        }else{
            [string_self appendString:self];
        }
    }else{
        [string_self appendString:@""];
    }
    [string_self replaceOccurrencesOfString:@"\n"
                                 withString:@""
                                    options:NSLiteralSearch
                                      range:NSMakeRange(0, [string_self length])];
    [string_self replaceOccurrencesOfString:@"\r"
                                 withString:@""
                                    options:NSLiteralSearch
                                      range:NSMakeRange(0, [string_self length])];
    [string_self replaceOccurrencesOfString:@"\t"
                                 withString:@""
                                    options:NSLiteralSearch
                                      range:NSMakeRange(0, [string_self length])];
    [string_self replaceOccurrencesOfString:@"\b"
                                 withString:@""
                                    options:NSLiteralSearch
                                      range:NSMakeRange(0, [string_self length])];
    
    NSData *data = [string_self dataUsingEncoding:NSUTF8StringEncoding];
    return data;
}
@end
