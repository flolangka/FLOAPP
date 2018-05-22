//
//  FLOMainCollectionViewLayout.h
//  FLOAPP
//
//  Created by 360doc on 2018/5/22.
//  Copyright © 2018年 Flolangka. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FLOMainCollectionViewLayout : UICollectionViewLayout

@property (nonatomic, assign) CGSize itemSize;//item的size
@property (nonatomic, assign) UIEdgeInsets contentInsets;//列表的内边距
@property (nonatomic, assign) NSInteger numberOfColumnsPerPage;//每页列数
@property (nonatomic, assign) CGFloat fixedLineSpacing;//item之间的纵向固定间隙

- (NSInteger)numberOfPages;

@end
