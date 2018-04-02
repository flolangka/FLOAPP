//
//  FLONetWorkHistoryTableViewController.h
//  XMPPChat
//
//  Created by 沈敏 on 16/9/5.
//  Copyright © 2016年 Flolangka. All rights reserved.
//

#import <UIKit/UIKit.h>

@class NetWork;

@interface FLONetWorkHistoryTableViewController : UITableViewController

@property (nonatomic, copy) void(^didSelectData)(NSString *url,NSString *para);

@end
