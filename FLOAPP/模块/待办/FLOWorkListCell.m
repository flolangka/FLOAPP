//
//  FLOWorkListCell.m
//  FLOAPP
//
//  Created by 360doc on 2018/5/10.
//  Copyright © 2018年 Flolangka. All rights reserved.
//

#import "FLOWorkListCell.h"
#import "FLOWorkItemViewModel.h"

@interface FLOWorkListCell ()

@property (nonatomic, strong, readwrite) FLOWorkItemViewModel *viewModel;

@end

@implementation FLOWorkListCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

//显示内容
- (void)bindViewModel:(FLOWorkItemViewModel *)viewModel {
    self.viewModel = viewModel;
    
}

//计算cell高度
+ (float)heightWithViewModel:(FLOWorkItemViewModel *)viewModel {
    return 30 + 0;
}

@end
