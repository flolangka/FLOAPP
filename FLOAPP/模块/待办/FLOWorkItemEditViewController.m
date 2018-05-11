//
//  FLOWorkItemEditViewController.m
//  FLOAPP
//
//  Created by 360doc on 2018/5/11.
//  Copyright © 2018年 Flolangka. All rights reserved.
//

#import "FLOWorkItemEditViewController.h"
#import "WorkList+CoreDataClass.h"
#import "UIView+FLOUtil.h"

#import <YYKit.h>
#import <Masonry.h>

@interface FLOWorkItemEditViewController ()

{
    UIView *contentView;
}

@property (nonatomic, strong) UIScrollView *editScrollView;

@property (nonatomic, strong) UITextField *titleTextField;
@property (nonatomic, strong) YYTextView *descTextView;

//公用textView
@property (nonatomic, strong) YYTextView *targetTextView;

@property (nonatomic, strong) UIView *targetView;
@property (nonatomic, strong) UIButton *addTargetBtn;
@property (nonatomic, strong) UIButton *deleteItemBtn;

@property (nonatomic, strong) NSMutableArray *targetLabels;

@end

@implementation FLOWorkItemEditViewController

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self createContentView];
    [self createTitleView];
    [self createEditView];
}

- (void)createContentView {
    contentView = [[UIView alloc] initWithFrame:CGRectMake(0, MYAPPConfig.statusBarHeight, MYAPPConfig.screenWidth, MYAPPConfig.screenHeight-MYAPPConfig.statusBarHeight)];
    [self.view addSubview:contentView];
    
    [contentView flo_setCornerRadius:10 roundingCorners:UIRectCornerTopLeft | UIRectCornerTopRight];
    contentView.backgroundColor = COLOR_RGB(56, 64, 79);
}

- (void)createTitleView {
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, MYAPPConfig.screenWidth, 49)];
    titleLabel.text = _editItem ? @"修改项目" : @"添加项目";
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.textColor = COLOR_HEX(0xffffff);
    titleLabel.font = [UIFont boldSystemFontOfSize:18];
    [contentView addSubview:titleLabel];
    
    //返回
    UIButton *closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [closeBtn addTarget:self action:@selector(closeButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    closeBtn.frame = CGRectMake(0, 2.5, 44, 44);
    [closeBtn setImageEdgeInsets:UIEdgeInsetsMake(13, 17, 13, 17)];
    [closeBtn setImage:[UIImage imageNamed:@"goback"] forState:UIControlStateNormal];
    [contentView addSubview:closeBtn];
    
    //保存
    UIButton *saveBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [saveBtn addTarget:self action:@selector(saveButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    saveBtn.frame = CGRectMake(MYAPPConfig.screenWidth-50-10, 2.5, 50, 44);
    [saveBtn setTintColor:COLOR_HEX(0xffffff)];
    [saveBtn setTitle:@"保存" forState:UIControlStateNormal];
    saveBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    [contentView addSubview:saveBtn];
    
    //分割线
    [contentView flo_addLineMarginTop:48.5 left:0 right:0];
}

- (void)createEditView {
    _editScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 49, MYAPPConfig.screenWidth, CGRectGetHeight(contentView.frame)-49)];
    
    if (@available(iOS 11.0, *)) {
        _editScrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    } else {
        [self setAutomaticallyAdjustsScrollViewInsets:NO];
    }
    _editScrollView.contentInset = UIEdgeInsetsMake(0, 0, 20, 0);
    _editScrollView.showsVerticalScrollIndicator = NO;
    [contentView addSubview:_editScrollView];
    
    self.titleTextField = [[UITextField alloc] initWithFrame:CGRectMake(15, 15, MYAPPConfig.screenWidth-30, 44)];
    _titleTextField.placeholder = @"项目标题";
    _titleTextField.font = [UIFont systemFontOfSize:18];
    _titleTextField.backgroundColor = [UIColor whiteColor];
    [_editScrollView addSubview:_titleTextField];
    
    self.descTextView = [[YYTextView alloc] initWithFrame:CGRectMake(15, CGRectGetMaxY(_titleTextField.frame) + 15, MYAPPConfig.screenWidth-30, 80)];
    _descTextView.placeholderText = @"项目描述";
    _descTextView.font = [UIFont systemFontOfSize:16];
    _descTextView.backgroundColor = [UIColor whiteColor];
    [_editScrollView addSubview:_descTextView];
    
    //公用textView
    self.targetTextView = [[YYTextView alloc] initWithFrame:CGRectMake(0, 0, MYAPPConfig.screenWidth-30, 40)];
    _targetTextView.backgroundColor = [UIColor whiteColor];
    _targetTextView.font = [UIFont systemFontOfSize:16];
    
    self.targetView = [[UIView alloc] init];
    [_editScrollView addSubview:_targetView];
    [_targetView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_editScrollView).offset(CGRectGetMaxY(_descTextView.frame) + 25);
        make.left.equalTo(_editScrollView).offset(15);
        make.width.mas_equalTo(MYAPPConfig.screenWidth-30);
        make.height.mas_equalTo(0);
    }];
    
    self.addTargetBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_addTargetBtn setTitle:@"添加目标" forState:UIControlStateNormal];
    _addTargetBtn.backgroundColor = [UIColor lightGrayColor];
    [_editScrollView addSubview:_addTargetBtn];
    [_addTargetBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_targetView.mas_bottom).offset(10);
        make.left.equalTo(_targetView);
        make.right.equalTo(_targetView);
        make.height.mas_equalTo(44);
    }];
    
    if (_editItem) {
        self.deleteItemBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_deleteItemBtn setTitle:@"删除项目" forState:UIControlStateNormal];
        _deleteItemBtn.backgroundColor = [UIColor redColor];
        [_editScrollView addSubview:_deleteItemBtn];
        [_deleteItemBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_addTargetBtn.mas_bottom).offset(30);
            make.left.equalTo(_addTargetBtn);
            make.right.equalTo(_addTargetBtn);
            make.height.mas_equalTo(44);
        }];
    }
}

#pragma mark - action
- (void)closeButtonAction:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)saveButtonAction:(UIButton *)sender {
    
    
    [self closeButtonAction:nil];
}


@end
