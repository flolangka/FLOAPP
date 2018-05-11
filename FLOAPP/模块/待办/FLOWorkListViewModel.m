//
//  FLOWorkListViewModel.m
//  FLOAPP
//
//  Created by 沈敏 on 2018/5/8.
//  Copyright © 2018年 Flolangka. All rights reserved.
//

#import "FLOWorkListViewModel.h"
#import "FLOWorkListCell.h"

@implementation FLOWorkListViewModel

- (instancetype)init {
    self = [super init];
    if (self) {        
        self.tableViewStyle = UITableViewStylePlain;
        self.dataArr = [NSMutableArray arrayWithObject:@[]];        
    }
    return self;
}

/**
 获取数据
 
 @param status 0、1、2
 @return 数据源
 */
- (NSArray <FLOWorkItemViewModel *>*)workItemViewModelsAtStatus:(NSInteger)status {
    NSArray *worlList = [WorkList workListAtStatus:status];
    
    NSMutableArray <FLOWorkItemViewModel *>*muarr = [NSMutableArray arrayWithCapacity:worlList.count];
    for (WorkList *item in worlList) {
        FLOWorkItemViewModel *vm = [[FLOWorkItemViewModel alloc] initWithItem:item];
        
        if (vm) {
            vm.cellHeight = [FLOWorkListCell heightWithViewModel:vm];
            [muarr addObject:vm];
        }
    }
    return muarr;
}

@end
