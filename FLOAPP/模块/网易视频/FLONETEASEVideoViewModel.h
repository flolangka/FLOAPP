//
//  FLONETEASEVideoViewModel.h
//  FLOAPP
//
//  Created by 360doc on 2018/4/12.
//  Copyright © 2018年 Flolangka. All rights reserved.
//

#import "FLOTableViewModel.h"

@interface FLONETEASEVideoViewModel : FLOTableViewModel

- (void)requestNewDataCompletion:(void(^)(BOOL newData))completion;
- (void)requestMoreDataEndRequest:(void(^)())endRequest completion:(void(^)(NSIndexSet *indexSet))completion;

@end
