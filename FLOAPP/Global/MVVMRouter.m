//
//  MVVMRouter.m
//  FLOAPP
//
//  Created by 360doc on 2018/4/8.
//  Copyright © 2018年 Flolangka. All rights reserved.
//

#import "MVVMRouter.h"
#import "FLOBaseViewController.h"
#import "FLOBaseViewModel.h"

@implementation MVVMRouter

+ (FLOBaseViewController *)viewControllerForViewModel:(FLOBaseViewModel *)viewModel {
    NSString *className = [[self routerInfo] objectForKey:NSStringFromClass([viewModel class])];
    
    NSParameterAssert(Def_CheckStringClassAndLength(className));
    NSParameterAssert([NSClassFromString(className) isSubclassOfClass:[FLOBaseViewController class]]);
    
    return [[NSClassFromString(className) alloc] initWithViewModel:viewModel];
}

+ (NSDictionary *)routerInfo {
    return @{};
}

@end
