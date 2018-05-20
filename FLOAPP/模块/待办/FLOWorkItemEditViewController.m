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
<UITextFieldDelegate>

{
    UIView *contentView;
}

@property (nonatomic, strong) UIScrollView *editScrollView;
@property (nonatomic, assign) float baseHeight;

@property (nonatomic, strong) UITextField *titleTextField;
@property (nonatomic, strong) YYTextView *descTextView;

@property (nonatomic, strong) UIView *targetView;
@property (nonatomic, strong) NSMutableArray *targetTextFields;

@property (nonatomic, strong) UIButton *addTargetBtn;
@property (nonatomic, strong) UIButton *deleteItemBtn;

@property (nonatomic, copy  ) NSDictionary *editItemTargetsStatus;

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
    
    if (_editItem) {
        //保存目标完成状态
        NSArray *targets = [_editItem.items  flo_objectFromJSONData];
        NSArray *targetsStatus = [_editItem.itemsStatus flo_objectFromJSONData];
        
        NSMutableDictionary *muDic = [NSMutableDictionary dictionaryWithCapacity:targets.count];
        for (int i = 0; i < targets.count; i++) {
            BOOL done = NO;
            if (i < targetsStatus.count) {
                done = [targetsStatus[i] boolValue];
            }
            
            NSString *str = [targets objectAtIndex:i];
            [muDic setObject:@(done) forKey:str];
        }
        
        _editItemTargetsStatus = [NSDictionary dictionaryWithDictionary:muDic];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(KeyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(KeyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
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
    _editScrollView.keyboardDismissMode = UIScrollViewKeyboardDismissModeInteractive;
    
    if (@available(iOS 11.0, *)) {
        _editScrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    } else {
        [self setAutomaticallyAdjustsScrollViewInsets:NO];
    }
    _editScrollView.showsVerticalScrollIndicator = NO;
    [contentView addSubview:_editScrollView];
    
    self.titleTextField = [[UITextField alloc] initWithFrame:CGRectMake(15, 15, MYAPPConfig.screenWidth-30, 44)];
    _titleTextField.placeholder = @"项目标题";
    _titleTextField.font = [UIFont systemFontOfSize:18];
    _titleTextField.backgroundColor = [UIColor whiteColor];
    _titleTextField.borderStyle = UITextBorderStyleRoundedRect;
    [_editScrollView addSubview:_titleTextField];
    
    self.descTextView = [[YYTextView alloc] initWithFrame:CGRectMake(15, CGRectGetMaxY(_titleTextField.frame) + 15, MYAPPConfig.screenWidth-30, 80)];
    _descTextView.placeholderText = @"项目描述";
    _descTextView.font = [UIFont systemFontOfSize:16];
    _descTextView.placeholderFont = [UIFont systemFontOfSize:16];
    _descTextView.backgroundColor = [UIColor whiteColor];
    [_descTextView flo_setCornerRadius:5];
    [_editScrollView addSubview:_descTextView];
    
    self.targetTextFields = [NSMutableArray arrayWithCapacity:1];
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
    _addTargetBtn.bounds = CGRectMake(0, 0, MYAPPConfig.screenWidth-30, 44);
    [_addTargetBtn flo_dottedBorderWithColor:COLOR_HEX(0xffffff)];
    [_editScrollView addSubview:_addTargetBtn];
    [_addTargetBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_targetView.mas_bottom).offset(10);
        make.left.equalTo(_targetView);
        make.right.equalTo(_targetView);
        make.height.mas_equalTo(44);
    }];
    [_addTargetBtn addTarget:self action:@selector(addTargetBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    _baseHeight = CGRectGetMaxY(_descTextView.frame) + 25 + 10 + 44;
    _baseHeight += 30;
    
    _editScrollView.contentSize = CGSizeMake(MYAPPConfig.screenWidth, _baseHeight);
    
    if (_editItem) {
        //显示内容
        _titleTextField.text = _editItem.title;
        _descTextView.text = _editItem.desc;
        
        self.deleteItemBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_deleteItemBtn setTitle:@"删除项目" forState:UIControlStateNormal];
        _deleteItemBtn.bounds = CGRectMake(0, 0, MYAPPConfig.screenWidth-30, 44);
        [_deleteItemBtn flo_setCornerRadius:5];
        _deleteItemBtn.backgroundColor = COLOR_HEX(0xffffff);
        [_deleteItemBtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        [_deleteItemBtn addTarget:self action:@selector(deleteItemBtnAction:) forControlEvents:UIControlEventTouchUpInside];
        [_editScrollView addSubview:_deleteItemBtn];
        [_deleteItemBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_addTargetBtn.mas_bottom).offset(30);
            make.left.equalTo(_addTargetBtn);
            make.right.equalTo(_addTargetBtn);
            make.height.mas_equalTo(44);
        }];
        
        _baseHeight += 30 + 44;
        
        [self createEditItemTargets];
    }
}

- (void)createEditItemTargets {
    NSArray *targets = [_editItem.items  flo_objectFromJSONData];
    for (NSString *target in targets) {
        UITextField *tf = [self createTargetEditView];
        tf.text = target;
    }
    
    [self configTargetViewFrame];
}

//目标编辑框
- (UITextField *)createTargetEditView {
    float y = _targetTextFields.count * (35+8);
    
    UITextField *tf = [[UITextField alloc] initWithFrame:CGRectMake(0, y, MYAPPConfig.screenWidth-30, 35)];
    tf.font = [UIFont systemFontOfSize:16];
    tf.backgroundColor = COLOR_HEX(0xffffff);
    tf.borderStyle = UITextBorderStyleRoundedRect;
    [_targetView addSubview:tf];
    
    //删除按钮
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(0, 0, 30, 25);
    btn.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 5);
    [btn setImage:[UIImage imageNamed:@"delete_icon"] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(targetDeleteButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    tf.rightView = btn;
    tf.rightViewMode = UITextFieldViewModeAlways;
    
    [_targetTextFields addObject:tf];
    return tf;
}

//添加、删除目标时更新
- (void)configTargetViewFrame {
    float height = _targetTextFields.count > 0 ? _targetTextFields.count * (35+8) - 8 : 0;
    [_targetView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(height);
    }];
    
    _editScrollView.contentSize = CGSizeMake(MYAPPConfig.screenWidth, _baseHeight + height);
}

//删除操作
- (void)delete {
    if (_deleteItem) {
        _deleteItem(_editItem);
    }
    [WorkList deleteEntity:_editItem];
    
    dispatch_after(0.5, dispatch_get_main_queue(), ^{
        [self closeButtonAction:nil];
    });
}

#pragma mark - action
- (void)closeButtonAction:(UIButton *)sender {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)saveButtonAction:(UIButton *)sender {
    if (!Def_CheckStringClassAndLength(_titleTextField.text)) {
        [_titleTextField becomeFirstResponder];
        return;
    }
    
    NSMutableArray *targets = [NSMutableArray arrayWithCapacity:1];
    for (UITextField *tf in _targetTextFields) {
        if (Def_CheckStringClassAndLength(tf.text)) {
            [targets addObject:tf.text];
        }
    }
    
    if (targets.count == 0) {
        Def_MBProgressString(@"请添加目标");
        return;
    }
    
    if (_editItem) {
        _editItem.title = _titleTextField.text;
        _editItem.desc = _descTextView.text;
        _editItem.items = [targets flo_JSONData];
        
        NSMutableArray *muArrItemStatus = [NSMutableArray arrayWithCapacity:targets.count];
        for (int i = 0; i < targets.count; i++) {
            NSString *target = [targets objectAtIndex:i];
            BOOL done = NO;
            if (_editItemTargetsStatus[target]) {
                done = [_editItemTargetsStatus[target] boolValue];
            }
            [muArrItemStatus addObject:@(done)];
        }
        _editItem.itemsStatus = [muArrItemStatus flo_JSONData];
        
        //存库
        [_editItem saveModify];
        
        //通知刷新
        if (_editCompletion) {
            _editCompletion(_editItem);
        }
    } else {
        //保存，通知上一页显示
        WorkList *item = [WorkList insertEntityTitle:_titleTextField.text desc:_descTextView.text items:targets];
        if (_editCompletion) {
            _editCompletion(item);
        }
    }
    
    //关闭页面
    dispatch_after(0.5, dispatch_get_main_queue(), ^{
        [self closeButtonAction:nil];
    });
}

- (void)deleteItemBtnAction:(UIButton *)sender {
    if (_editItem) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"确定删除项目？" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        FLOWeakObj(self);
        [alert addAction:[UIAlertAction actionWithTitle:@"删除" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            [weakself delete];
        }]];
        [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
        }]];
        
        [self presentViewController:alert animated:YES completion:nil];
    }
}

- (void)addTargetBtnAction:(UIButton *)sneder {
    UITextField *tf = [self createTargetEditView];
    [self configTargetViewFrame];
    
    [tf becomeFirstResponder];
}

- (void)targetDeleteButtonAction:(UIButton *)sender {
    UITextField *textField = (UITextField *)sender.superview;
    
    [textField resignFirstResponder];
    [textField removeFromSuperview];
    
    //下面的往上挪
    NSInteger index = [_targetTextFields indexOfObject:textField];
    if (index >= 0) {
        [_targetTextFields removeObject:textField];
        
        while (index < _targetTextFields.count) {
            UIView *l = [_targetTextFields objectAtIndex:index];
            l.top -= l.height + 8;
            
            index ++;
        }
    }
    
    //更新父级view高度
    [self configTargetViewFrame];
}

#pragma mark - NSNotification
- (void)KeyboardWillShow:(NSNotification *)noti {
    CGRect keyboardEnd = [[noti.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    _editScrollView.contentInset = UIEdgeInsetsMake(0, 0, keyboardEnd.size.height, 0);
}
- (void)KeyboardWillHide:(NSNotification *)noti {
    _editScrollView.contentInset = UIEdgeInsetsZero;
}

@end
