//
//  FLOBaseViewController.h
//  FLOAPP
//
//  Created by 360doc on 2018/4/4.
//  Copyright © 2018年 Flolangka. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FLOBaseViewModel.h"

@interface FLOBaseViewController : UIViewController

@property (nonatomic, strong, readonly) FLOBaseViewModel *viewModel;

- (instancetype)initWithViewModel:(FLOBaseViewModel *)viewModel;

- (void)bindViewModel;

@end
