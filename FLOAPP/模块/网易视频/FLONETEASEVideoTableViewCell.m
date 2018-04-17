//
//  FLONETEASEVideoTableViewCell.m
//  FLOAPP
//
//  Created by 360doc on 2018/4/12.
//  Copyright © 2018年 Flolangka. All rights reserved.
//

#import "FLONETEASEVideoTableViewCell.h"
#import "NSString+FLOUtil.h"
#import "FLOVideoIdentityView.h"
#import <Masonry.h>
#import <UIImageView+WebCache.h>

@interface FLONETEASEVideoTableViewCell ()

@property (nonatomic, strong, readwrite) FLONETEASEVideoItemViewModel *viewModel;

@property (weak, nonatomic) IBOutlet UIImageView *coverImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *userIconImageView;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *replyInfoLabel;
@property (nonatomic, strong) UILabel *playCountLabel;
@property (nonatomic, strong) UILabel *lengthLabel;

@end

@implementation FLONETEASEVideoTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    [self createSubview];
}

- (void)createSubview {
    //视频区域 16:9
    
    //播放次数
    _playCountLabel = [[UILabel alloc] init];
    _playCountLabel.textColor = [UIColor whiteColor];
    _playCountLabel.font = [UIFont systemFontOfSize:14];
    [_coverImageView addSubview:_playCountLabel];
    [_playCountLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_coverImageView.mas_left).offset(10);
        make.bottom.equalTo(_coverImageView.mas_bottom).offset(-7);
        make.size.mas_equalTo(CGSizeMake(200, 21));
    }];
    
    //时长
    _lengthLabel = [[UILabel alloc] init];
    _lengthLabel.textColor = [UIColor whiteColor];
    _lengthLabel.textAlignment = NSTextAlignmentRight;
    _lengthLabel.font = [UIFont systemFontOfSize:14];
    [_coverImageView addSubview:_lengthLabel];
    [_lengthLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(_coverImageView.mas_right).offset(-10);
        make.bottom.equalTo(_coverImageView.mas_bottom).offset(-7);
        make.size.mas_equalTo(CGSizeMake(200, 21));
    }];
    
    //用户头像
    _userIconImageView.layer.cornerRadius = 15;
    _userIconImageView.layer.masksToBounds = YES;
    _userIconImageView.layer.borderWidth = 1;
    _userIconImageView.layer.borderColor = COLOR_HEXAlpha(0x666666, 0.2).CGColor;
    
    //视频标识
    FLOVideoIdentityView *videoIdentityView = [FLOVideoIdentityView videoIdentityView];
    [_coverImageView addSubview:videoIdentityView];
    [videoIdentityView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(_coverImageView);
        make.size.mas_equalTo(videoIdentityView.bounds.size);
    }];
}

//播放视频
- (void)playWithPlayerLayer:(AVPlayerLayer *)playerLayer {
    playerLayer.frame = CGRectMake(0, 0, MYAPPConfig.screenWidth-24, (MYAPPConfig.screenWidth-24)*9/16.);
    
    AVPlayerItem *playerItem = [AVPlayerItem playerItemWithURL:[NSURL URLWithString:self.viewModel.item.url_m3u8]];
    [playerLayer.player replaceCurrentItemWithPlayerItem:playerItem];
    [playerLayer.player play];
    
    [_coverImageView.layer addSublayer:playerLayer];
}

//显示内容
- (void)bindViewModel:(FLONETEASEVideoItemViewModel *)viewModel {
    self.viewModel = viewModel;
    
    [_coverImageView sd_setImageWithURL:_viewModel.coverImageUrl];
    _titleLabel.text = viewModel.title;
    [_userIconImageView sd_setImageWithURL:_viewModel.userIconUrl placeholderImage:[UIImage imageNamed:@"usericon_Placeholder"]];
    _userNameLabel.text = viewModel.userName;
    _replyInfoLabel.attributedText = viewModel.replyAttStr;
    _playCountLabel.text = viewModel.playCountStr;
    _lengthLabel.text = viewModel.lengthStr;    
}

//计算cell高度
+ (float)heightWithViewModel:(FLONETEASEVideoItemViewModel *)viewModel {
    float titleHeight = [viewModel.title heightWithLimitWidth:MYAPPConfig.screenWidth-24 fontSize:17];
    
    return ceilf(12 + (MYAPPConfig.screenWidth-24)*9/16. + 15 + titleHeight + 12 + 30 + 12);
}

@end
