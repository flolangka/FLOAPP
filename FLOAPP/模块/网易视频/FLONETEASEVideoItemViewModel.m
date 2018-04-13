//
//  FLONETEASEVideoItemViewModel.m
//  FLOAPP
//
//  Created by 360doc on 2018/4/12.
//  Copyright © 2018年 Flolangka. All rights reserved.
//

#import "FLONETEASEVideoItemViewModel.h"

@interface FLONETEASEVideoItemViewModel ()

@property (nonatomic, strong, readwrite) FLONETEASEVideoItem *item;

@end

@implementation FLONETEASEVideoItemViewModel

- (instancetype)initWithItem:(FLONETEASEVideoItem *)item {
    self = [super init];
    if (self) {
        _item = item;
        
        _coverImageUrl = [NSURL URLWithString:item.coverImagePath];
        _title = item.title;
        _userIconUrl = [NSURL URLWithString:item.userIcon];
        _userName = item.userName;
        
        UIFont *font = [UIFont systemFontOfSize:14];
        NSMutableAttributedString *muAttStr = [[NSMutableAttributedString alloc] init];
        //点赞
        {
            NSTextAttachment *att = [[NSTextAttachment alloc] init];
            att.image = [UIImage imageNamed:@"statusdetail_icon_like"];
            att.bounds = CGRectMake(0, -2.5, font.pointSize, font.pointSize);
            
            [muAttStr appendAttributedString:[NSAttributedString attributedStringWithAttachment:att]];
            [muAttStr appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@" %@   ", [FLOUtil integerStr_10000:item.voteCount]] attributes:@{NSFontAttributeName: font}]];
        }
        //评论
        {
            NSTextAttachment *att = [[NSTextAttachment alloc] init];
            att.image = [UIImage imageNamed:@"statusdetail_icon_comment"];
            att.bounds = CGRectMake(0, -2.5, font.pointSize, font.pointSize);
            
            [muAttStr appendAttributedString:[NSAttributedString attributedStringWithAttachment:att]];
            [muAttStr appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@" %@ ", [FLOUtil integerStr_10000:item.replyCount]] attributes:@{NSFontAttributeName: font}]];
        }
        _replyAttStr = muAttStr;
        
        _playCountStr = [NSString stringWithFormat:@"%@次播放", [FLOUtil integerStr_10000:item.playCount]];
        
        _lengthStr = [FLOUtil timeH_M_SWithSecond:item.length];
    }
    return self;
}

@end
