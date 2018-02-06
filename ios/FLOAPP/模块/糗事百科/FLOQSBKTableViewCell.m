//
//  FLOQSBKTableViewCell.m
//  FLOAPP
//
//  Created by 360doc on 2018/1/30.
//  Copyright © 2018年 Flolangka. All rights reserved.
//

#import "FLOQSBKTableViewCell.h"
#import "NSString+FLOUtil.h"

#import <Masonry.h>
#import <UIImageView+WebCache.h>

@interface FLOQSBKTableViewCell ()

@property (nonatomic, strong) UIView *myContentView;
@property (nonatomic, strong) UIImageView *userIconImgV;
@property (nonatomic, strong) UILabel *userNameLabel;
@property (nonatomic, strong) UILabel *createTimeLabel;
@property (nonatomic, strong) UILabel *contentLabel;
@property (nonatomic, strong) UIImageView *imgView;
@property (nonatomic, strong) UIImageView *videoPlayImgView;

@end

static float FLOQSBKContentFontSize = 16;

@implementation FLOQSBKTableViewCell

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
        make.top.equalTo(_myContentView).offset(15);
        make.left.equalTo(_myContentView).offset(15);
        make.size.mas_equalTo(CGSizeMake(35, 35));
    }];
    _userIconImgV.layer.cornerRadius = 35/2.;
    _userIconImgV.layer.masksToBounds = YES;
    
    //昵称
    _userNameLabel = [[UILabel alloc] init];
    [_myContentView addSubview:_userNameLabel];
    [_userNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_myContentView).offset(15);
        make.left.equalTo(_userIconImgV.mas_right).offset(15);
        make.right.equalTo(_myContentView).offset(-15);
        make.height.mas_equalTo(35);
    }];
    _userNameLabel.font = [UIFont systemFontOfSize:15];
    _userNameLabel.textColor = [UIColor darkGrayColor];
    
    //时间
    _createTimeLabel = [[UILabel alloc] init];
    [_myContentView addSubview:_createTimeLabel];
    [_createTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_userNameLabel);
        make.left.equalTo(_userIconImgV.mas_right).offset(15);
        make.right.equalTo(_myContentView).offset(-15);
        make.height.mas_equalTo(35);
    }];
    _createTimeLabel.font = [UIFont systemFontOfSize:12];
    _createTimeLabel.textColor = [UIColor lightGrayColor];
    _createTimeLabel.textAlignment = NSTextAlignmentRight;
    
    //正文
    _contentLabel = [[UILabel alloc] init];
    [_myContentView addSubview:_contentLabel];
    [_contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_userIconImgV.mas_bottom).offset(10);
        make.left.equalTo(_myContentView).offset(15);
        make.right.equalTo(_myContentView).offset(-15);
        make.height.mas_equalTo(24);
    }];
    _contentLabel.font = [UIFont systemFontOfSize:FLOQSBKContentFontSize];
    _contentLabel.textColor = COLOR_RGB3SAMEAlpha(0, 0.8);
    _contentLabel.numberOfLines = 0;
    
    //长按菜单
    UILongPressGestureRecognizer *recognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressGestureRecognizerHandle:)];
    [recognizer setMinimumPressDuration:1.0f];
    [_contentLabel addGestureRecognizer:recognizer];
    _contentLabel.userInteractionEnabled = YES;
    
    //图片
    _imgView = [[UIImageView alloc] init];
    [_myContentView addSubview:_imgView];
    [_imgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_contentLabel.mas_bottom).offset(12);
        make.left.equalTo(_contentLabel);
        make.right.equalTo(_contentLabel);
        //make.bottom.equalTo(_myContentView).offset(-15);
        make.height.mas_equalTo(100);
    }];
    _imgView.contentMode = UIViewContentModeScaleAspectFill;
    _imgView.clipsToBounds = YES;
    _imgView.userInteractionEnabled = YES;
    [_imgView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imgViewAction)]];
    
    //视频播放图片
    _videoPlayImgView = [[UIImageView alloc] init];
    [_imgView addSubview:_videoPlayImgView];
    [_videoPlayImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(_imgView);
        make.size.mas_equalTo(CGSizeMake(80, 80));
    }];
    _videoPlayImgView.image = [UIImage imageNamed:@"video_youtube"];
    
    return self;
}

- (void)imgViewAction {
    if (_imgAction) {
        _imgAction();
    }
}

- (void)longPressGestureRecognizerHandle:(UILongPressGestureRecognizer *)longPressGestureRecognizer {
    if (longPressGestureRecognizer.state == UIGestureRecognizerStateBegan){
        [self becomeFirstResponder];
        
        CGRect rect = _contentLabel.frame;
        rect.origin.y += 8+10;
        
        UIMenuController *menu = [UIMenuController sharedMenuController];
        [menu setMenuItems:@[[[UIMenuItem alloc] initWithTitle:@"复制" action:@selector(copyContent:)]]];
        [menu setTargetRect:rect inView:self];
        [menu setMenuVisible:YES animated:YES];
    }
}

- (BOOL)canBecomeFirstResponder{
    return YES;
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {
    if (action == @selector(copyContent:)) return YES;
    return NO;
}

- (void)copyContent:(id)sender {
    [[UIPasteboard generalPasteboard] setString:_contentLabel.attributedText.string];
}

//纯文本
- (void)configUserIcon:(NSString *)icon
              userName:(NSString *)name
            createTime:(NSString *)time
               content:(NSString *)content {
    [self UserIcon:icon
          userName:name
        createTime:time
           content:content
         imagePath:nil
         imageSize:CGSizeZero
             video:NO];
}

//图片
- (void)configUserIcon:(NSString *)icon
              userName:(NSString *)name
            createTime:(NSString *)time
               content:(NSString *)content
             imagePath:(NSString *)imgPath
             imageSize:(CGSize    )imgSize {
    [self UserIcon:icon
          userName:name
        createTime:time
           content:content
         imagePath:imgPath
         imageSize:imgSize
             video:NO];
}

//视频
- (void)configUserIcon:(NSString *)icon
              userName:(NSString *)name
            createTime:(NSString *)time
               content:(NSString *)content
          videoPicture:(NSString *)videoPicture
             videoSize:(CGSize    )videoSize {
    [self UserIcon:icon
          userName:name
        createTime:time
           content:content
         imagePath:videoPicture
         imageSize:videoSize
             video:YES];
}

- (void)UserIcon:(NSString *)icon
        userName:(NSString *)name
      createTime:(NSString *)time
         content:(NSString *)content
       imagePath:(NSString *)imgPath
       imageSize:(CGSize    )imgSize
           video:(BOOL      )video {
    [_userIconImgV sd_setImageWithURL:[NSURL URLWithString:icon]];
    _userNameLabel.text = name;
    _createTimeLabel.text = time;
    _contentLabel.attributedText = [self attributedContentWithContent:content];
    
    float imgHeight = 0;
    if (Def_CheckStringClassAndLength(imgPath)) {
        imgHeight = DEVICE_SCREEN_WIDTH/imgSize.width * imgSize.height;
        imgHeight = MIN(imgHeight, 600);
        
        [_imgView sd_setImageWithURL:[NSURL URLWithString:imgPath]];
    } else {
        _imgView.image = nil;
    }
    _videoPlayImgView.hidden = !video;
    
    //更新正文高度
    float height = [content heightWithLimitWidth:(DEVICE_SCREEN_WIDTH - 15 - 15) fontSize:FLOQSBKContentFontSize];
    [_contentLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(height);
    }];
    
    //更新图片区域高度
    [_imgView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(imgHeight);
    }];
}

//计算高度
+ (float)heightWithContent:(NSString *)content
                  imgSize:(CGSize    )imgSize {
    float height = 8 + 15 + 35 + 10;
    
    height += [content heightWithLimitWidth:(DEVICE_SCREEN_WIDTH - 15 - 15) fontSize:FLOQSBKContentFontSize];
    
    height += 12;
    
    float imgHeight = 0;
    if (imgSize.height > 0) {
        imgHeight = DEVICE_SCREEN_WIDTH/imgSize.width * imgSize.height;
        imgHeight = MIN(imgHeight, 600);
    }
    
    height += imgHeight + 15;
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
