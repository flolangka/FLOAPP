//
//  FLONETEASEVideoItem.h
//  FLOAPP
//
//  Created by 360doc on 2018/4/12.
//  Copyright © 2018年 Flolangka. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FLONETEASEVideoItem : NSObject

@property (nonatomic, copy  ) NSString *coverImagePath;
@property (nonatomic, copy  ) NSString *url_m3u8;
@property (nonatomic, copy  ) NSString *url_mp4;
@property (nonatomic, assign) NSInteger length;
@property (nonatomic, assign) NSInteger playCount;
@property (nonatomic, assign) NSInteger replyCount;
@property (nonatomic, assign) NSInteger voteCount;

@property (nonatomic, copy  ) NSString *title;
@property (nonatomic, copy  ) NSString *userName;
@property (nonatomic, copy  ) NSString *userIcon;

- (instancetype)initWithInfo:(NSDictionary *)info;

@end
