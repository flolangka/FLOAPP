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

+ (AFHTTPSessionManager *)sharedHTTPSession;

+ (AFURLSessionManager *)sharedURLSession;

@end
