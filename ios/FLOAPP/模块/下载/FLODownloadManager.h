//
//  FLODownloadManager.h
//  FLOAPP
//
//  Created by 360doc on 2017/4/14.
//  Copyright © 2017年 Flolangka. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol FLODownloadManagerDelegate <NSObject>
@optional
- (void)downloadStarted:(NSString *)taskID;
- (void)downloadSuspend:(NSString *)taskID;
- (void)downloadFinished:(NSString *)taskID;
- (void)downloadFailed:(NSString *)taskID;
- (void)downloadProgress:(float)progress taskID:(NSString *)taskID;

@end

@interface FLODownloadManager : NSObject

@property (nonatomic, weak) id <FLODownloadManagerDelegate>delegate;

+ (instancetype)manager;
- (NSInteger)getCount;

// 重启时处理用户上滑结束进程导致的下载中断
- (void)checkKilledDownloadService;

// 添加下载任务，如果已在队列中，则置顶开始下载，暂停现有任务
- (void)downloadTask:(NSString *)taskID;

// 用户退出时取消所有下载任务
- (void)cancelAllDownloading;

// 删除任务
- (void)deleteDownload:(NSString *)taskID;

// 暂停下载,是否继续后面的下载
- (void)suspendCurrentDownloadAndContinue:(BOOL)isContinue;

@end
