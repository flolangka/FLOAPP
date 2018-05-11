//
//  FLOWorkItemEditViewController.h
//  FLOAPP
//
//  Created by 360doc on 2018/5/11.
//  Copyright © 2018年 Flolangka. All rights reserved.
//

#import <UIKit/UIKit.h>
@class WorkList;

@interface FLOWorkItemEditViewController : UIViewController

//修改时需要传
@property (nonatomic, strong) WorkList *editItem;

//编辑完成回调
@property (nonatomic, copy  ) void(^editCompletion)(WorkList *item);

@end
