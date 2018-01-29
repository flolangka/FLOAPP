//
//  FLOQSBKTopicItem.h
//  FLOAPP
//
//  Created by 360doc on 2018/1/29.
//  Copyright © 2018年 Flolangka. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FLOQSBKTopicItem : NSObject

@property (nonatomic, assign) float cellHeight;

+ (instancetype)itemWithDictionary:(NSDictionary *)dict;

@end
