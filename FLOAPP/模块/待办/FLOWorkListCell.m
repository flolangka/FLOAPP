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

NSString * const KeyFLOWorkListCellRefreshNotificationName = @"KeyFLOWorkListCellRefreshNotificationName";

@interface FLOWorkListCell ()

@property (nonatomic, strong, readwrite) FLOWorkItemViewModel *viewModel;

@property (nonatomic, strong) UIView *baseView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) UILabel *descLabel;
@property (nonatomic, strong) UIView *targetsContentView;
@property (nonatomic, strong) UIButton *finishBtn;

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
        make.top.equalTo(self.contentView).offset(25);
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
        make.left.equalTo(_baseView).offset(15);
        make.right.equalTo(_baseView).offset(-15);
        make.height.mas_equalTo(0);
    }];
    
    //完成按钮
    _finishBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_finishBtn setTitle:@"Completion" forState:UIControlStateNormal];
    [_finishBtn addTarget:self action:@selector(finishButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [_baseView addSubview:_finishBtn];
    [_finishBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(150);
        make.centerX.equalTo(_baseView.mas_centerX);
        make.bottom.equalTo(_baseView).offset(-20);
        make.height.mas_equalTo(35);
    }];
    _finishBtn.layer.cornerRadius = 35/2.;
    _finishBtn.layer.masksToBounds = YES;
    _finishBtn.layer.borderWidth = 1;
    _finishBtn.layer.borderColor = COLOR_HEX(0xffffff).CGColor;
    
    //目标区域
    _targetsContentView = [[UIView alloc] init];
    _targetsContentView.backgroundColor = COLOR_HEX(0xffffff);
    [_baseView addSubview:_targetsContentView];
    [_targetsContentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_descLabel.mas_bottom).offset(15);
        make.left.equalTo(_baseView).offset(15);
        make.right.equalTo(_baseView).offset(-15);
        make.bottom.equalTo(_finishBtn.mas_top).offset(-15);
    }];
    
    //分割线
    [_baseView flo_addLineMarginTop:50 left:0 right:0];
}

//显示内容
- (void)bindViewModel:(FLOWorkItemViewModel *)viewModel {
    self.viewModel = viewModel;
    
    [_baseView flo_setCornerRadius:20];
    
    _titleLabel.text = _viewModel.title;
    _timeLabel.text = _viewModel.timeStr;
    _descLabel.text = _viewModel.desc;
    
    if (Def_CheckStringClassAndLength(_viewModel.desc)) {
        float height = [_viewModel.desc heightWithLimitWidth:MYAPPConfig.screenWidth - 15*2 - 15*2 fontSize:14];
        [_descLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_timeLabel.mas_bottom).offset(15);
            make.height.mas_equalTo(height);
        }];
    } else {
        [_descLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_timeLabel.mas_bottom).offset(0);
            make.height.mas_equalTo(0);
        }];
    }
    
    [_targetsContentView removeAllSubviews];
    [_targetsContentView flo_setCornerRadius:10];
    
    //目标区域,上留白 15，下留白 20
    float x = 44;
    float y = 0;
    float w = MYAPPConfig.screenWidth - 15*2 - 15*2 - x - 15;
    
    float fontSize = 15;
    UIFont *font = [UIFont systemFontOfSize:fontSize];
    
    NSArray *targets = _viewModel.targets;
    for (int i = 0; i < targets.count; i++) {
        //内容
        NSString *str = [targets objectAtIndex:i];
        float h = [str heightWithLimitWidth:w fontSize:fontSize] + 15;
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(x, y, w, h)];
        label.font = font;
        label.numberOfLines = 0;
        label.text = str;
        [_targetsContentView addSubview:label];
        
        //选中按钮
        UIButton *doneBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        doneBtn.frame = CGRectMake(8, y+(h-28)/2., 28, 28);
        [doneBtn setImage:[UIImage imageNamed:@"icon_multiselect_normal"] forState:UIControlStateNormal];
        [doneBtn setImage:[UIImage imageNamed:@"icon_multiselect_selected"] forState:UIControlStateSelected];
        [doneBtn addTarget:self action:@selector(doneButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        doneBtn.tag = 2000 + i;
        [_targetsContentView addSubview:doneBtn];
        
        if (i < _viewModel.targetsStatus.count) {
            doneBtn.selected = [_viewModel.targetsStatus[i] boolValue];
        }
        
        if (y > 0) {
            [label flo_topLineLeft:-30 right:0];
        }
        y += h;
    }
    
    if (_viewModel.finished) {
        [_finishBtn mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(35);
            make.bottom.equalTo(_baseView).offset(-20);
        }];
        _finishBtn.hidden = NO;
    } else {
        [_finishBtn mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(0);
            make.bottom.equalTo(_baseView).offset(0);
        }];
        _finishBtn.hidden = YES;
    }
}

//渐变颜色
- (void)gradientStartColor:(UIColor *)startColor endColor:(UIColor *)endColor {
    NSArray *sublayers = _baseView.layer.sublayers;
    for (NSInteger i = sublayers.count-1; i >= 0; i--) {
        CALayer *layer = [sublayers objectAtIndex:i];
        if ([layer isKindOfClass:[CAGradientLayer class]]) {
            [layer removeFromSuperlayer];
        }
    }
    
    CGSize size = _baseView.bounds.size;
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.colors = @[(__bridge id)startColor.CGColor, (__bridge id)endColor.CGColor];
    gradientLayer.locations = @[@0, @1.0];
    gradientLayer.startPoint = CGPointMake(0, 0);
    gradientLayer.endPoint = CGPointMake(1.0, 1.0);
    gradientLayer.frame = CGRectMake(0, 0, size.width, size.height);
    [_baseView.layer insertSublayer:gradientLayer atIndex:0];
}

//计算cell高度
+ (float)heightWithViewModel:(FLOWorkItemViewModel *)viewModel {
    float height = 25 + 50;
    
    //描述
    if (Def_CheckStringClassAndLength(viewModel.desc)) {
        height += 15 + [viewModel.desc heightWithLimitWidth:MYAPPConfig.screenWidth - 15*2 - 15*2 fontSize:14];
    }
    
    //目标
    height += 15;
    float x = 44;
    float w = MYAPPConfig.screenWidth - 15*2 - 15*2 - x - 15;
    for (NSString *target in viewModel.targets) {
        height += [target heightWithLimitWidth:w fontSize:15] + 15;
    }
    height += 20;
    
    if (viewModel.finished) {
        height += 35 + 20;
    }
    
    return height;
}

#pragma mark - action
- (void)doneButtonAction:(UIButton *)sender {
    BOOL finished = _viewModel.finished;
    sender.selected = !sender.selected;    
    
    //修改存库
    [_viewModel.item updateItemStatus:sender.selected atIndex:sender.tag-2000];
    
    //更新viewmodel
    [_viewModel update];
    
    //完成状态有改变,通知刷新cell
    if (finished != _viewModel.finished) {
        [[NSNotificationCenter defaultCenter] postNotificationName:KeyFLOWorkListCellRefreshNotificationName object:nil userInfo:@{@"itemViewModel": _viewModel}];
    }
}

- (void)finishButtonAction:(UIButton *)sender {
    
}

@end
