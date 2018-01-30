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

+ (AFHTTPSessionManager *)sharedHTTPSession {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        httpSessionManager = [AFHTTPSessionManager manager];
        httpSessionManager.responseSerializer = [AFHTTPResponseSerializer serializer];
        httpSessionManager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript",@"text/html", nil];
        httpSessionManager.requestSerializer.timeoutInterval = 10;
    });
    return httpSessionManager;
}

+ (AFURLSessionManager *)sharedURLSession {
    static dispatch_once_t onceToken2;
    dispatch_once(&onceToken2, ^{
        urlSessionManager = [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    });
    return urlSessionManager;
}

@end
