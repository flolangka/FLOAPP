//
//  FLOFriendApplyModel.m
//  XMPPChat
//
//  Created by admin on 15/11/27.
//  Copyright © 2015年 Flolangka. All rights reserved.
//

#import "FLOFriendApplyModel.h"

@implementation FLOFriendApplyModel

- (instancetype)initWithDictionary:(NSDictionary *)infoDic
{
    self = [super init];
    if (self) {
        _sourceUser = infoDic[@"SourceUser"];
        _targetUser = infoDic[@"TargetUser"];
        _applyRemark = infoDic[@"ApplyRemark"];
        _applyState = [infoDic[@"ApplyState"] unsignedIntegerValue];
    }
    return self;
}

@end
