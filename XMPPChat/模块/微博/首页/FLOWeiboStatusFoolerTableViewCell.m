//
//  FLOWeiboStatusFoolerTableViewCell.m
//  XMPPChat
//
//  Created by admin on 15/12/17.
//  Copyright © 2015年 Flolangka. All rights reserved.
//

#import "FLOWeiboStatusFoolerTableViewCell.h"
#import "FLOWeiboStatusModel.h"

@implementation FLOWeiboStatusFoolerTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setValueWithStatus:(FLOWeiboStatusModel *)status
{
    [self.retweet setTitle:[NSString stringWithFormat:@" %lu",(long)status.reposts_count] forState:UIControlStateNormal];
    [self.comment setTitle:[NSString stringWithFormat:@" %lu",(long)status.comments_count] forState:UIControlStateNormal];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
