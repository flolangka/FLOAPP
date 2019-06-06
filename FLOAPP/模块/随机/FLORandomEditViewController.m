//
//  FLORandomEditViewController.m
//  FLOAPP
//
//  Created by 360doc on 2018/11/2.
//  Copyright © 2018 Flolangka. All rights reserved.
//

#import "FLORandomEditViewController.h"
#import "Random+CoreDataClass.h"
#import "UIView+FLOUtil.h"

#import <YYKit.h>
#import <Masonry.h>

@interface FLORandomEditViewController ()

@property (nonatomic, strong) UIScrollView *editScrollView;
@property (nonatomic, assign) float baseHeight;

@property (nonatomic, strong) UITextField *titleTextField;

@property (nonatomic, strong) UIView *targetView;
@property (nonatomic, strong) NSMutableArray *targetTextFields;

@property (nonatomic, strong) UIButton *addTargetBtn;

@end

@implementation FLORandomEditViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = _editRandom ? @"修改项目" : @"添加项目";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(saveAction:)];
    
    [self createEditView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(KeyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(KeyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)createEditView {
    _editScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, MYAPPConfig.screenWidth, MYAPPConfig.screenHeight-MYAPPConfig.navigationHeight)];
    _editScrollView.keyboardDismissMode = UIScrollViewKeyboardDismissModeInteractive;
    _editScrollView.backgroundColor = COLOR_RGB(56, 64, 79);
    
    if (@available(iOS 11.0, *)) {
        _editScrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    } else {
        [self setAutomaticallyAdjustsScrollViewInsets:NO];
    }
    _editScrollView.showsVerticalScrollIndicator = NO;
    [self.view addSubview:_editScrollView];
    
    self.titleTextField = [[UITextField alloc] initWithFrame:CGRectMake(15, 15, MYAPPConfig.screenWidth-30, 44)];
    _titleTextField.placeholder = @"项目标题";
    _titleTextField.font = [UIFont systemFontOfSize:18];
    _titleTextField.backgroundColor = [UIColor whiteColor];
    _titleTextField.borderStyle = UITextBorderStyleRoundedRect;
    [_editScrollView addSubview:_titleTextField];
    
    self.targetTextFields = [NSMutableArray arrayWithCapacity:1];
    self.targetView = [[UIView alloc] init];
    [_editScrollView addSubview:_targetView];
    [_targetView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_editScrollView).offset(CGRectGetMaxY(_titleTextField.frame) + 25);
        make.left.equalTo(_editScrollView).offset(15);
        make.width.mas_equalTo(MYAPPConfig.screenWidth-30);
        make.height.mas_equalTo(0);
    }];
    
    self.addTargetBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_addTargetBtn setTitle:@"添加可选项" forState:UIControlStateNormal];
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
    _baseHeight = CGRectGetMaxY(_titleTextField.frame) + 25 + 10 + 44;
    _baseHeight += 30;
    
    _editScrollView.contentSize = CGSizeMake(MYAPPConfig.screenWidth, _baseHeight);
    
    if (_editRandom) {
        //显示内容
        _titleTextField.text = _editRandom.name;
        
        [self createEditItemTargets];
    }
}

- (void)createEditItemTargets {
    NSArray *options = [_editRandom.options flo_objectFromJSONData];
    for (NSString *option in options) {
        UITextField *tf = [self createTargetEditView];
        tf.text = option;
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

#pragma mark - action
/**
 返回上一页
 */
- (void)delayClose {
    dispatch_after(0.5, dispatch_get_main_queue(), ^{
        [self.navigationController popViewControllerAnimated:YES];
    });
}

/**
 点击保存事件
 */
- (void)saveAction:(id)sender {
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
        Def_MBProgressString(@"请添加可选项");
        return;
    }
    
    if (_editRandom) {
         [_editRandom updateName:_titleTextField.text options:targets];
    } else {
        [Random insertEntityName:_titleTextField.text options:targets];
    }
    
    //关闭页面
    [self delayClose];
}

/**
 添加可选项
 */
- (void)addTargetBtnAction:(UIButton *)sneder {
    UITextField *tf = [self createTargetEditView];
    [self configTargetViewFrame];
    
    [tf becomeFirstResponder];
}

/**
 删除可选项
 */
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
