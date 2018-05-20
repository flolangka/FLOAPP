//
//  FLOWorkItemViewModel.h
//  FLOAPP
//
//  Created by 360doc on 2018/5/10.
//  Copyright © 2018年 Flolangka. All rights reserved.
//

#import <Foundation/Foundation.h>
@class WorkList;

@interface FLOWorkItemViewModel : NSObject

@property (nonatomic, strong, readonly) WorkList *item;
@property (nonatomic, assign, readonly) float cellHeight;

@property (nonatomic, copy  ) NSString *title;
@property (nonatomic, copy  ) NSString *timeStr;
@property (nonatomic, copy  ) NSString *desc;

@property (nonatomic, assign) BOOL editBtnHide;
@property (nonatomic, copy  ) NSString *titleRightBtnTitle;

@property (nonatomic, copy  ) NSArray <NSString *>*targets;
@property (nonatomic, copy  ) NSArray <NSNumber *>*targetsStatus;
@property (nonatomic, assign) BOOL targetBtnEnable;

@property (nonatomic, assign) BOOL showFinishBtn;

- (instancetype)initWithItem:(WorkList *)item;

/**
 item 修改后更新显示内容
 */
- (void)update;

@end
