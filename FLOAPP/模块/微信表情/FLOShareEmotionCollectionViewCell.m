//
//  FLOShareEmotionCollectionViewCell.m
//  FLOAPP
//
//  Created by 360doc on 2018/3/12.
//  Copyright © 2018年 Flolangka. All rights reserved.
//

#import "FLOShareEmotionCollectionViewCell.h"
#import "FLOLiveIdentityView.h"
#import "FLOGIFIdentityView.h"
#import "NSString+FLOUtil.h"

#import <Masonry.h>

@interface FLOShareEmotionCollectionViewCell ()

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) FLOLiveIdentityView *liveView;
@property (nonatomic, strong) FLOGIFIdentityView *gifView;
@property (nonatomic, strong) UIImageView *videoImageView;
@property (nonatomic, strong) UILabel *sizeLabel;

@end

@implementation FLOShareEmotionCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _imageView = [[UIImageView alloc] init];
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageView.clipsToBounds = YES;
        [self.contentView addSubview:_imageView];
        [_imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView).offset(0);
            make.right.equalTo(self.contentView).offset(0);
            make.top.equalTo(self.contentView).offset(0);
            make.bottom.equalTo(self.contentView).offset(0);
        }];
        
        //live标识
        _liveView = [[FLOLiveIdentityView alloc] init];
        CGSize liveViewSize = _liveView.bounds.size;
        [self.contentView addSubview:_liveView];
        [_liveView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView).offset(0);
            make.top.equalTo(self.contentView).offset(0);
            make.size.mas_equalTo(liveViewSize);
        }];
        
        //gif标识
        _gifView = [[FLOGIFIdentityView alloc] init];
        CGSize gifViewSize = _gifView.bounds.size;
        [self.contentView addSubview:_gifView];
        [_gifView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView).offset(0);
            make.top.equalTo(self.contentView).offset(0);
            make.size.mas_equalTo(gifViewSize);
        }];
        
        //视频标识
        _videoImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"video_youtube"]];
        [self.contentView addSubview:_videoImageView];
        [_videoImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(40, 40));
            make.center.equalTo(self.contentView);
        }];
        
        //原图大小
        _sizeLabel = [[UILabel alloc] init];
        _sizeLabel.textAlignment = NSTextAlignmentCenter;
        _sizeLabel.font = [UIFont systemFontOfSize:13];
        _sizeLabel.textColor = COLOR_RGB3SAME(255);
        _sizeLabel.backgroundColor = COLOR_RGB3SAMEAlpha(0, 0.4);
        [self.contentView addSubview:_sizeLabel];
        [_sizeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.contentView);
            make.bottom.equalTo(self.contentView).offset(-2);
            make.height.mas_equalTo(17);
            make.width.mas_equalTo(0);
        }];
        
        [self sizeStr:@""];
        [self gif:NO];
        [self livePhoto:NO];
        [self video:NO];
    }
    return self;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    
    [self image:nil];
    [self sizeStr:@""];
    [self gif:NO];
    [self livePhoto:NO];
    [self video:NO];
}

- (void)image:(UIImage *)image {
    _imageView.image = image;
}

- (void)sizeStr:(NSString *)str {
    _sizeLabel.text = str;
    
    if (Def_CheckStringClassAndLength(str)) {
        _sizeLabel.hidden = NO;
        
        float width = [str widthWithLimitHeight:17 fontSize:13];
        [_sizeLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(width+10);
        }];
    } else {
        _sizeLabel.hidden = YES;
    }
}

- (void)gif:(BOOL)b {
    _gifView.hidden = !b;
}

- (void)livePhoto:(BOOL)b {
    _liveView.hidden = !b;
}

- (void)video:(BOOL)b {
    _videoImageView.hidden = !b;
}

@end
