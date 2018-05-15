//
//  FLOWorkListCell.m
//  FLOAPP
//
//  Created by 360doc on 2018/5/10.
//  Copyright © 2018年 Flolangka. All rights reserved.
//

#import "FLOWorkListCell.h"
#import "FLOWorkItemViewModel.h"
#import "WorkList+CoreDataClass.h"
#import "UIView+FLOUtil.h"
#import "NSString+FLOUtil.h"

#import <Masonry.h>

@interface FLOWorkListCell ()

@property (nonatomic, strong, readwrite) FLOWorkItemViewModel *viewModel;

@property (nonatomic, strong) UIView *baseView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) UILabel *descLabel;
@property (nonatomic, strong) UIView *targetsContentView;

@end

@implementation FLOWorkListCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = [UIColor clearColor];
        
        [self createSubView];
    }
    return self;
}

- (void)createSubView {
    self.baseView = [[UIView alloc] init];
    [self.contentView addSubview:_baseView];
    [_baseView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView).offset(30);
        make.bottom.equalTo(self.contentView);
        make.left.equalTo(self.contentView).offset(15);
        make.right.equalTo(self.contentView).offset(-15);
    }];
    
    //标题
    _titleLabel = [[UILabel alloc] init];
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    _titleLabel.font = [UIFont boldSystemFontOfSize:18];
    _titleLabel.textColor = COLOR_HEX(0xffffff);
    [_baseView addSubview:_titleLabel];
    [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_baseView);
        make.left.equalTo(_baseView).offset(20);
        make.right.equalTo(_baseView).offset(-20);
        make.height.mas_equalTo(44);
    }];
    
    //时间
    _timeLabel = [[UILabel alloc] init];
    _timeLabel.textAlignment = NSTextAlignmentCenter;
    _timeLabel.font = [UIFont systemFontOfSize:11];
    _timeLabel.textColor = COLOR_HEX(0xffffff);
    [_baseView addSubview:_timeLabel];
    [_timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_baseView).offset(33);
        make.left.equalTo(_baseView);
        make.right.equalTo(_baseView);
        make.height.mas_equalTo(15);
    }];
    
    //描述
    _descLabel = [[UILabel alloc] init];
    _descLabel.numberOfLines = 0;
    _descLabel.font = [UIFont systemFontOfSize:14];
    _descLabel.textColor = COLOR_HEX(0xffffff);
    [_baseView addSubview:_descLabel];
    [_descLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_timeLabel.mas_bottom).offset(0);
        make.left.equalTo(_baseView).offset(10);
        make.right.equalTo(_baseView).offset(-10);
        make.height.mas_equalTo(0);
    }];
    
    //目标区域
    _targetsContentView = [[UIView alloc] init];
    [_baseView addSubview:_targetsContentView];
    [_targetsContentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_descLabel.mas_bottom).offset(5);
        make.left.equalTo(_baseView);
        make.right.equalTo(_baseView);
        make.bottom.equalTo(_baseView);
    }];
    
    //分割线
    [_baseView flo_addLineMarginTop:50 left:0 right:0];
    [_targetsContentView flo_topLineLeft:0 right:0];
}

//显示内容
- (void)bindViewModel:(FLOWorkItemViewModel *)viewModel {
    self.viewModel = viewModel;
    
//    _baseView.bounds = CGRectMake(0, 0, CGRectGetWidth(self.frame) - 2*_HSpace, CGRectGetHeight(self.frame) - 30);
    [_baseView flo_setCornerRadius:20];
    _baseView.backgroundColor = [UIColor orangeColor];
    
    _titleLabel.text = _viewModel.title;
    _timeLabel.text = _viewModel.timeStr;
    _descLabel.text = _viewModel.desc;
    
    if (Def_CheckStringClassAndLength(_viewModel.desc)) {
        float height = [viewModel.desc heightWithLimitWidth:MYAPPConfig.screenWidth - 15*2 - 10*2 fontSize:14];
        [_descLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_timeLabel.mas_bottom).offset(5);
            make.height.mas_equalTo(height);
        }];
    } else {
        [_descLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_timeLabel.mas_bottom).offset(0);
            make.height.mas_equalTo(0);
        }];
    }
    
}

//计算cell高度
+ (float)heightWithViewModel:(FLOWorkItemViewModel *)viewModel {
    float height = 30 + 50;    
    
    //描述
    if (Def_CheckStringClassAndLength(viewModel.desc)) {
        height += 5 + [viewModel.desc heightWithLimitWidth:MYAPPConfig.screenWidth - 15*2 - 10*2 fontSize:14];
    }
    
    //目标
    height += 35 * viewModel.targets.count;
    
    return height;
}

@end
