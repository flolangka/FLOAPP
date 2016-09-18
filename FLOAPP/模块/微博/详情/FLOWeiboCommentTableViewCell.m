//
//  FLOWeiboCommentTableViewCell.m
//  XMPPChat
//
//  Created by admin on 15/12/20.
//  Copyright © 2015年 Flolangka. All rights reserved.
//

#import "FLOWeiboCommentTableViewCell.h"
#import "FLOWeiboCommentModel.h"
#import "FLOWeiboUserModel.h"
#import <SDWebImage/UIImageView+WebCache.h>

@implementation FLOWeiboCommentTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setContentWithCommentModel:(FLOWeiboCommentModel *)commentModel
{
    [self.nameBtn setTitle:commentModel.userInfo.name forState:UIControlStateNormal];
    self.timeLabel.text = commentModel.time;
    self.textL.text = commentModel.commentsText;
    [self.iconView sd_setImageWithURL:[NSURL URLWithString:commentModel.userInfo.userIconURL]];
}

@end
