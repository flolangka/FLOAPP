//
//  FLOTableViewController.h
//  FLOAPP
//
//  Created by 360doc on 2018/4/4.
//  Copyright © 2018年 Flolangka. All rights reserved.
//

#import "FLOBaseViewController.h"

@interface FLOTableViewController : FLOBaseViewController
<UITableViewDelegate,
UITableViewDataSource>

@property (nonatomic, strong, readonly) UITableView *tableView;
@property (nonatomic, assign) BOOL requesting;

//子类提供cell
- (UITableViewCell *)tableView:(UITableView *)tableView dequeueReusableCellForIndexPath:(NSIndexPath *)indexPath;

//子类配置cell内容
- (void)configCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath withObject:(id)object;

//子类设置cell高度
- (float)heightForRowAtIndexPath:(NSIndexPath *)indexPath withObject:(id)object;

- (void)addHeaderRefresh;
- (void)headerRefreshAction;
- (void)endHeaderRefresh;
- (void)removeHeaderRefresh;

- (void)addFooterRefresh;
- (void)footerRefreshAction;
- (void)endFooterRefresh;
- (void)removeFooterRefresh;

@end
