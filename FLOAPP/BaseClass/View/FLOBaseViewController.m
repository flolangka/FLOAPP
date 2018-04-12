//
//  FLOBaseViewController.m
//  FLOAPP
//
//  Created by 360doc on 2018/4/4.
//  Copyright © 2018年 Flolangka. All rights reserved.
//

#import "FLOBaseViewController.h"
#import "FLOBaseViewModel.h"

@interface FLOBaseViewController ()

@property (nonatomic, strong, readwrite) FLOBaseViewModel *viewModel;

@end

@implementation FLOBaseViewController

- (instancetype)initWithViewModel:(FLOBaseViewModel *)viewModel {
    self = [super init];
    if (self) {
        self.viewModel = viewModel;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self bindViewModel];
}

- (void)bindViewModel {
    // 导航栏标题
    RAC(self, title) = RACObserve(self.viewModel, title);
    
    // 加载转圈
    [RACObserve(self.viewModel, loading) subscribeNext:^(NSNumber *loading) {
        if (loading.boolValue) {
            Def_MBProgressShow;
        } else {
            Def_MBProgressHide;
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
