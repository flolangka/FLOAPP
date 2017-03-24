//
//  FLODownloadUtil.m
//  FLOAPP
//
//  Created by 360doc on 2017/3/8.
//  Copyright © 2017年 Flolangka. All rights reserved.
//

#import "FLODownloadUtil.h"

@interface FLODownloadUtil () <NSURLSessionDownloadDelegate>

{
    NSURLSession *dlSession;
    NSString *taskID;
    NSString *urlPath;
    NSString *savePath;
    NSURLSessionDownloadTask *task;
    
    void(^downloadProgress)(float);
    void(^downloadfFinished)();
}

@end

@implementation FLODownloadUtil

/**
 建立下载session
 
 @param iden 可用文件标识
 @param path 文件夹cache后面的路径
 @return bgsession
 */
+ (instancetype)dlSessionWithIdentifier:(NSString *)iden URLPath:(NSString *)urlPath savePath:(NSString *)savePath progress:(void (^)(float))progress finished:(void (^)())finished {
    FLODownloadUtil *obj = [FLODownloadUtil new];
    
    obj -> taskID = iden;
    obj -> urlPath = urlPath;
    obj -> savePath = savePath;
    obj -> downloadProgress = progress;
    obj -> downloadfFinished = finished;
    obj -> dlSession = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:iden] delegate:obj delegateQueue:nil];
    
    return obj;
}

/**
 开始新的下载任务
 */
- (void)startNewDownload {
    task = [dlSession downloadTaskWithURL:[NSURL URLWithString:urlPath]];
    [task resume];
}

/**
 取消下载，删除下载缓存
 */
- (void)cancel {
    if (task) {
        [task cancel];
    }
}

#pragma mark - NSURLSessionDownloadDelegate
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location {
    
    // app重启后location路径可能不对，需要调整
    NSString *filePath = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:savePath];
    NSString *preStr = [filePath substringToIndex:[filePath rangeOfString:@"/Library/Caches/"].location];
    
    NSString *lPath = location.absoluteString;
    lPath = [lPath stringByReplacingCharactersInRange:NSMakeRange(0, [lPath rangeOfString:@"/Library/Caches/"].location) withString:preStr];
    NSLog(@"下载完成: %@", lPath);
    
    // 文件转换
    NSError *error = nil;
    BOOL moveSuccess = [[NSFileManager defaultManager] moveItemAtPath:lPath toPath:filePath error:&error];
    if (moveSuccess && downloadfFinished) {
        downloadfFinished();
    }
    NSLog(@"文件转换%@ error:%@", moveSuccess?@"成功":@"失败", error.localizedDescription);
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
    
    if (task == nil) {
        task = downloadTask;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (downloadProgress) {
            downloadProgress(totalBytesWritten/(double)totalBytesExpectedToWrite);
        }
    });
}

/* 断点续传关键代理方法
 cancelByProducingResumeData 时
 用户上滑kill app，重启后创建session 时
 */
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    if (error && error.userInfo) {
        NSData *resumeData = [error.userInfo objectForKey:@"NSURLSessionDownloadTaskResumeData"];
        if (resumeData) {
            self -> task = [session downloadTaskWithResumeData:resumeData];
            [self -> task resume];
        }
    }
}

@end
