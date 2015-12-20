//
//  FLOWeiboStatusTableViewCell.m
//  XMPPChat
//
//  Created by admin on 15/12/17.
//  Copyright © 2015年 Flolangka. All rights reserved.
//

#import "FLOWeiboStatusTableViewCell.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "FLOWeiboUserModel.h"
#import "FLOWeiboStatusModel.h"

@implementation FLOWeiboStatusTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setContentWithStatus:(FLOWeiboStatusModel *)status
{
    FLOWeiboUserModel *userInfo  = status.user;
    
    // 设置头像
    [self.IconImageV sd_setImageWithURL:[NSURL URLWithString:userInfo.userIconURL]];
    
    // 设置微博认证图标
    if (userInfo.isVerified) {
        self.verifiedImageV.image = [UIImage imageNamed:@"avatar_vip"];
    } else {
        self.verifiedImageV.image = nil;
    }
    
    // 设置名字与等级图标
    NSAttributedString *attributedStr;
    if (userInfo.level > 0) {
        NSString *imageName = [NSString stringWithFormat:@"common_icon_membership_level%d",userInfo.level];
        self.levelImagev.image = [UIImage imageNamed:imageName];
        attributedStr = [[NSAttributedString alloc] initWithString:userInfo.name attributes:@{NSForegroundColorAttributeName:[UIColor redColor]}];
    } else {
        self.levelImagev.image = nil;
        attributedStr = [[NSAttributedString alloc] initWithString:userInfo.name attributes:@{NSForegroundColorAttributeName:[UIColor darkGrayColor]}];
    }
    [self.nameBtn setAttributedTitle:attributedStr forState:UIControlStateNormal];
    
    self.timeAgoLabel.text = status.timeAgo;
    
    // 当来源为空时，隐藏“来自”
    if (status.source.length > 1)
    {
        self.source.hidden = NO;
        self.sourceLabel.text = status.source;
    } else {
        self.source.hidden = YES;
        self.sourceLabel.text = nil;
    }
    
    // 将 @...: #...# 内容蓝色
    self.statusText.text   = status.text;
    //    [self analysisStringToEmotion:status.text];
    
    CGFloat labelWidth = [UIScreen mainScreen].bounds.size.width-16;
    if (status.reStatus) {
        self.retweetBackControl.hidden = NO;
        NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"@%@ ",status.reStatus.user.name] attributes:@{NSForegroundColorAttributeName:[UIColor colorWithRed:0.1 green:0.3 blue:1 alpha:0.8]}];
        NSAttributedString *text = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@":%@",status.reStatus.text] attributes:@{NSForegroundColorAttributeName:[UIColor darkTextColor]}];
        [str appendAttributedString:text];
        self.retweetedLabel.attributedText = str;
        
        //绑定转发微博图片
        //绑定图片
        NSArray *imageDicArray = status.reStatus.pic_urls;
        //将所有url取出
        NSArray *imageUrlarray = [imageDicArray valueForKeyPath:@"thumbnail_pic"];
        [self layout:imageUrlarray forView:self.restatusImageSuperV];
        [self layout:nil forView:self.statusImageSuperV];
        
        CGRect retweetedLabelRect = [_retweetedLabel textRectForBounds:CGRectMake(0, 0, labelWidth, 1000) limitedToNumberOfLines:0];
        NSArray *reConstraintArray = _retweetedLabel.constraints;
        for (NSLayoutConstraint *constraint in reConstraintArray) {
            if (constraint.firstAttribute == NSLayoutAttributeHeight) {
                constraint.constant = retweetedLabelRect.size.height+10;
            }
        }
    } else {
        self.retweetBackControl.hidden = YES;
        self.retweetedLabel.text = nil;
        
        //绑定自有微博图片
        //绑定图片
        NSArray *imageDicArray = status.pic_urls;
        //将所有url取出
        NSArray *imageUrlarray = [imageDicArray valueForKeyPath:@"thumbnail_pic"];
        [self layout:imageUrlarray forView:self.statusImageSuperV];
        [self layout:nil forView:self.restatusImageSuperV];
        
        NSArray *reConstraintArray = _retweetedLabel.constraints;
        for (NSLayoutConstraint *constraint in reConstraintArray) {
            if (constraint.firstAttribute == NSLayoutAttributeHeight) {
                constraint.constant = 0;
            }
        }
    }
    
    //修改正文高度约束
    CGRect statusLabelRect = [_statusText textRectForBounds:CGRectMake(0, 0, labelWidth, 1000) limitedToNumberOfLines:0];
    NSArray *constraintArray = _statusText.constraints;
    for (NSLayoutConstraint *constraint in constraintArray) {
        if (constraint.firstAttribute == NSLayoutAttributeHeight) {
            constraint.constant = statusLabelRect.size.height;
        }
    }
}

-(CGFloat)cellHeight4StatusModel:(FLOWeiboStatusModel *)status{
    //计算出除去图片的所有高度
    CGFloat cellHeight = 70;
    
    //绑定model
    //绑定内容
    self.statusText.text   = status.text;
    if (status.reStatus) {
        self.retweetBackControl.hidden = NO;
        self.retweetedLabel.text = [NSString stringWithFormat:@"@%@ :%@", status.reStatus.user.name, status.reStatus.text];
    } else {
        self.retweetBackControl.hidden = YES;
        self.retweetedLabel.text = nil;
    }
    
    //计算2个label的高度
    CGFloat labelWidth = [UIScreen mainScreen].bounds.size.width-16;
    CGRect statusLabelRect = [_statusText textRectForBounds:CGRectMake(0, 0, labelWidth, 1000) limitedToNumberOfLines:0];
    CGRect retweetedLabelRect = [_retweetedLabel textRectForBounds:CGRectMake(0, 0, labelWidth, 1000) limitedToNumberOfLines:0];
    
    cellHeight = cellHeight + statusLabelRect.size.height + retweetedLabelRect.size.height+10;
    
    FLOWeiboStatusModel *reStatus = status.reStatus;
    NSInteger countImage = 0;
    if (reStatus) {
        //转发微博图片数量
        countImage = reStatus.pic_urls.count;
    }else {
        //正文图片的张数
        countImage = status.pic_urls.count;
    }
    
    if (countImage != 0) {
        //显示的行数
        NSInteger line = ceil((CGFloat)countImage / 4.f);
        
        //图片显示需要的高度
        CGFloat imageWidth = ([UIScreen mainScreen].bounds.size.width-16-15)/4.;
        NSInteger imageBoxHeight = line * imageWidth + 16 + (line - 1) * 5;
        cellHeight += imageBoxHeight;
    }
    
    return cellHeight;
}

-(void)layout:(NSArray *)imageArray forView:(UIView *)view{
    //先移除之前的所有子视图图片
    NSArray *subViews = view.subviews;
    for (UIView *subView in subViews) {
        [subView removeFromSuperview];
    }
    
    //计算出需要的高度
    //显示的行数
    NSInteger line = ceil((CGFloat)imageArray.count / 4.f);
    
    //图片显示需要的高度
    CGFloat imageWidth = ([UIScreen mainScreen].bounds.size.width-16-15)/4.;
    NSInteger imageBoxHeight = line * imageWidth + 16 + (line - 1) * 5;
    //找到约束,更改为需要的高度
    NSArray *constraintArray = view.constraints;
    for (NSLayoutConstraint *constraint in constraintArray) {
        if (constraint.firstAttribute == NSLayoutAttributeHeight) {
            if (imageArray.count != 0) {
                constraint.constant = imageBoxHeight;
            }else{
                //更改高度为0;
                constraint.constant = 0;
            }
            
        }
    }
    
    
    for (int i = 0; i < imageArray.count; i ++) {
        NSString *imageURL = imageArray[i];
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(i % 4 * (imageWidth + 5), 8 + (imageWidth + 5)* (i/4), imageWidth, imageWidth)];
        [view addSubview:imageView];
        imageView.backgroundColor = [UIColor lightGrayColor];
        [imageView sd_setImageWithURL:[NSURL URLWithString:imageURL]];
    }
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
