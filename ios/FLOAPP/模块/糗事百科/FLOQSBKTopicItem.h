//
//  FLOQSBKTopicItem.h
//  FLOAPP
//
//  Created by 360doc on 2018/1/29.
//  Copyright © 2018年 Flolangka. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FLOQSBKTopicItem : NSObject

@property (nonatomic, copy  ) NSString *userIcon;
@property (nonatomic, copy  ) NSString *userName;
@property (nonatomic, copy  ) NSString *createTime;
@property (nonatomic, copy  ) NSString *content;
@property (nonatomic, copy  ) NSArray  *pictures;

+ (instancetype)itemWithDictionary:(NSDictionary *)dict;

@end
