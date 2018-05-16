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
        
        self.gradientColors = @[@[COLOR_RGB(246, 41, 55), COLOR_RGB(207, 0, 90)],
                                @[COLOR_RGB(247, 84, 130), COLOR_RGB(198, 12, 141)],
                                @[COLOR_RGB(27, 198, 109), COLOR_RGB(49, 171, 34)],
                                @[COLOR_RGB(25, 186, 187), COLOR_RGB(20, 141, 185)],
                                @[COLOR_RGB(248, 107, 27), COLOR_RGB(235, 9, 63)],
                                @[COLOR_RGB(34, 91, 223), COLOR_RGB(72, 46, 221)],
                                @[COLOR_RGB(229, 181, 26), COLOR_RGB(217, 107, 18)],
                                @[COLOR_RGB(31, 220, 140), COLOR_RGB(28, 178, 138)],
                                @[COLOR_RGB(113, 57, 252), COLOR_RGB(73, 50, 230)],
                                @[COLOR_RGB(205, 37, 180), COLOR_RGB(141, 0, 223)]];
        self.configedGradientColors = [NSMutableArray arrayWithCapacity:1];
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
        FLOWorkItemViewModel *vm = [self itemViewModelWithItem:item];
        if (vm) {
            [muarr addObject:vm];
        }
    }
    return muarr;
}

- (FLOWorkItemViewModel *)itemViewModelWithItem:(WorkList *)item {
    FLOWorkItemViewModel *vm = [[FLOWorkItemViewModel alloc] initWithItem:item];
    
    if (vm) {
        vm.cellHeight = [FLOWorkListCell heightWithViewModel:vm];
        return vm;
    }
    return nil;
}

/**
 更新dataArr
 
 @param arr 新数据
 */
- (void)updateDataArr:(NSArray <FLOWorkItemViewModel *>*)arr {
    [self.dataArr removeAllObjects];
    [self.configedGradientColors removeAllObjects];
    [self.dataArr addObject:arr];
}

/**
 添加数据
 
 @param work 数据
 @param completion 数据源更新回调
 */
- (void)addWorkList:(WorkList *)work completion:(void(^)(NSIndexPath *indexPath))completion {
    FLOWorkItemViewModel *vm = [self itemViewModelWithItem:work];
    if (vm) {
        NSMutableArray *muarr = [NSMutableArray arrayWithArray:self.dataArr.firstObject];
        [muarr addObject:vm];
        
        [self.dataArr removeAllObjects];
        [self.dataArr addObject:muarr];
        
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:muarr.count-1 inSection:0];
        if (completion) {
            completion(indexPath);
        }
    } else {
        if (completion) {
            completion(nil);
        }
    }
}

/**
 根据itemViewModel获取位置
 
 @param vm 数据
 @return 位置
 */
- (NSIndexPath *)indexPathForItemViewModel:(FLOWorkItemViewModel *)vm {
    NSIndexPath *indexPath = nil;
    
    NSInteger index = [self.dataArr.firstObject indexOfObject:vm];
    if (index >= 0) {
        indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    }
    return indexPath;
}

//配置渐变色，不能与上一个cell同一种配色
- (NSArray *)gradientColorsAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *gradientColors = nil;
    
    if (indexPath.row < _configedGradientColors.count) {
        gradientColors = _configedGradientColors[indexPath.row];
    } else {
        while (!gradientColors) {
            NSInteger index = arc4random_uniform(_gradientColors.count);
            NSArray *colorArr = _gradientColors[index];
            
            if (indexPath.row == 0) {
                gradientColors = colorArr;
            } else {
                NSArray *pColorArr = self.configedGradientColors.lastObject;
                if (![pColorArr isEqualToArray:colorArr]) {
                    gradientColors = colorArr;
                } else {
                    DLog(@" -- 颜色重复，再选一次");
                }
            }
        }
    }
    self.configedGradientColors[indexPath.row] = gradientColors;
    
    return gradientColors;
}

@end
