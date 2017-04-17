//
//  DownloadService.m
//  UITest
//
//  Created by 360doc on 2017/3/3.
//  Copyright © 2017年 Flolangka. All rights reserved.
//

#import "DownloadService.h"

@interface NSURLSession (DQCorrectedResumeData)
- (NSURLSessionDownloadTask *)correctedDownloadTaskWithResumeData:(NSData *)resumeData;
@end

@interface DownloadService () <NSURLSessionDownloadDelegate>

{
    NSURLSession *dlSession;
    NSString *taskID;
    NSString *urlPath;
    NSString *savePath;
    NSURLSessionDownloadTask *task;
    
    BOOL downloading;
    
    void(^downloadProgress)(NSString *, float);
    void(^downloadSuspend)(NSString *);
    void(^downloadFinished)(NSString *, NSString *);
    void(^downloadFailed)(NSString *);
    
    NSString *resumeDataPath;
}

@end

@implementation DownloadService

/**
 建立下载session、应用重启时继续未完成的下载
 
 @param iden 下载任务标识
 @param urlPath 下载路径
 @param savePath 文件夹Library/Caches后面的路径
 @param progress 进度
 @param suspend 用户上滑杀进程，重启时非WIFI下暂停下载的事件
 @param finished 下载完成并保存完成
 @param failed 失败事件
 @return dlService
 */
+ (instancetype)downloadSessionWithIdentifier:(NSString *)iden URLPath:(NSString *)urlPath savePath:(NSString *)savePath resumeDataPath:(NSString *)resumeDataPath progress:(void (^)(NSString *, float))progress suspend:(void (^)(NSString *))suspend finished:(void (^)(NSString *, NSString *))finished failed:(void (^)(NSString *))failed {
    DownloadService *dlService = [DownloadService new];
    
    dlService -> taskID = iden;
    dlService -> urlPath = urlPath;
    dlService -> savePath = savePath;
    dlService -> resumeDataPath = resumeDataPath;
    dlService -> downloadProgress = progress;
    dlService -> downloadSuspend = suspend;
    dlService -> downloadFinished = finished;
    dlService -> downloadFailed = failed;
    dlService -> downloading = NO;
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:iden];
    dlService -> dlSession = [NSURLSession sessionWithConfiguration:configuration delegate:dlService delegateQueue:nil];
    
    return dlService;
}

/**
 是否正在下载
 */
- (BOOL)downloading {
    return downloading;
}

/**
 开始下载任务
 */
- (void)startDownload {    
    if (task) {
        [task resume];
    } else {
        task = [dlSession downloadTaskWithURL:[NSURL URLWithString:urlPath]];
        [task resume];
    }
    downloading = YES;
}

/**
 通过resumeData继续下载
 */
- (void)startWithResumeData {
    NSData *data = [NSData dataWithContentsOfFile:[FLOUtil FilePathInCachesWithName:resumeDataPath]];
    if (data && data.length) {
        NSString *strVersion = [UIDevice currentDevice].systemVersion;
        NSArray *arr = [strVersion componentsSeparatedByString:@"."];
        NSString *first = [arr objectAtIndex:0];
        NSString *second = [arr objectAtIndex:1];
        
        // 10.0~10.1 续传有系统BUG
        if ([first isEqualToString:@"10"] && ([second isEqualToString:@"0"] || [second isEqualToString:@"1"])) {
            task = [dlSession correctedDownloadTaskWithResumeData:data];
        } else {
            task = [dlSession downloadTaskWithResumeData:data];
        }
        [task resume];
        
        downloading = YES;
    } else {
        [self startDownload];
    }
}

/**
 暂停下载并保存已下载数据信息
 */
- (void)suspendSaveResumeData {
    if (downloading) {
        [task cancelByProducingResumeData:^(NSData * _Nullable resumeData) {
            if (resumeData) {
                BOOL saveSuccess = [resumeData writeToFile:[FLOUtil FilePathInCachesWithName:resumeDataPath] atomically:YES];
                DLog(@"暂停下载>%@<，已获取resumeData保存%@", taskID, saveSuccess?@"成功":@"失败");
            }
        }];
    }
    downloading = NO;
}

/**
 取消下载，删除下载缓存
 */
- (void)cancel {
    [dlSession invalidateAndCancel];
    downloading = NO;
}

- (NSString *)downloadTaskID {
    return taskID;
}

#pragma mark - NSURLSessionDownloadDelegate
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location {
    downloading = NO;
    
    NSString *fileName = downloadTask.response.suggestedFilename;
    NSString *path = savePath;
    if (![savePath hasSuffix:fileName]) {
        path = [savePath stringByAppendingPathComponent:fileName];
    }
    NSString *filePath = [FLOUtil FilePathInCachesWithName:path];
    [FLOUtil DropFilePath:filePath];
    
    // app重启后location路径可能不对，需要调整
    NSString *preStr = [filePath substringToIndex:[filePath rangeOfString:@"/Library/Caches/"].location];
    
    NSString *lPath = location.absoluteString;
    lPath = [lPath stringByReplacingCharactersInRange:NSMakeRange(0, [lPath rangeOfString:@"/Library/Caches/"].location) withString:preStr];
    DLog(@"下载完成: %@\n保存路径: %@", lPath, filePath);
    
    // 文件转换
    NSError *error = nil;
    BOOL moveSuccess = [[NSFileManager defaultManager] moveItemAtPath:lPath toPath:filePath error:&error];
    if (moveSuccess && downloadFinished) {
        downloadFinished(taskID, fileName);
    }
    DLog(@"文件转换%@ error:%@", moveSuccess?@"成功":@"失败", error.localizedDescription);
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
    downloading = YES;
    
    if (task == nil) {
        task = downloadTask;
    }
    
    if (downloadProgress) {
        downloadProgress(taskID, totalBytesWritten/(double)totalBytesExpectedToWrite);
    }
}

/* 断点续传关键代理方法
 cancelByProducingResumeData 时
 用户上滑kill app，重启后创建session 时
 */
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    if (error && error.userInfo) {
        DLog(@"文档下载didCompleteWithError：%@\nTaskID：%@", error.userInfo, taskID);
        downloading = NO;
        
        NSData *resumeData = [error.userInfo objectForKey:@"NSURLSessionDownloadTaskResumeData"];
        if (resumeData) {
            
            // 用户主动暂停
            NSString *localizedDescription = [error.userInfo objectForKey:@"NSLocalizedDescription"];
            if (localizedDescription && [localizedDescription isEqualToString:@"cancelled"]) {
                return;
            }
            
            if ([FLOUtil networkStatus] == 1) {
                self -> task = [session downloadTaskWithResumeData:resumeData];
                [self -> task resume];
                downloading = YES;
            } else {
                BOOL saveSuccess = [resumeData writeToFile:[FLOUtil FilePathInCachesWithName:resumeDataPath] atomically:YES];
                
                if (saveSuccess && downloadSuspend) {
                    downloadSuspend(taskID);
                }
            }
        } else {
            if (downloadFailed) {
                downloadFailed(taskID);
            }
        }
    }
}

- (void)URLSession:(NSURLSession *)session didBecomeInvalidWithError:(NSError *)error {
    DLog(@"文档下载didBecomeInvalidWithError：%@\nTaskID：%@", error.userInfo, taskID);
}

@end


@implementation NSURLSession (DQCorrectedResumeData)
NSData * correctRequestData(NSData *data) {
    if (!data) {
        return nil;
    }
    // return the same data if it's correct
    if ([NSKeyedUnarchiver unarchiveObjectWithData:data] != nil) {
        return data;
    }
    NSMutableDictionary *archive = [[NSPropertyListSerialization propertyListWithData:data options:NSPropertyListMutableContainersAndLeaves format:nil error:nil] mutableCopy];
    
    if (!archive) {
        return nil;
    }
    NSInteger k = 0;
    id objectss = archive[@"$objects"];
    while ([objectss[1] objectForKey:[NSString stringWithFormat:@"$%ld",k]] != nil) {
        k += 1;
    }
    NSInteger i = 0;
    while ([archive[@"$objects"][1] objectForKey:[NSString stringWithFormat:@"__nsurlrequest_proto_prop_obj_%ld",i]] != nil) {
        NSMutableArray *arr = archive[@"$objects"];
        NSMutableDictionary *dic = arr[1];
        id obj = [dic objectForKey:[NSString stringWithFormat:@"__nsurlrequest_proto_prop_obj_%ld",i]];
        if (obj) {
            [dic setValue:obj forKey:[NSString stringWithFormat:@"$%ld",i+k]];
            [dic removeObjectForKey:[NSString stringWithFormat:@"__nsurlrequest_proto_prop_obj_%ld",i]];
            [arr replaceObjectAtIndex:1 withObject:dic];
            archive[@"$objects"] = arr;
        }
        i++;
    }
    if ([archive[@"$objects"][1] objectForKey:@"__nsurlrequest_proto_props"] != nil) {
        NSMutableArray *arr = archive[@"$objects"];
        NSMutableDictionary *dic = arr[1];
        id obj = [dic objectForKey:@"__nsurlrequest_proto_props"];
        if (obj) {
            [dic setValue:obj forKey:[NSString stringWithFormat:@"$%ld",i+k]];
            [dic removeObjectForKey:@"__nsurlrequest_proto_props"];
            [arr replaceObjectAtIndex:1 withObject:dic];
            archive[@"$objects"] = arr;
        }
    }
    // Rectify weird "NSKeyedArchiveRootObjectKey" top key to NSKeyedArchiveRootObjectKey = "root"
    if ([archive[@"$top"] objectForKey:@"NSKeyedArchiveRootObjectKey"] != nil) {
        [archive[@"$top"] setObject:archive[@"$top"][@"NSKeyedArchiveRootObjectKey"] forKey: NSKeyedArchiveRootObjectKey];
        [archive[@"$top"] removeObjectForKey:@"NSKeyedArchiveRootObjectKey"];
    }
    // Reencode archived object
    NSData *result = [NSPropertyListSerialization dataWithPropertyList:archive format:NSPropertyListBinaryFormat_v1_0 options:0 error:nil];
    return result;
}

NSMutableDictionary *getResumeDictionary(NSData *data) {
    NSMutableDictionary *iresumeDictionary = nil;
    if ([[UIDevice currentDevice] systemVersion].floatValue >= 10.0) {
        id root = nil;
        id  keyedUnarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
        @try {
            root = [keyedUnarchiver decodeTopLevelObjectForKey:@"NSKeyedArchiveRootObjectKey" error:nil];
            if (root == nil) {
                root = [keyedUnarchiver decodeTopLevelObjectForKey:NSKeyedArchiveRootObjectKey error:nil];
            }
        } @catch(NSException *exception) {
            
        }
        [keyedUnarchiver finishDecoding];
        iresumeDictionary = [root mutableCopy];
    }
    
    if (iresumeDictionary == nil) {
        iresumeDictionary = [NSPropertyListSerialization propertyListWithData:data options:NSPropertyListMutableContainersAndLeaves format:nil error:nil];
    }
    return iresumeDictionary;
}

NSData *correctResumeData(NSData *data) {
    NSString *kResumeCurrentRequest = @"NSURLSessionResumeCurrentRequest";
    NSString *kResumeOriginalRequest = @"NSURLSessionResumeOriginalRequest";
    if (data == nil) {
        return  nil;
    }
    NSMutableDictionary *resumeDictionary = getResumeDictionary(data);
    if (resumeDictionary == nil) {
        return nil;
    }
    resumeDictionary[kResumeCurrentRequest] = correctRequestData(resumeDictionary[kResumeCurrentRequest]);
    resumeDictionary[kResumeOriginalRequest] = correctRequestData(resumeDictionary[kResumeOriginalRequest]);
    NSData *result = [NSPropertyListSerialization dataWithPropertyList:resumeDictionary format:NSPropertyListXMLFormat_v1_0 options:0 error:nil];
    return result;
}

- (NSURLSessionDownloadTask *)correctedDownloadTaskWithResumeData:(NSData *)resumeData {
    NSString *kResumeCurrentRequest = @"NSURLSessionResumeCurrentRequest";
    NSString *kResumeOriginalRequest = @"NSURLSessionResumeOriginalRequest";
    
    NSData *cData = correctResumeData(resumeData);
    cData = cData?cData:resumeData;
    NSURLSessionDownloadTask *task = [self downloadTaskWithResumeData:cData];
    NSMutableDictionary *resumeDic = getResumeDictionary(cData);
    if (resumeDic) {
        if (task.originalRequest == nil) {
            NSData *originalReqData = resumeDic[kResumeOriginalRequest];
            NSURLRequest *originalRequest = [NSKeyedUnarchiver unarchiveObjectWithData:originalReqData ];
            if (originalRequest) {
                [task setValue:originalRequest forKey:@"originalRequest"];
            }
        }
        if (task.currentRequest == nil) {
            NSData *currentReqData = resumeDic[kResumeCurrentRequest];
            NSURLRequest *currentRequest = [NSKeyedUnarchiver unarchiveObjectWithData:currentReqData];
            if (currentRequest) {
                [task setValue:currentRequest forKey:@"currentRequest"];
            }
        }
        
    }
    return task;
}
@end
