//
//  FLOSortViewModel.m
//  FLOAPP
//
//  Created by 360doc on 2018/4/27.
//  Copyright © 2018年 Flolangka. All rights reserved.
//

#import "FLOSortViewModel.h"

@interface FLOSortViewModel ()

@property (nonatomic, assign, readwrite) NSUInteger sortNumber;

@end

@implementation FLOSortViewModel

- (instancetype)init {
    self = [super init];
    if (self) {
        self.title = @"排序";
        
        self.sorting = NO;
        self.sortNumber = 200;
    }
    return self;
}

@end
