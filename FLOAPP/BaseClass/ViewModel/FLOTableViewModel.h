//
//  FLOTableViewModel.h
//  FLOAPP
//
//  Created by 360doc on 2018/4/4.
//  Copyright © 2018年 Flolangka. All rights reserved.
//

#import "FLOBaseViewModel.h"

@interface FLOTableViewModel : FLOBaseViewModel

@property (nonatomic, assign) UITableViewStyle tableViewStyle;

// 数据源 @[@[], @[]], 每个小数组为一个section的数据
@property (nonatomic, strong) NSMutableArray *dataArr;

@end
