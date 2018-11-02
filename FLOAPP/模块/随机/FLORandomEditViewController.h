//
//  FLORandomEditViewController.h
//  FLOAPP
//
//  Created by 360doc on 2018/11/2.
//  Copyright © 2018 Flolangka. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Random;

NS_ASSUME_NONNULL_BEGIN

@interface FLORandomEditViewController : UIViewController

//修改项目时传
@property (nonatomic, strong) Random *editRandom;

@end

NS_ASSUME_NONNULL_END
