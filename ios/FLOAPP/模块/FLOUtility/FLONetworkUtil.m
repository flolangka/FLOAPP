//
//  FLONetworkUtil.m
//  FLOAPP
//
//  Created by 360doc on 2018/1/30.
//  Copyright © 2018年 Flolangka. All rights reserved.
//

#import "FLONetworkUtil.h"

@implementation FLONetworkUtil

static AFHTTPSessionManager *httpSessionManager ;
static AFURLSessionManager *urlSessionManager ;
static AFJSONResponseSerializer *JSONResponseSerializer ;
static AFHTTPResponseSerializer *TextHTMLResponseSerializer ;

/**
 AFHTTPSessionManager单例
 
 @return 单例对象
 */
+ (AFHTTPSessionManager *)sharedHTTPSession {
    static dispatch_once_t FLONetworkUtil_onceToken;
    dispatch_once(&FLONetworkUtil_onceToken, ^{
        httpSessionManager = [AFHTTPSessionManager manager];
        httpSessionManager.requestSerializer.timeoutInterval = 10;
        httpSessionManager.responseSerializer = [self sharedJSONResponseSerializer];
    });
    return httpSessionManager;
}

/**
 json 结果解析（默认）
 */
+ (void)HTTPSessionSetJSONResponseSerializer {
    [self sharedHTTPSession].responseSerializer = [self sharedJSONResponseSerializer];
}

+ (AFJSONResponseSerializer *)sharedJSONResponseSerializer {
    static dispatch_once_t FLONetworkUtil_onceToken1;
    dispatch_once(&FLONetworkUtil_onceToken1, ^{
        JSONResponseSerializer = [AFJSONResponseSerializer serializer];
    });
    return JSONResponseSerializer;
}

/**
 text/html 结果解析，接口调用前设置，调用完成后需调用 HTTPSessionSetJSONResponseSerializer 还原
 */
+ (void)HTTPSessionSetTextHTMLResponseSerializer {
    [self sharedHTTPSession].responseSerializer = [self sharedTextHTMLResponseSerializer];
}

+ (AFHTTPResponseSerializer *)sharedTextHTMLResponseSerializer {
    static dispatch_once_t FLONetworkUtil_onceToken2;
    dispatch_once(&FLONetworkUtil_onceToken2, ^{
        TextHTMLResponseSerializer = [AFHTTPResponseSerializer serializer];
        TextHTMLResponseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    });
    return TextHTMLResponseSerializer;
}

/**
 AFURLSessionManager单例
 
 @return 单例对象
 */
+ (AFURLSessionManager *)sharedURLSession {
    static dispatch_once_t FLONetworkUtil_onceToken3;
    dispatch_once(&FLONetworkUtil_onceToken3, ^{
        urlSessionManager = [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    });
    return urlSessionManager;
}

/**
 返回结果转NSDictionary

 @param responseObject 返回结果
 @return NSDictionary
 */
+ (NSDictionary *)dictionaryResult:(id)responseObject {
    NSDictionary *result = nil;
    
    if ([responseObject isKindOfClass:[NSDictionary class]]) {
        result = (NSDictionary *)responseObject;
    } else if ([responseObject isKindOfClass:[NSData class]]) {
        result = [(NSData *)responseObject flo_objectFromJSONData];
    }
    
    return result;
}

@end
