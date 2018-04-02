//
//  FLOWeiboStatusTableViewCell.h
//  XMPPChat
//
//  Created by admin on 15/12/17.
//  Copyright © 2015年 Flolangka. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FLOWeiboStatusModel;

@interface FLOWeiboStatusTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *IconImageV;
@property (weak, nonatomic) IBOutlet UIImageView *verifiedImageV;
@property (weak, nonatomic) IBOutlet UIButton    *nameBtn;
@property (weak, nonatomic) IBOutlet UIImageView *levelImagev;
@property (weak, nonatomic) IBOutlet UILabel     *timeAgoLabel;
@property (weak, nonatomic) IBOutlet UILabel     *source;
@property (weak, nonatomic) IBOutlet UILabel     *sourceLabel;
@property (weak, nonatomic) IBOutlet UILabel     *statusText;
@property (weak, nonatomic) IBOutlet UIControl   *retweetBackControl;
@property (weak, nonatomic) IBOutlet UILabel     *retweetedLabel;

@property (weak, nonatomic) IBOutlet UIView *statusImageSuperV;
@property (weak, nonatomic) IBOutlet UIView *restatusImageSuperV;


- (void)setContentWithStatus:(FLOWeiboStatusModel *)status;
-(CGFloat)cellHeight4StatusModel:(FLOWeiboStatusModel *)status;

@end
