//
//  FLORandomListViewModel.h
//  FLOAPP
//
//  Created by 360doc on 2018/10/31.
//  Copyright © 2018 Flolangka. All rights reserved.
//

#import "FLOTableViewModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface FLORandomListViewModel : FLOTableViewModel

/**
 项目名
 */
- (NSString *)cellTitleForIndexPath:(NSIndexPath *)indexPath;

/**
 选项列表
 */
- (NSArray <NSString *>*)randomListForIndexPath:(NSIndexPath *)indexPath;

@end

NS_ASSUME_NONNULL_END
