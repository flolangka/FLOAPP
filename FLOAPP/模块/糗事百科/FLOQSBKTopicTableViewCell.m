//
//  FLOQSBKTopicTableViewCell.m
//  FLOAPP
//
//  Created by 360doc on 2018/1/29.
//  Copyright © 2018年 Flolangka. All rights reserved.
//

#import "FLOQSBKTopicTableViewCell.h"
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

static float FLOQSBKTopicContentFontSize = 16;
static float FLOQSBKTopicImageSpace = 8;

@implementation FLOQSBKTopicTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    self.backgroundColor = COLOR_HEX(0xefeff4);
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
    _contentLabel.textColor = COLOR_RGB3SAMEAlpha(0, 0.8);
    _contentLabel.numberOfLines = 0;
    
    //图片
    _pictureView = [[UIView alloc] init];
    [_myContentView addSubview:_pictureView];
    [_pictureView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_contentLabel.mas_bottom).offset(12);
        make.left.equalTo(_contentLabel);
        make.right.equalTo(_contentLabel);
        //make.bottom.equalTo(_myContentView).offset(-15);
        make.height.mas_equalTo(100);
    }];
    [_pictureView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(pictureViewAction:)]];
    
    float imgSize = [[self class] imgSize];
    for (int i = 0; i < 6; i++) {
        UIImageView *imgV = [[UIImageView alloc] initWithFrame:CGRectMake(i%3 * (imgSize + FLOQSBKTopicImageSpace), i/3 * (imgSize + FLOQSBKTopicImageSpace), imgSize, imgSize)];
        imgV.tag = 1000 + i;
        imgV.contentMode = UIViewContentModeScaleAspectFill;
        imgV.clipsToBounds = YES;
        [_pictureView addSubview:imgV];
    }
    
    return self;
}

- (void)pictureViewAction:(UITapGestureRecognizer *)tap {
    CGPoint point = [tap locationInView:_pictureView];
    
    float imgSize = [[self class] imgSize];
    NSInteger index = (int)(point.x / imgSize) + (int)(point.y / imgSize) * 3;
    if (_imgAction) {
        _imgAction(index);
    }
}

+ (float)imgSize {
    return floorf((MYAPPConfig.screenWidth - 15 - 35 - 15 - 2 * FLOQSBKTopicImageSpace - 15)/3.);
}

- (void)configUserIcon:(NSString *)icon
              userName:(NSString *)name
            createTime:(NSString *)time
               content:(NSString *)content
              pictures:(NSArray *)pictures; {
    [_userIconImgV sd_setImageWithURL:[NSURL URLWithString:icon] placeholderImage:[UIImage imageNamed:@"usericon_Placeholder"]];
    _userNameLabel.text = name;
    _createTimeLabel.text = time;
    _contentLabel.attributedText = [self attributedContentWithContent:content];
    
    for (int i = 0; i < 6; i++) {
        UIImageView *imgV = [_pictureView viewWithTag:1000 + i];
        
        if (i < pictures.count) {
            [imgV sd_setImageWithURL:[NSURL URLWithString:pictures[i]]];
            imgV.hidden = NO;
        } else {
            imgV.hidden = YES;
        }
    }    
    
    //更新正文高度
    float height = [content heightWithLimitWidth:(MYAPPConfig.screenWidth - 15 - 35 - 15 - 15) fontSize:FLOQSBKTopicContentFontSize];
    [_contentLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(height);
    }];
    
    //更新图片区域高度
    float imgSize = [[self class] imgSize];
    imgSize = pictures.count > 3 ? (imgSize*2 + FLOQSBKTopicImageSpace) : imgSize;
    [_pictureView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(imgSize);
    }];
}

//计算高度
+ (float)heightWithContent:(NSString *)content
              pictureCount:(NSInteger )count {
    float height = 8 + 15 + 20 + 10;
    
    height += [content heightWithLimitWidth:(MYAPPConfig.screenWidth - 15 - 35 - 15 - 15) fontSize:FLOQSBKTopicContentFontSize];
    
    height += 12;
    
    float imgSize = [self imgSize];
    imgSize = count > 3 ? (imgSize*2 + FLOQSBKTopicImageSpace) : imgSize;
    
    height += imgSize + 15;
    return height;
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
