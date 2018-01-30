//
//  FLOQSBKTableViewCell.h
//  FLOAPP
//
//  Created by 360doc on 2018/1/30.
//  Copyright © 2018年 Flolangka. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FLOQSBKTableViewCell : UITableViewCell

//图片、视频点击事件
@property (nonatomic, copy  ) void(^imgAction)(void);

//纯文本
- (void)configUserIcon:(NSString *)icon
              userName:(NSString *)name
            createTime:(NSString *)time
               content:(NSString *)content;

//图片
- (void)configUserIcon:(NSString *)icon
              userName:(NSString *)name
            createTime:(NSString *)time
               content:(NSString *)content
             imagePath:(NSString *)imgPath
             imageSize:(CGSize    )imgSize;

//视频
- (void)configUserIcon:(NSString *)icon
              userName:(NSString *)name
            createTime:(NSString *)time
               content:(NSString *)content
          videoPicture:(NSString *)videoPicture
             videoSize:(CGSize    )videoSize;

@end
