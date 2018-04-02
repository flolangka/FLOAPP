//
//  FLOMusicModel.h
//  FLOAPP
//
//  Created by 360doc on 2017/11/15.
//  Copyright © 2017年 Flolangka. All rights reserved.
//

#import <Foundation/Foundation.h>

// 搜索结果每页数量
extern NSInteger const MusicSearchPageNum;

@interface FLOMusicModel : NSObject

@property (nonatomic, assign) NSInteger songID;     // 歌曲ID
@property (nonatomic, copy) NSString *name;         // 歌名
@property (nonatomic, copy) NSString *albumName;    // 专辑名称
@property (nonatomic, copy) NSString *singer;       // 歌手
@property (nonatomic, assign) NSInteger time;       // 时长
@property (nonatomic, copy) NSString *logo;         // 专辑封面

/**
 虾米音乐搜索
 
 @param text 关键词
 @param page 页码
 @param completion 搜索结果
 */
+ (void)XMMusicSearch:(NSString *)text page:(NSInteger)page completion:(void(^)(NSArray <FLOMusicModel *>*))completion;

@end
