//
//  FLOMusicViewController.m
//  FLOAPP
//
//  Created by 沈敏 on 2018/5/8.
//  Copyright © 2018年 Flolangka. All rights reserved.
//

#import "FLOMusicViewController.h"

@implementation FLOMusicViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    MDCActivityIndicator *activityIndicator = [[MDCActivityIndicator alloc] init];
    [activityIndicator sizeToFit];
    [self.view addSubview:activityIndicator];
    
    // To make the activity indicator appear:
    [activityIndicator startAnimating];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        // To make the activity indicator disappear:
        [activityIndicator stopAnimating];
    });
}

@end
