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

@interface FLOWorkListCell ()

@property (nonatomic, strong, readwrite) FLOWorkItemViewModel *viewModel;

@property (nonatomic, strong) UIView *baseView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) UILabel *descLabel;
@property (nonatomic, strong) UIView *targetsContentView;
@property (nonatomic, strong) UIButton *finishBtn;

@property (nonatomic, strong) UIButton *leftButton;
@property (nonatomic, strong) UIButton *rightButton;

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
    self.baseView = [[UIView alloc] initWithFrame:CGRectMake(15, 25, MYAPPConfig.screenWidth-30, 25+50)];
    [self.contentView addSubview:_baseView];
    
    //标题
    _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, CGRectGetWidth(_baseView.frame)-40, 44)];
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    _titleLabel.font = [UIFont boldSystemFontOfSize:18];
    _titleLabel.textColor = COLOR_HEX(0xffffff);
    [_baseView addSubview:_titleLabel];
    
    //时间
    _timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 33, CGRectGetWidth(_baseView.frame), 15)];
    _timeLabel.textAlignment = NSTextAlignmentCenter;
    _timeLabel.font = [UIFont systemFontOfSize:11];
    _timeLabel.textColor = COLOR_HEX(0xffffff);
    [_baseView addSubview:_timeLabel];
    
    //描述
    _descLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 50, CGRectGetWidth(_baseView.frame)-30, 0)];
    _descLabel.numberOfLines = 0;
    _descLabel.font = [UIFont systemFontOfSize:14];
    _descLabel.textColor = COLOR_HEX(0xffffff);
    [_baseView addSubview:_descLabel];
    
    //目标区域
    _targetsContentView = [[UIView alloc] initWithFrame:CGRectMake(15, CGRectGetMaxY(_descLabel.frame) + 15, CGRectGetWidth(_baseView.frame)-30, 0)];
    _targetsContentView.backgroundColor = COLOR_HEX(0xffffff);
    [_baseView addSubview:_targetsContentView];
    
    //完成按钮
    _finishBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _finishBtn.frame = CGRectMake((CGRectGetWidth(_baseView.frame)-150)/2., CGRectGetMaxY(_targetsContentView.frame) + 15, 150, 35);
    [_finishBtn setTitle:@"Completion" forState:UIControlStateNormal];
    [_finishBtn addTarget:self action:@selector(finishButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [_baseView addSubview:_finishBtn];
    _finishBtn.layer.cornerRadius = 35/2.;
    _finishBtn.layer.masksToBounds = YES;
    _finishBtn.layer.borderWidth = 1;
    _finishBtn.layer.borderColor = COLOR_HEX(0xffffff).CGColor;
    
    //修改按钮
    _leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _leftButton.frame = CGRectMake(8, 7.5, 35, 35);
    [_leftButton setTintColor:COLOR_HEX(0xffffff)];
    [_leftButton setImageEdgeInsets:UIEdgeInsetsMake(9, 9, 9, 9)];
    [_leftButton setImage:[[UIImage imageNamed:@"icon_write"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    [_leftButton addTarget:self action:@selector(leftButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [_baseView addSubview:_leftButton];
    
    //redo/undo按钮
    _rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _rightButton.frame = CGRectMake(CGRectGetWidth(_baseView.frame) - 35 - 8, 7.5, 35, 35);
    [_rightButton setTitleColor:COLOR_HEX(0xffffff) forState:UIControlStateNormal];
    [_rightButton setTitle:@"undo" forState:UIControlStateNormal];
    _rightButton.titleLabel.font = [UIFont systemFontOfSize:14];
    [_rightButton addTarget:self action:@selector(rightButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [_baseView addSubview:_rightButton];
    
    //分割线
    [_baseView flo_addLineMarginTop:50 left:0 right:0];
}

//显示内容
- (void)bindViewModel:(FLOWorkItemViewModel *)viewModel {
    self.viewModel = viewModel;
    
    _titleLabel.text = _viewModel.title;
    _timeLabel.text = _viewModel.timeStr;
    _descLabel.text = _viewModel.desc;
    
    _leftButton.hidden = _viewModel.editBtnHide;
    [_rightButton setTitle:_viewModel.titleRightBtnTitle forState:UIControlStateNormal];
    
    if (Def_CheckStringClassAndLength(_viewModel.desc)) {
        float height = [_viewModel.desc heightWithLimitWidth:MYAPPConfig.screenWidth - 15*2 - 15*2 fontSize:14];
        _descLabel.height = height + 30;
    } else {
        _descLabel.height = 15;
    }
    
    [_targetsContentView removeAllSubviews];
    
    //目标区域
    float x = 44;
    float y = 0;
    float w = MYAPPConfig.screenWidth - 15*2 - 15*2 - x - 10;
    
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
        [_targetsContentView addSubview:doneBtn];
        
        if (i < _viewModel.targetsStatus.count) {
            doneBtn.selected = [_viewModel.targetsStatus[i] boolValue];
        }
        
        if (_viewModel.targetBtnEnable) {
            label.tag = 1000 + i;
            [label addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(targetLabelTapAction:)]];
            label.userInteractionEnabled = YES;
            
            doneBtn.tag = 2000 + i;
            [doneBtn addTarget:self action:@selector(doneButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        } else {
            doneBtn.userInteractionEnabled = NO;
        }
        
        if (y > 0) {
            [label flo_topLineLeft:-30 right:0];
        }
        y += h;
    }
    _targetsContentView.frame = CGRectMake(15, CGRectGetMaxY(_descLabel.frame), CGRectGetWidth(_baseView.frame)-30, y);
    [_targetsContentView flo_setCornerRadius:10];
    
    if (_viewModel.showFinishBtn) {
        _finishBtn.top = CGRectGetMaxY(_targetsContentView.frame) + 15;
        _baseView.height = CGRectGetMaxY(_finishBtn.frame) + 15;
        _finishBtn.hidden = NO;
    } else {
        _baseView.height = CGRectGetMaxY(_targetsContentView.frame) + 15;
        _finishBtn.hidden = YES;
    }
    
    [_baseView flo_setCornerRadius:20];
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
        height += [viewModel.desc heightWithLimitWidth:MYAPPConfig.screenWidth - 15*2 - 15*2 fontSize:14] + 30;
    } else {
        height += 15;
    }
    
    //目标
    float x = 44;
    float w = MYAPPConfig.screenWidth - 15*2 - 15*2 - x - 10;
    for (NSString *target in viewModel.targets) {
        height += [target heightWithLimitWidth:w fontSize:15] + 15;
    }
    height += 15;
    
    if (viewModel.showFinishBtn) {
        height += 35 + 15;
    }
    
    return height;
}

#pragma mark - action
- (void)doneButtonAction:(UIButton *)sender {
    if (_viewModel.targetBtnEnable) {
        sender.selected = !sender.selected;
        
        if (_delegate && [_delegate respondsToSelector:@selector(workListCell:targetSelected:atIndex:)]) {
            [_delegate workListCell:self targetSelected:sender.selected atIndex:sender.tag - 2000];
        }
    }
}
- (void)targetLabelTapAction:(UIGestureRecognizer *)ges {
    NSInteger tag = ges.view.tag + 1000;
    
    UIButton *doneBtn = [ges.view.superview viewWithTag:tag];
    if (doneBtn) {
        [self doneButtonAction:doneBtn];
    }
}

- (void)finishButtonAction:(UIButton *)sender {
    if (_delegate && [_delegate respondsToSelector:@selector(workListCellClickFinishButton:)]) {
        [_delegate workListCellClickFinishButton:self];
    }
}

- (void)leftButtonAction:(UIButton *)sender {
    if (_delegate && [_delegate respondsToSelector:@selector(workListCellClickTitleLeftButton:)]) {
        [_delegate workListCellClickTitleLeftButton:self];
    }
}

- (void)rightButtonAction:(UIButton *)sender {
    if (_delegate && [_delegate respondsToSelector:@selector(workListCellClickTitleRightButton:)]) {
        [_delegate workListCellClickTitleRightButton:self];
    }
}

@end
