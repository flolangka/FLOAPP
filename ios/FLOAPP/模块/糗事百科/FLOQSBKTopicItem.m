//
//  FLOQSBKTopicItem.m
//  FLOAPP
//
//  Created by 360doc on 2018/1/29.
//  Copyright © 2018年 Flolangka. All rights reserved.
//

#import "FLOQSBKTopicItem.h"

@implementation FLOQSBKTopicItem

+ (instancetype)itemWithDictionary:(NSDictionary *)dict {
    if (IntStatus(dict) == 1) {
        FLOQSBKTopicItem *item = [[self alloc] init];
        [item configProperty:dict];
        
        return item;
    }
    
    return nil;
}

- (void)configProperty:(NSDictionary *)dict {
    
}

@end
