//
//  FLOSortViewController.m
//  FLOAPP
//
//  Created by 360doc on 2018/4/27.
//  Copyright © 2018年 Flolangka. All rights reserved.
//

#import "FLOSortViewController.h"
#import "FLOSortViewModel.h"
#import "FLOSortView.h"


@interface FLOSortViewController ()

@property (nonatomic, strong, readwrite) FLOSortViewModel *viewModel;
@property (nonatomic, strong) NSMutableArray *sortArr;

@property (nonatomic, strong) UISegmentedControl *seg;
@property (nonatomic, strong) UIView *segMaskView;
@property (nonatomic, strong) UIView *sortContainerView;

@end

@implementation FLOSortViewController
@dynamic viewModel;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.sortArr = [NSMutableArray arrayWithCapacity:self.viewModel.sortNumber];
    [self configSubViews];
    
    @weakify(self);
    [RACObserve(self.viewModel, sorting) subscribeNext:^(NSNumber *sorting) {
        @strongify(self);
        if (sorting.boolValue) {
            [self.view addSubview:self.segMaskView];
            self.navigationItem.rightBarButtonItem.enabled = NO;
        } else {
            [self.segMaskView removeFromSuperview];
            self.navigationItem.rightBarButtonItem.enabled = YES;
        }
    }];
}

- (void)configSubViews {
    self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Sort" style:UIBarButtonItemStyleDone target:self action:@selector(sortBarButtonItemAction:)];
    
    _seg = [[UISegmentedControl alloc] initWithItems:@[@"冒泡", @"选择", @"插入", @"希尔", @"堆排", @"归并", @"快排", @"基数"]];
    _seg.frame = CGRectMake(5, 10, MYAPPConfig.screenWidth-10, 35);
    _seg.tintColor = COLOR_RGB3SAME(0);
    [_seg addTarget:self action:@selector(segmentedControlAction:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:_seg];
    
    _segMaskView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, MYAPPConfig.screenWidth, _seg.height + 20)];
    _segMaskView.backgroundColor = COLOR_RGB3SAMEAlpha(255, 0.5);
    
    //排序区域
    _sortContainerView = [[UIView alloc] initWithFrame:CGRectMake(5, 10+35+10, MYAPPConfig.screenWidth-10, MYAPPConfig.screenHeight - (64+10+35+10+5))];
    _sortContainerView.backgroundColor = COLOR_RGB3SAME(255);
    [self.view addSubview:_sortContainerView];
    
    _seg.selectedSegmentIndex = 0;
    [self segmentedControlAction:nil];
}

- (void)sortBarButtonItemAction:(id)sender {
    self.viewModel.sorting = YES;
    
}

- (void)segmentedControlAction:(id)sender {
    [self.sortArr removeAllObjects];
    [_sortContainerView removeAllSubviews];
    
    float width = _sortContainerView.width / self.viewModel.sortNumber;
    for (int i = 0; i < self.viewModel.sortNumber; i++) {
        FLOSortView *view = [[FLOSortView alloc] initWithFrame:CGRectMake(i*width, 0, width, arc4random_uniform(_sortContainerView.height))];
        [_sortContainerView addSubview:view];
        
        [view updateHeight:view.height];
        [self.sortArr addObject:@(view.height)];
    }
}

@end
