//
//  FLOWorkListViewModel.m
//  FLOAPP
//
//  Created by 沈敏 on 2018/5/8.
//  Copyright © 2018年 Flolangka. All rights reserved.
//

#import "FLOWorkListViewModel.h"

@implementation FLOWorkListViewModel

- (instancetype)init {
    self = [super init];
    if (self) {        
        self.tableViewStyle = UITableViewStylePlain;
        self.dataArr = [NSMutableArray arrayWithObject:[NSMutableArray arrayWithCapacity:1]];
        
        [self.dataArr.firstObject addObject:@"1"];
    }
    return self;
}

@end
