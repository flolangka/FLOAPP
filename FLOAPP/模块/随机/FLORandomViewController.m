//
//  FLORandomViewController.m
//  FLOAPP
//
//  Created by 360doc on 2018/10/31.
//  Copyright © 2018 Flolangka. All rights reserved.
//

#import "FLORandomViewController.h"
#import "Random+CoreDataClass.h"
#import "FLORandomEditViewController.h"
#import "NSString+FLOUtil.h"
#import "UIView+FLOUtil.h"
#import <Masonry.h>
#import <PNChart.h>

@interface FLORandomViewController ()

@property (nonatomic, strong) UIView *randomView;
@property (nonatomic, strong) UITextView *optionsTextView;
@property (nonatomic, copy  ) NSArray *options;

@property (nonatomic, strong) PNPieChart *pieChart; //饼状图

/* 随机方案
 1、转盘
 2、二叉树
 */

@end

@implementation FLORandomViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = _randomModel.name;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(editAction:)];
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self initSubViews];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.options = [_randomModel.options flo_objectFromJSONData];
}

- (void)initSubViews {
    float randomViewHeight = 400;
    
    _randomView = [[UIView alloc] init];
    [self.view addSubview:_randomView];
    [_randomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view);
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        make.height.mas_equalTo(randomViewHeight);
    }];
    
    //饼状图
    _pieChart = [[PNPieChart alloc] initWithFrame:CGRectMake((MYAPPConfig.screenWidth-280)/2., 44, 280.0, 280.0) items:@[]];
    _pieChart.descriptionTextColor = [UIColor blackColor];
    _pieChart.descriptionTextFont  = [UIFont fontWithName:@"Avenir-Medium" size:15.0];
    _pieChart.hideValues = YES;
    _pieChart.duration = 0.5;
    _pieChart.descriptionTextShadowOffset = CGSizeZero;
    [_randomView addSubview:_pieChart];
    
    //选项列表
    _optionsTextView = [[UITextView alloc] init];
    [self.view addSubview:_optionsTextView];
    [_optionsTextView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_randomView.mas_bottom);
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        make.bottom.equalTo(self.view).offset(-MYAPPConfig.bottomAddHeight-5);
    }];
    _optionsTextView.editable = NO;
    _optionsTextView.selectable = NO;
    _optionsTextView.contentInset = UIEdgeInsetsMake(0, 16, 0, 16);
    _optionsTextView.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0, 0, 5);
    
    //选项的虚线边框
    [self.view drawDashLineBorderRect:CGRectMake(5, randomViewHeight, MYAPPConfig.screenWidth-5*2, MYAPPConfig.screenHeight-MYAPPConfig.navigationHeight-randomViewHeight-MYAPPConfig.bottomAddHeight-5) lineLength:5 lineSpacing:3 lineColor:COLOR_HEX(0xD8D8D8) cornerRadius:5];
}

- (void)loadPieChart {
    NSMutableArray *items = [NSMutableArray array];
    NSInteger count = _options.count;
    for (NSInteger i = 0; i < count; i++) {
        UIColor *color = [UIColor colorWithHue:(float)i/count saturation:1 brightness:1 alpha:1];
        [items addObject:[PNPieChartDataItem dataItemWithValue:1 color:color description:_options[i]]];
    }
    
    [_pieChart updateChartData:[NSArray arrayWithArray:items]];
    [_pieChart strokeChart];
}

#pragma mark - get/set
- (void)setOptions:(NSArray *)options {
    _options = [options copy];
    
    NSMutableArray *arr = [NSMutableArray arrayWithArray:_options];
    [arr enumerateObjectsUsingBlock:^(NSString *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        arr[idx] = [NSString stringWithFormat:@"%ld. %@", idx+1, obj];
    }];
    
    _optionsTextView.attributedText = [[arr componentsJoinedByString:@"\n"] attributedFont:[UIFont systemFontOfSize:18] paragraphSpacing:10 alignment:0];
    
    [self loadPieChart];
}

#pragma mark - action
/**
 点击修改事件
 */
- (void)editAction:(id)sender {
    FLORandomEditViewController *editVC = [[FLORandomEditViewController alloc] init];
    editVC.editRandom = _randomModel;
    [self.navigationController pushViewController:editVC animated:YES];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
