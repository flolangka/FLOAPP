//
//  FLOWeiboUserModel.m
//  XMPPChat
//
//  Created by admin on 15/12/17.
//  Copyright © 2015年 Flolangka. All rights reserved.
//

#import "FLOWeiboUserModel.h"

@implementation FLOWeiboUserModel

- (instancetype)initWithDictionary:(NSDictionary *)userInfo
{
    self = [super init];
    if (self) {
        self.idStr                = userInfo[@"idstr"];
        self.name                 = userInfo[@"screen_name"];
        self.level                = [userInfo[@"mbrank"] intValue];
        self.userIconURL          = userInfo[@"profile_image_url"];
        self.isVerified           = [userInfo[@"verified"] boolValue];
    }
    return self;
}

-(NSDictionary *)dictionary
{
    NSDictionary *dic = @{@"idstr":self.idStr,
                          @"screen_name":self.name,
                          @"mbrank":[NSNumber numberWithInt:self.level],
                          @"profile_image_url":self.userIconURL,
                          @"verified":[NSNumber numberWithBool:self.isVerified]
                          };
    return dic;
}

@end
