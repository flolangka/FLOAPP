//
//  FLOAlgorithmViewModel.h
//  FLOAPP
//
//  Created by 360doc on 2018/4/27.
//  Copyright © 2018年 Flolangka. All rights reserved.
//

#import "FLOTableViewModel.h"

@class FLOBaseViewController;

@interface FLOAlgorithmViewModel : FLOTableViewModel

- (NSString *)cellTitleForIndexPath:(NSIndexPath *)indexPath;
- (FLOBaseViewController *)pushViewControllerForIndexPath:(NSIndexPath *)indexPath;

@end
