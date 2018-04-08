//
//  MVVMRouter.h
//  FLOAPP
//
//  Created by 360doc on 2018/4/8.
//  Copyright © 2018年 Flolangka. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FLOBaseViewController;
@class FLOBaseViewModel;

@interface MVVMRouter : NSObject

+ (FLOBaseViewController *)viewControllerForViewModel:(FLOBaseViewModel *)viewModel;

@end
