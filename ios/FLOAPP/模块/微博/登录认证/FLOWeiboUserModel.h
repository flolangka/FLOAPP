//
//  FLOWeiboUserModel.h
//  XMPPChat
//
//  Created by admin on 15/12/17.
//  Copyright © 2015年 Flolangka. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FLOWeiboUserModel : NSObject

@property (nonatomic, copy) NSString *idStr;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *userIconURL;
@property (nonatomic      ) BOOL     isVerified;
@property (nonatomic      ) int      level;

- (instancetype)initWithDictionary:(NSDictionary *)userInfo;

- (NSDictionary *)dictionary;

@end
