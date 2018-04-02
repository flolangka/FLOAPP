//
//  FLOWeiboCommentTableViewCell.h
//  XMPPChat
//
//  Created by admin on 15/12/20.
//  Copyright © 2015年 Flolangka. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FLOWeiboCommentModel;

@interface FLOWeiboCommentTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *iconView;
@property (weak, nonatomic) IBOutlet UIButton *nameBtn;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *textL;

- (void)setContentWithCommentModel:(FLOWeiboCommentModel *)commentModel;

@end
