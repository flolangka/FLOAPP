//
//  FLOSortClass.h
//  FLOAPP
//
//  Created by 360doc on 2018/4/27.
//  Copyright © 2018年 Flolangka. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, FLOSortType) {
    FLOSortTypeBubble = 0,
    FLOSortTypeSelect,
    FLOSortTypeInsert,
    FLOSortTypeShell,
    FLOSortTypeHeap,
    FLOSortTypeMerge,
    FLOSortTypeQuick,
    FLOSortTypeRadix,
};

@interface FLOSortClass : NSObject

@property (nonatomic, copy  ) void(^indexValueChanged)(NSInteger index, float value);
@property (nonatomic, copy  ) void(^finished)(void);

- (void)sort:(NSArray *)arr type:(FLOSortType)type;

+ (NSArray *)sortTypes;

@end
