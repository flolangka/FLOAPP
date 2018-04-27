//
//  FLOSortViewModel.h
//  FLOAPP
//
//  Created by 360doc on 2018/4/27.
//  Copyright © 2018年 Flolangka. All rights reserved.
//

#import "FLOBaseViewModel.h"

@interface FLOSortViewModel : FLOBaseViewModel

@property (nonatomic, assign) BOOL sorting;
@property (nonatomic, assign, readonly) NSUInteger sortNumber;

@end
