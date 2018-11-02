//
//  FLORandomListViewModel.h
//  FLOAPP
//
//  Created by 360doc on 2018/10/31.
//  Copyright © 2018 Flolangka. All rights reserved.
//

#import "FLOTableViewModel.h"
#import "Random+CoreDataClass.h"

NS_ASSUME_NONNULL_BEGIN

@interface FLORandomListViewModel : FLOTableViewModel

/**
 刷新数据
 */
- (void)reloadData;

/**
 根据indexPath获取随机项目
 */
- (Random *)randomForIndexPath:(NSIndexPath *)indexPath;

@end

NS_ASSUME_NONNULL_END
