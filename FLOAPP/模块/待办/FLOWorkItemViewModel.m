//
//  FLOWorkItemViewModel.m
//  FLOAPP
//
//  Created by 360doc on 2018/5/10.
//  Copyright © 2018年 Flolangka. All rights reserved.
//

#import "FLOWorkItemViewModel.h"
#import "WorkList+CoreDataClass.h"

@implementation FLOWorkItemViewModel

- (instancetype)initWithItem:(WorkList *)item {
    self = [super init];
    if (self) {
        _item = item;
        
    }
    return self;
}



@end
