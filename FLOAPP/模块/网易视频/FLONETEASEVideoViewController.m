//
//  FLONETEASEVideoViewController.m
//  FLOAPP
//
//  Created by 360doc on 2018/4/12.
//  Copyright © 2018年 Flolangka. All rights reserved.
//

#import "FLONETEASEVideoViewController.h"
#import "FLONETEASEVideoViewModel.h"
#import "FLONETEASEVideoItemViewModel.h"
#import "FLONETEASEVideoTableViewCell.h"

@interface FLONETEASEVideoViewController ()

@property (nonatomic, strong, readwrite) FLONETEASEVideoViewModel *viewModel;

@end

@implementation FLONETEASEVideoViewController
@dynamic viewModel;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self addHeaderRefresh];
    [self addFooterRefresh];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"FLONETEASEVideoTableViewCell" bundle:nil] forCellReuseIdentifier:@"FLONETEASEVideoTableViewCell"];
    
    //请求数据
    self.viewModel.loading = YES;
    [self headerRefreshAction];
}

#pragma mark - tableView
- (UITableViewCell *)tableView:(UITableView *)tableView dequeueReusableCellForIndexPath:(NSIndexPath *)indexPath {
    NSString *cellid = @"FLONETEASEVideoTableViewCell";
    FLONETEASEVideoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellid forIndexPath:indexPath];
    return cell;
}

- (void)configCell:(FLONETEASEVideoTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath withObject:(FLONETEASEVideoItemViewModel *)object {
    [cell bindViewModel:object];
}

- (float)heightForRowAtIndexPath:(NSIndexPath *)indexPath withObject:(FLONETEASEVideoItemViewModel *)object {
    return object.cellHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 8;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return [[UIView alloc] init];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 1;
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return [[UIView alloc] init];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    
}

#pragma mark - refresh
- (void)headerRefreshAction {
    [super headerRefreshAction];
    
    self.requesting = YES;
    @weakify(self);
    [self.viewModel requestNewDataCompletion:^(BOOL newData) {
        @strongify(self);
        
        if (newData) {
            [self.tableView reloadData];
        }
        self.requesting = NO;
        self.viewModel.loading = NO;
        [self endHeaderRefresh];
    }];
}

- (void)footerRefreshAction {
    [super footerRefreshAction];
    
    self.requesting = YES;
    @weakify(self);
    [self.viewModel requestMoreDataCompletion:^(BOOL moreData) {
        @strongify(self);
        
        if (moreData) {
            [self.tableView reloadData];
        }
        self.requesting = NO;
        [self endFooterRefresh];
    }];
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
