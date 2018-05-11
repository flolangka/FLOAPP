//
//  FLOCollectionViewLayout.h
//  FLOAPP
//
//  Created by 360doc on 2017/1/5.
//  Copyright © 2017年 Flolangka. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FLOCollectionViewLayout : UICollectionViewLayout

// 几列
@property (nonatomic, assign) NSInteger numberOfColum;

// item直接间距
@property (nonatomic, assign) CGFloat horizontalSpace;
@property (nonatomic, assign) CGFloat verticalSpace;

// item高度回调
@property (nonatomic, copy) CGFloat(^itemHeight)(NSIndexPath *);

@end
