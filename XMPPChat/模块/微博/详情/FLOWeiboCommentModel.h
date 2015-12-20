//
//  FLOWeiboCommentModel.h
//  XMPPChat
//
//  Created by admin on 15/12/20.
//  Copyright © 2015年 Flolangka. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FLOWeiboStatusModel;
@class FLOWeiboUserModel;

@interface FLOWeiboCommentModel : NSObject

@property (nonatomic, copy) NSString *time;
@property (nonatomic, copy) NSString *source;
@property (nonatomic, copy) NSString *commentsID;
@property (nonatomic, copy) NSString *commentsText;
@property (nonatomic, strong) FLOWeiboUserModel *userInfo;
@property (nonatomic, strong) FLOWeiboStatusModel *status;

- (instancetype)initWithDictionary:(NSDictionary *)dic;

@end
