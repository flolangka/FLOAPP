//
//  FLOWeiboStatusFoolerTableViewCell.h
//  XMPPChat
//
//  Created by admin on 15/12/17.
//  Copyright © 2015年 Flolangka. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FLOWeiboStatusModel;

@interface FLOWeiboStatusFoolerTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIButton *retweet;
@property (weak, nonatomic) IBOutlet UIButton *comment;

- (void)setValueWithStatus:(FLOWeiboStatusModel *)status;

@end
