//
//  FLOUserModel.m
//  XMPPChat
//
//  Created by admin on 15/11/27.
//  Copyright © 2015年 Flolangka. All rights reserved.
//

#import "FLOUserModel.h"

@implementation FLOUserModel

- (instancetype)initWithDictionary:(NSDictionary *)infoDic
{
    self = [super init];
    if (self) {
        _userName = infoDic[@"UserName"];
        _iconURL = [NSURL URLWithString:infoDic[@"IconURL"]];
    }
    return self;
}

@end
