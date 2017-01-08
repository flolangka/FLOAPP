//
//  MQTTService.h
//  FLOAPP
//
//  Created by 沈敏 on 2017/1/7.
//  Copyright © 2017年 Flolangka. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MQTTService : NSObject

@property (nonatomic, copy) void(^eventAction)(NSInteger, NSString *);

+ (instancetype)shareService;

- (void)connectToServer;
- (void)close;

@end
