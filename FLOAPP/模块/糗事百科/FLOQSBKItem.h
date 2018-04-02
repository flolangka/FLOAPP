//
//  FLOQSBKItem.h
//  FLOAPP
//
//  Created by 360doc on 2018/1/30.
//  Copyright © 2018年 Flolangka. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FLOQSBKItem : NSObject

@property (nonatomic, copy  ) NSString *userIcon;
@property (nonatomic, copy  ) NSString *userName;
@property (nonatomic, copy  ) NSString *createTime;
@property (nonatomic, copy  ) NSString *content;

@property (nonatomic, assign) float cellHeight;

+ (instancetype)itemWithDictionary:(NSDictionary *)dict;

@end


/**
 纯文本model
 */
@interface FLOQSBKWordItem :FLOQSBKItem

@end


/**
 图片model
 */
@interface FLOQSBKImageItem :FLOQSBKItem

@property (nonatomic, assign) CGSize size;
@property (nonatomic, copy  ) NSString *smallImgPath;
@property (nonatomic, copy  ) NSString *mediumImgPath;

@end


/**
 视频model
 */
@interface FLOQSBKVideoItem :FLOQSBKItem

@property (nonatomic, assign) CGSize size;
@property (nonatomic, copy  ) NSString *imgPath;
@property (nonatomic, copy  ) NSString *videoPath;

@end
