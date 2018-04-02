//
//  FLONetworkUtil.h
//  FLOAPP
//
//  Created by 360doc on 2018/1/30.
//  Copyright © 2018年 Flolangka. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFHTTPSessionManager.h>
#import <AFURLSessionManager.h>

@interface FLONetworkUtil : NSObject

/**
 AFHTTPSessionManager单例

 @return 单例对象
 */
+ (AFHTTPSessionManager *)sharedHTTPSession;

/**
 json 结果解析（默认）
 */
+ (void)HTTPSessionSetJSONResponseSerializer;

/**
 text/html 结果解析，接口调用前设置，调用完成后需调用 HTTPSessionSetJSONResponseSerializer 还原
 */
+ (void)HTTPSessionSetTextHTMLResponseSerializer;

/**
 AFURLSessionManager单例

 @return 单例对象
 */
+ (AFURLSessionManager *)sharedURLSession;

/**
 返回结果转NSDictionary
 
 @param responseObject 返回结果
 @return NSDictionary
 */
+ (NSDictionary *)dictionaryResult:(id)responseObject;

@end
