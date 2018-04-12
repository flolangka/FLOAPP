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


@end
