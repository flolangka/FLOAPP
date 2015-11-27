//
//  FLOFriendApplyModel.h
//  XMPPChat
//
//  Created by admin on 15/11/27.
//  Copyright © 2015年 Flolangka. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FLOUserModel;

typedef enum : NSUInteger {
    FriendApplyStateWait = 0,
    FriendApplyStateYES,
    FriendApplyStateNO,
} FriendApplyState;

@interface FLOFriendApplyModel : NSObject

@property (nonatomic, strong) FLOUserModel *sourceUser;
@property (nonatomic, strong) FLOUserModel *targetUser;
@property (nonatomic, copy) NSString *applyRemark;  //申请留言、备注
@property (nonatomic) FriendApplyState applyState;

- (instancetype)initWithDictionary:(NSDictionary *)infoDic;

@end
