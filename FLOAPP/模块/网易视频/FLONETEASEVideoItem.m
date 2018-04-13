//
//  FLONETEASEVideoItem.m
//  FLOAPP
//
//  Created by 360doc on 2018/4/12.
//  Copyright © 2018年 Flolangka. All rights reserved.
//

#import "FLONETEASEVideoItem.h"

@implementation FLONETEASEVideoItem

- (instancetype)initWithInfo:(NSDictionary *)info {
    if (!Def_CheckDictionaryClassAndCount(info)) {
        return nil;
    }
    
    self = [super init];
    if (self) {
        _coverImagePath = info[@"cover"];
        _url_m3u8 = info[@"m3u8_url"];
        _url_mp4 = info[@"mp4_url"];
        _length = [info[@"length"] integerValue];
        _playCount = [info[@"playCount"] integerValue];
        _replyCount = [info[@"replyCount"] integerValue];
        _voteCount = [info[@"voteCount"] integerValue];
        _title = info[@"title"];
        _userName = info[@"topicName"];
        
        NSDictionary *videoTopic = info[@"videoTopic"];
        NSString *topic_icons = [videoTopic objectForKey:@"topic_icons"] ? : @"";
        _userIcon = Def_CheckStringClassAndLength(topic_icons) ? topic_icons : info[@"topicImg"];
    }
    return self;
}

@end
