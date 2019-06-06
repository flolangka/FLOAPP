//
//  FLOWorkListViewModel.h
//  FLOAPP
//
//  Created by 沈敏 on 2018/5/8.
//  Copyright © 2018年 Flolangka. All rights reserved.
//

#import "FLOTableViewModel.h"
#import "FLOWorkItemViewModel.h"
#import "WorkList+CoreDataClass.h"

@interface FLOWorkListViewModel : FLOTableViewModel

/**
 获取数据

 @param status 0、1、2
 @return 数据源
 */
- (NSArray <FLOWorkItemViewModel *>*)workItemViewModelsAtStatus:(NSInteger)status;

/**
 更新dataArr

 @param arr 新数据
 */
- (void)updateDataArr:(NSArray <FLOWorkItemViewModel *>*)arr;

/**
 添加数据

 @param work 数据
 @param completion 数据源更新回调
 */
- (void)addWorkList:(WorkList *)work completion:(void(^)(NSIndexPath *indexPath))completion;

/**
 获取数据位置

 @param vm 数据
 @return 位置
 */
- (NSIndexPath *)indexPathForItemViewModel:(FLOWorkItemViewModel *)vm;

/**
 删除数据并返回位置
 
 @param vm 数据
 @return 位置
 */
- (NSIndexPath *)indexPathForRemoveItemViewModel:(FLOWorkItemViewModel *)vm;

//配置渐变色，不能与上一个cell同一种配色
- (NSArray *)gradientColorsAtIndexPath:(NSIndexPath *)indexPath;

@end
