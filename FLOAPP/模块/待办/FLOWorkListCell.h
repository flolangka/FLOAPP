//
//  FLOWorkListCell.h
//  FLOAPP
//
//  Created by 360doc on 2018/5/10.
//  Copyright © 2018年 Flolangka. All rights reserved.
//

#import <UIKit/UIKit.h>
@class FLOWorkItemViewModel;
@class FLOWorkListCell;

@protocol FLOWorkListCellDelegate<NSObject>

- (void)workListCell:(FLOWorkListCell *)cell targetSelected:(BOOL)selected atIndex:(NSInteger)index;
- (void)workListCellClickFinishButton:(FLOWorkListCell *)cell;
- (void)workListCellClickTitleLeftButton:(FLOWorkListCell *)cell;
- (void)workListCellClickTitleRightButton:(FLOWorkListCell *)cell;

@end

@interface FLOWorkListCell : UITableViewCell

@property (nonatomic, strong, readonly) FLOWorkItemViewModel *viewModel;

@property (nonatomic, weak  ) id <FLOWorkListCellDelegate> delegate;

//显示内容
- (void)bindViewModel:(FLOWorkItemViewModel *)viewModel;
//渐变颜色
- (void)gradientStartColor:(UIColor *)startColor endColor:(UIColor *)endColor;

//计算cell高度
+ (float)heightWithViewModel:(FLOWorkItemViewModel *)viewModel;

@end
