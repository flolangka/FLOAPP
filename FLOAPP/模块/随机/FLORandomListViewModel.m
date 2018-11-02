//
//  FLORandomListViewModel.m
//  FLOAPP
//
//  Created by 360doc on 2018/10/31.
//  Copyright © 2018 Flolangka. All rights reserved.
//

#import "FLORandomListViewModel.h"

@implementation FLORandomListViewModel

- (instancetype)init {
    self = [super init];
    if (self) {
        self.title = @"这就是命";
        
        self.tableViewStyle = UITableViewStylePlain;
        self.dataArr = [NSMutableArray arrayWithObject:[NSMutableArray arrayWithCapacity:1]];
    }
    return self;
}

/**
 刷新数据
 */
- (void)reloadData {
    NSArray *arr = [Random allItems];
    
    [self.dataArr.firstObject removeAllObjects];
    [self.dataArr.firstObject addObjectsFromArray:arr];
}

/**
 根据indexPath获取随机项目
 */
- (Random *)randomForIndexPath:(NSIndexPath *)indexPath {
    Random *model = [self.dataArr.firstObject objectAtIndex:indexPath.row];
    return model;
}

@end
