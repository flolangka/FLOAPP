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

@end
