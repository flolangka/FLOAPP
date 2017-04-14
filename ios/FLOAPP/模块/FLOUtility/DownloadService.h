//
//  DownloadService.h
//  UITest
//
//  Created by 360doc on 2017/3/3.
//  Copyright © 2017年 Flolangka. All rights reserved.
//

#import <Foundation/Foundation.h>

/*
 1 : 点击下载 -> 建session, startDownload开始下载
 
 2.1 : 点击取消（cancel)
 2.2 : 下载完成 (保存文件)
 2.3 : 下载中app被kill重启，建session(程序会自动获取resumeData继续下载)
 2.4 : 下载中断网重连、进入后台，下载任务会继续在后台执行
 */

@interface DownloadService : NSObject



/**
 建立下载session、应用重启时继续未完成的下载
 
 @param iden 下载任务标识
 @param urlPath 下载路径
 @param savePath 文件夹Library/Caches后面的路径
 @param resumeDataPath resumeData保存路径
 @param progress 进度
 @param suspend 用户上滑杀进程，重启时非WIFI下暂停下载的事件
 @param finished 下载完成并保存完成
 @param failed 失败事件
 @return dlService
 */
+ (instancetype)downloadSessionWithIdentifier:(NSString *)iden
                                      URLPath:(NSString *)urlPath
                                     savePath:(NSString *)savePath
                               resumeDataPath:(NSString *)resumeDataPath
                                     progress:(void(^)(NSString *iden, float progress))progress
                                      suspend:(void(^)(NSString *iden))suspend
                                     finished:(void(^)(NSString *iden))finished
                                       failed:(void(^)(NSString *iden))failed;

/**
 是否正在下载
 */
- (BOOL)downloading;

/**
 开始下载任务
 */
- (void)startDownload;

/**
 通过resumeData继续下载
 */
- (void)startWithResumeData;

/**
 暂停下载并保存已下载数据信息
 */
- (void)suspendSaveResumeData;

/**
 取消下载，删除下载缓存
 */
- (void)cancel;

/**
 下载任务标识
 */
- (NSString *)downloadTaskID;

@end
