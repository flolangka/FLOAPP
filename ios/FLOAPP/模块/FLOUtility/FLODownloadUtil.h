//
//  FLODownloadUtil.h
//  FLOAPP
//
//  Created by 360doc on 2017/3/8.
//  Copyright © 2017年 Flolangka. All rights reserved.
//

#import <Foundation/Foundation.h>

/*
 1 : 点击下载 -> 建session, startNewDownload开始下载
 
 2.1 : 点击取消（cancel)
 2.2 : 下载完成 (保存文件)
 2.3 : 下载中app被用户kill重启，建session(程序会自动获取resumeData继续下载)
 2.4 : 下载中断网重连、进入后台，下载任务会继续在后台执行
 */

@interface FLODownloadUtil : NSObject

/**
 建立下载session、应用重启时继续未完成的下载
 
 @param iden 下载任务标识
 @param urlPath 下载路径
 @param savePath 文件夹cache后面的路径
 @param progress 进度
 @param finished 下载完成并保存完成
 @return bgsession
 */
+ (instancetype)dlSessionWithIdentifier:(NSString *)iden URLPath:(NSString *)urlPath savePath:(NSString *)savePath progress:(void(^)(float))progress finished:(void(^)())finished;

/**
 开始新的下载任务
 */
- (void)startNewDownload;

/**
 取消下载，删除下载缓存
 */
- (void)cancel;

@end
