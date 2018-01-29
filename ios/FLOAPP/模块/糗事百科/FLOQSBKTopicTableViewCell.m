//
//  FLOQSBKTopicTableViewCell.m
//  FLOAPP
//
//  Created by 360doc on 2018/1/29.
//  Copyright © 2018年 Flolangka. All rights reserved.
//

#import "FLOQSBKTopicTableViewCell.h"
#import "FLOQSBKTopicItem.h"
#import "NSString+FLOUtil.h"

#import <Masonry.h>
#import <UIImageView+WebCache.h>

@interface FLOQSBKTopicTableViewCell ()

@property (nonatomic, strong) UIView *myContentView;
@property (nonatomic, strong) UIImageView *userIconImgV;
@property (nonatomic, strong) UILabel *userNameLabel;
@property (nonatomic, strong) UILabel *createTimeLabel;
@property (nonatomic, strong) UILabel *contentLabel;
@property (nonatomic, strong) UIView *pictureView;

@end

static float FLOQSBKTopicContentFontSize = 17;
static float FLOQSBKTopicImageSpace = 8;

@implementation FLOQSBKTopicTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    self.backgroundColor = COLOR_RGB(244, 244, 248);
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    _myContentView = [[UIView alloc] init];
    [self.contentView addSubview:_myContentView];
    [_myContentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView).offset(8);
        make.left.equalTo(self.contentView);
        make.right.equalTo(self.contentView);
        make.bottom.equalTo(self.contentView);
    }];
    _myContentView.backgroundColor = COLOR_RGB3SAME(255);
    
    //头像
    _userIconImgV = [[UIImageView alloc] init];
    [_myContentView addSubview:_userIconImgV];
    [_userIconImgV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_myContentView).offset(15);
        make.top.equalTo(_myContentView).offset(15);
        make.size.mas_equalTo(CGSizeMake(35, 35));
    }];
    _userIconImgV.layer.cornerRadius = 35/2.;
    _userIconImgV.layer.masksToBounds = YES;
    
    //昵称
    _userNameLabel = [[UILabel alloc] init];
    [_myContentView addSubview:_userNameLabel];
    [_userNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_userIconImgV.mas_right).offset(15);
        make.right.equalTo(_myContentView).offset(-15);
        make.top.equalTo(_myContentView).offset(15);
        make.height.mas_equalTo(20);
    }];
    _userNameLabel.font = [UIFont systemFontOfSize:15];
    _userNameLabel.textColor = [UIColor darkGrayColor];
    
    //时间
    _createTimeLabel = [[UILabel alloc] init];
    [_myContentView addSubview:_createTimeLabel];
    [_createTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_userIconImgV.mas_right).offset(15);
        make.right.equalTo(_myContentView).offset(-15);
        make.top.equalTo(_userNameLabel);
        make.height.mas_equalTo(20);
    }];
    _createTimeLabel.font = [UIFont systemFontOfSize:12];
    _createTimeLabel.textColor = [UIColor lightGrayColor];
    _createTimeLabel.textAlignment = NSTextAlignmentRight;
    
    //正文
    _contentLabel = [[UILabel alloc] init];
    [_myContentView addSubview:_contentLabel];
    [_contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_userIconImgV.mas_right).offset(15);
        make.right.equalTo(_createTimeLabel);
        make.top.equalTo(_userNameLabel.mas_bottom).offset(10);
        make.height.mas_equalTo(24);
    }];
    _contentLabel.font = [UIFont systemFontOfSize:FLOQSBKTopicContentFontSize];
    _contentLabel.numberOfLines = 0;
    
    //图片
    _pictureView = [[UIView alloc] init];
    [_myContentView addSubview:_pictureView];
    [_pictureView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_contentLabel.mas_bottom).offset(12);
        make.left.equalTo(_contentLabel);
        make.right.equalTo(_contentLabel);
        make.bottom.equalTo(_myContentView).offset(-15);
        make.height.mas_equalTo(100);
    }];
    
    float imgSize = [self imgSize];
    for (int i = 0; i < 6; i++) {
        UIImageView *imgV = [[UIImageView alloc] initWithFrame:CGRectMake(i%3 * (imgSize + FLOQSBKTopicImageSpace), i/3 * (imgSize + FLOQSBKTopicImageSpace), imgSize, imgSize)];
        imgV.tag = 1000 + i;
        imgV.contentMode = UIViewContentModeScaleAspectFill;
        imgV.clipsToBounds = YES;
        [_pictureView addSubview:imgV];
    }
    
    return self;
}

- (float)imgSize {
    return floorf((DEVICE_SCREEN_WIDTH - 15 - 35 - 15 - 2 * FLOQSBKTopicImageSpace - 15)/3.);
}

- (void)configTopicItem:(FLOQSBKTopicItem *)item {
    [_userIconImgV sd_setImageWithURL:[NSURL URLWithString:item.userIcon]];
    _userNameLabel.text = item.userName;
    _createTimeLabel.text = item.createTime;
    _contentLabel.attributedText = [self attributedContentWithContent:item.content];
    
    for (int i = 0; i < 6; i++) {
        UIImageView *imgV = [_pictureView viewWithTag:1000 + i];
        
        if (i < item.pictures.count) {
            [imgV sd_setImageWithURL:[NSURL URLWithString:item.pictures[i]]];
            imgV.hidden = NO;
        } else {
            imgV.hidden = YES;
        }
    }    
    
    //更新正文高度
    float height = [item.content heightWithLimitWidth:(DEVICE_SCREEN_WIDTH - 15 - 35 - 15 - 15) fontSize:FLOQSBKTopicContentFontSize];
    [_contentLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(height);
    }];
    
    //更新图片区域高度
    float imgSize = [self imgSize];
    imgSize = item.pictures.count > 3 ? (imgSize*2 + FLOQSBKTopicImageSpace) : imgSize;
    [_pictureView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(imgSize);
    }];
}

- (NSAttributedString *)attributedContentWithContent:(NSString *)text {
    NSMutableAttributedString *muAttText = [[NSMutableAttributedString alloc] initWithString:text];
    
    NSArray *topics = [[self regexTopic] matchesInString:text options:0 range:NSMakeRange(0, text.length)];
    for (NSTextCheckingResult *rs in topics) {
        [muAttText addAttribute:NSForegroundColorAttributeName value:COLOR_RGB(100, 156, 213) range:rs.range];
    }
    
    return muAttText;
}

//匹配#。。#
- (NSRegularExpression *)regexTopic {
    static NSRegularExpression *regex;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        regex = [NSRegularExpression regularExpressionWithPattern:@"#[^@#]+?#" options:kNilOptions error:NULL];
    });
    return regex;
}

@end
