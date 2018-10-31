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
 项目名
 */
- (NSString *)cellTitleForIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *dic = [self.dataArr.firstObject objectAtIndex:indexPath.row];
    if (Def_CheckDictionaryClassAndCount(dic)) {
        
    }
    return nil;
}

/**
 选项列表
 */
- (NSArray <NSString *>*)randomListForIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *dic = [self.dataArr.firstObject objectAtIndex:indexPath.row];
    if (Def_CheckDictionaryClassAndCount(dic)) {
        
    }
    return nil;
}

@end
