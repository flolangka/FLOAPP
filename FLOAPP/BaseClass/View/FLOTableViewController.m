//
//  FLOTableViewController.m
//  FLOAPP
//
//  Created by 360doc on 2018/4/4.
//  Copyright © 2018年 Flolangka. All rights reserved.
//

#import "FLOTableViewController.h"
#import "FLOTableViewModel.h"

#import <MJRefresh.h>

@interface FLOTableViewController ()

@property (nonatomic, strong, readwrite) FLOTableViewModel *viewModel;
@property (nonatomic, strong, readwrite) UITableView *tableView;

@end

@implementation FLOTableViewController
@dynamic viewModel;

#pragma mark - super func
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self configTableView];
}

- (void)bindViewModel {
    [super bindViewModel];
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark -

- (void)configTableView {
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, MYAPPConfig.screenWidth, MYAPPConfig.screenHeight-MYAPPConfig.navigationBarHeight) style:self.viewModel.tableViewStyle];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [self.view addSubview:_tableView];
    
    if (@available(iOS 11.0, *)) {
        [_tableView setContentInsetAdjustmentBehavior:UIScrollViewContentInsetAdjustmentNever];
    } else {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.viewModel.dataArr.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[self.viewModel.dataArr objectAtIndex:section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [self tableView:tableView dequeueReusableCellForIndexPath:indexPath];
    
    [self configCell:cell atIndexPath:indexPath withObject:[[self.viewModel.dataArr objectAtIndex:indexPath.section] objectAtIndex:indexPath.row]];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [self heightForRowAtIndexPath:indexPath withObject:[[self.viewModel.dataArr objectAtIndex:indexPath.section] objectAtIndex:indexPath.row]];
}

//子类提供cell
- (UITableViewCell *)tableView:(UITableView *)tableView dequeueReusableCellForIndexPath:(NSIndexPath *)indexPath {
    NSString *cellid = @"cellid";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellid];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellid];
    }
    return cell;
}

//子类配置cell内容
- (void)configCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath withObject:(id)object {
    
}

//子类设置cell高度
- (float)heightForRowAtIndexPath:(NSIndexPath *)indexPath withObject:(id)object {
    return 44;
}

#pragma mark - refresh
- (void)addHeaderRefresh {
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(headerRefreshAction)];
}
- (void)headerRefreshAction {
    if (self.requesting) {
        [self endHeaderRefresh];
        return;
    }
}
- (void)endHeaderRefresh {
    [self.tableView.mj_header endRefreshing];
}
- (void)removeHeaderRefresh {
    [self endHeaderRefresh];
    self.tableView.mj_header = nil;
}

- (void)addFooterRefresh {
    self.tableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(footerRefreshAction)];
}
- (void)footerRefreshAction {
    if (self.requesting) {
        [self endFooterRefresh];
        return;
    }
}
- (void)endFooterRefresh {
    [self.tableView.mj_footer endRefreshing];
}
- (void)removeFooterRefresh {
    [self endFooterRefresh];
    self.tableView.mj_footer = nil;
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
