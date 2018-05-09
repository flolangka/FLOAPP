//
//  FLOWorkListViewController.m
//  FLOAPP
//
//  Created by 沈敏 on 2018/5/8.
//  Copyright © 2018年 Flolangka. All rights reserved.
//

#import "FLOWorkListViewController.h"
#import "FLOWorkListViewModel.h"
#import "UIView+FLOUtil.h"
#import "UIImage+FLOUtil.h"
#import <UIView+YYAdd.h>

@interface FLOWorkListViewController ()

{
    UIView *backgroundContentView;
    UIImageView *backgroundImageView;
    UIView *backgroundMaskView;
    UIScrollView *backgroundScrollView;
    
    UIView *contentView;
    float contentViewHeight;
}

@property (nonatomic, strong, readwrite) FLOWorkListViewModel *viewModel;

@end

@implementation FLOWorkListViewController
@dynamic viewModel;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    contentViewHeight = MYAPPConfig.screenHeight-MYAPPConfig.navigationBarHeight;
    [self createBackgroundView];
    [self createBackgroundScrollView];
    [self createBaseView];
    
    self.tableView.frame = CGRectMake(0, 44, MYAPPConfig.screenWidth, contentViewHeight-44);
    [contentView addSubview:self.tableView];
}

- (void)createBackgroundView {
    //滑动时伸缩的view
    backgroundContentView = [[UIView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:backgroundContentView];
    
    backgroundImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, MYAPPConfig.navigationBarHeight, MYAPPConfig.screenWidth, contentViewHeight)];
    [backgroundContentView addSubview:backgroundImageView];
    
    UIImage *snapshot = [[UIApplication sharedApplication].keyWindow snapshotImageAfterScreenUpdates:NO];
    CGSize size = snapshot.size;
    snapshot = [snapshot clipToRect:CGRectMake(0, MYAPPConfig.navigationBarHeight*snapshot.scale, size.width*snapshot.scale, (size.height-MYAPPConfig.navigationBarHeight)*snapshot.scale)];
    backgroundImageView.image = snapshot;
    
    //滑动时黑色透明的view
    backgroundMaskView = [[UIView alloc] initWithFrame:self.view.bounds];
    backgroundMaskView.backgroundColor = COLOR_HEXAlpha(0x000000, 0);
    [self.view addSubview:backgroundMaskView];
}

//用于向下滑动返回上一页
- (void)createBackgroundScrollView {
    backgroundScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, MYAPPConfig.navigationBarHeight, MYAPPConfig.screenWidth, contentViewHeight)];
    backgroundScrollView.showsVerticalScrollIndicator = NO;
    backgroundScrollView.showsHorizontalScrollIndicator = NO;
    backgroundScrollView.pagingEnabled = YES;
    backgroundScrollView.bounces = NO;
    backgroundScrollView.delegate = self;
    backgroundScrollView.contentSize = CGSizeMake(MYAPPConfig.screenWidth, contentViewHeight*2);
    [self.view addSubview:backgroundScrollView];
    
    if (@available(iOS 11.0, *)) {
        backgroundScrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    } else {
        [self setAutomaticallyAdjustsScrollViewInsets:NO];
    }
}

- (void)createBaseView {
    contentView = [[UIView alloc] initWithFrame:CGRectMake(0, contentViewHeight, MYAPPConfig.screenWidth, contentViewHeight)];
    [backgroundScrollView addSubview:contentView];
    
    [contentView flo_setCornerRadius:10 roundingCorners:UIRectCornerTopLeft | UIRectCornerTopRight];
    contentView.backgroundColor = COLOR_RGB(56, 64, 79);
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (scrollView == backgroundScrollView && scrollView.contentOffset.y == 0) {
        [self close];
    }
}

//called when setContentOffset/scrollRectVisible:animated: finishes
- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    if (scrollView == backgroundScrollView && scrollView.contentOffset.y == 0) {
        [self close];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView == backgroundScrollView) {
        float y = scrollView.contentOffset.y;
        backgroundMaskView.backgroundColor = COLOR_HEXAlpha(0x000000, y/contentViewHeight);
        
        float s = y/contentViewHeight*40;
        backgroundContentView.transform = CGAffineTransformMakeScale((MYAPPConfig.screenWidth-s)/MYAPPConfig.screenWidth, (contentViewHeight-s)/contentViewHeight);
    }
}

#pragma mark - action
- (void)close {
    [self dismissViewControllerAnimated:NO completion:^{
        
    }];
}

@end
