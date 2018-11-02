//
//  FLORandomViewController.h
//  FLOAPP
//
//  Created by 360doc on 2018/10/31.
//  Copyright © 2018 Flolangka. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Random;

NS_ASSUME_NONNULL_BEGIN

@interface FLORandomViewController : UIViewController

//随机项目
@property (nonatomic, strong) Random *randomModel;

@end

NS_ASSUME_NONNULL_END
