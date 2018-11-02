//
//  FLODownloadManager.m
//  FLOAPP
//
//  Created by 360doc on 2017/4/14.
//  Copyright © 2017年 Flolangka. All rights reserved.
//

#import "FLODownloadManager.h"
#import "DownloadService.h"
#import "DownloadFile+CoreDataClass.h"
#import "APLCoreDataStackManager.h"

@interface FLODownloadManager ()

// 下载队列
@property (nonatomic, strong) NSMutableArray *muArrTaskID;

@property (nonatomic, strong) DownloadService *currentDownload;

// 0:无网络 1:Wifi 2:EDGE
@property (nonatomic, assign) NSInteger lastNetworkStatus;

// 进度
@property (nonatomic, strong) NSMutableDictionary *muDictProgress;
@property (nonatomic, strong) NSDictionary *dictProgressCopy;

@end

@implementation FLODownloadManager

static FLODownloadManager *manager;
+ (instancetype)manager {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[FLODownloadManager alloc] init];
        manager.muArrTaskID = [NSMutableArray arrayWithCapacity:1];
        manager.muDictProgress = [NSMutableDictionary dictionaryWithCapacity:1];
        manager.dictProgressCopy = @{};
        
        manager.lastNetworkStatus = [FLOUtil networkStatus];
                
        // 网络变化
        [[NSNotificationCenter defaultCenter] addObserver:manager selector:@selector(DeviceGetNetworkChangeedNotification:) name:DEVICE_NETWORK_CHANGE_NOTIFICATION object:[UIApplication sharedApplication]];
        
        [manager saveProgress];
    });
    return manager;
}
- (NSInteger)getCount {
    return _muArrTaskID.count;
}
- (void)saveProgress {
    if (_muDictProgress.count > 0) {
        // 最新进度
        NSDictionary *dict = [NSDictionary dictionaryWithDictionary:_muDictProgress];
        for (NSString *taskID in dict.allKeys) {
            NSNumber *newProgress = [dict objectForKey:taskID];
            NSNumber *oldProgress = [_dictProgressCopy objectForKey:taskID];
            
            if (oldProgress == nil || newProgress.floatValue != oldProgress.floatValue) {
                // 需要更新进度
                [self updateProgress:newProgress.floatValue taskID:taskID];
            }
        }
        
        if (_muArrTaskID.count == 0) {
            [_muDictProgress removeAllObjects];
        }
    }
    _dictProgressCopy = [NSDictionary dictionaryWithDictionary:_muDictProgress];
    
    // 3秒执行一次
    dispatch_time_t delayInNanoSeconds = dispatch_time(DISPATCH_TIME_NOW, 3 * NSEC_PER_SEC);
    dispatch_after(delayInNanoSeconds, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^(void){
        [self saveProgress];
    });
}

// 重启时处理用户上滑结束进程导致的下载中断
- (void)checkKilledDownloadService {
    [self addUnfinishedDownload];
    
    DownloadFile *model = [self downloadingFile];
    if (model) {
        [_muArrTaskID insertObject:model.taskID atIndex:0];
        
        _currentDownload = [self dlServiceWithModel:model];
        
        DLog(@"打开APP， 处理用户上滑结束进程导致的下载中断 >> %@", model.taskID);
    }
    
    // 如果队列里有任务的话，肯定是WIFI，直接开始下载
    if (!_currentDownload) {
        [self startNextDownload];
    }
    DLog(@"DocumentDownloadManager 配置完成 所有下载任务: %@", _muArrTaskID);
}

// 添加所有未完成的下载任务
- (void)addUnfinishedDownload {
    if ([FLOUtil networkStatus] == 1) {
        NSArray *arrTaskID = [self unFinishedTaskIDs];
        for (NSString *taskID in arrTaskID) {
            if (![_muArrTaskID containsObject:taskID]) {
                [_muArrTaskID addObject:taskID];
            }
        }
    }
}

// 添加下载任务，如果已在队列中，则置顶开始下载，暂停现有任务
- (void)downloadTask:(NSString *)taskID {
    if ([_muArrTaskID containsObject:taskID]) {
        if ([_muArrTaskID indexOfObject:taskID] != 0) {
            // 暂停现有下载任务
            [self suspendCurrentDownloadAndContinue:NO];
            
            // 置顶开始下载
            [self moveTaskToFirst:taskID];
            [self startNextDownload];
        } else {
            if (!_currentDownload.downloading) {
                [_currentDownload startDownload];
                
                // 更新状态
                [self updateStatus:1 taskID:taskID];
                if (_delegate && [_delegate respondsToSelector:@selector(downloadStarted:)]) {
                    [_delegate downloadStarted:taskID];
                }
            }
        }
    } else {
        [_muArrTaskID addObject:taskID];
        
        if (_muArrTaskID.count == 1) {
            [self startNextDownload];
        }
    }
}

- (void)startNextDownload {
    if (_muArrTaskID.count > 0) {
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            NSString *taskID = [_muArrTaskID firstObject];
            DownloadFile *model = [self downloadFileWithTaskID:taskID];
            if (model && model.downloadStatus != 3) {
                if (model.downloadStatus == 1) {
                    return;
                }
                
                _currentDownload = [self dlServiceWithModel:model];
                
                // 开始、重新、继续下载
                [_currentDownload startDownload];
                
                // 更新状态
                [self updateStatus:1 taskID:taskID];
                if (_delegate && [_delegate respondsToSelector:@selector(downloadStarted:)]) {
                    [_delegate downloadStarted:taskID];
                }
            } else {
                [_muArrTaskID removeObject:taskID];
                [self startNextDownload];
            }
        });
    }
}

- (DownloadService *)dlServiceWithModel:(DownloadFile *)model {
    DownloadService *service = [DownloadService downloadSessionWithIdentifier:model.taskID URLPath:model.downloadURL savePath:model.savePath resumeDataPath:[self resumeDataPath:model.taskID] progress:^(NSString *iden, float progress) {
        
        // 临时存储进度
        [_muDictProgress setObject:[NSNumber numberWithFloat:progress] forKey:iden];
        
        if (_delegate && [_delegate respondsToSelector:@selector(downloadProgress:taskID:)]) {
            [_delegate downloadProgress:progress taskID:iden];
        }
    } suspend:^(NSString *iden) {
        [self updateStatus:2 taskID:iden];
        
        // 下载进度存库
        NSNumber *progress = [_muDictProgress objectForKey:iden];
        if (progress) {
            [self updateProgress:[progress floatValue] taskID:iden];
            [_muDictProgress removeObjectForKey:iden];
        }
        
        if (_delegate && [_delegate respondsToSelector:@selector(downloadSuspend:)]) {
            [_delegate downloadSuspend:iden];
        }
    } finished:^(NSString *iden, NSString *fileName) {
        [self updateStatus:3 taskID:iden];
        
        if (![model.savePath hasSuffix:fileName]) {
            [self updateSavePath:[model.savePath stringByAppendingPathComponent:fileName] taskID:iden];
        }
        
        [_muDictProgress removeObjectForKey:iden];
        
        if (_delegate && [_delegate respondsToSelector:@selector(downloadFinished:fileName:)]) {
            [_delegate downloadFinished:iden fileName:fileName];
        }
        
        [_muArrTaskID removeObject:iden];
        [self startNextDownload];
    } failed:^(NSString *iden) {
        [self updateStatus:-1 taskID:iden];
        [_muDictProgress removeObjectForKey:iden];
        
        if (_delegate && [_delegate respondsToSelector:@selector(downloadFailed:)]) {
            [_delegate downloadFailed:iden];
        }
        
        [_muArrTaskID removeObject:iden];
        [self startNextDownload];
    }];
    
    return service;
}

#pragma mark - 取消、暂停与删除下载
// 用户退出时取消所有下载任务
- (void)cancelAllDownloading {
    [_currentDownload cancel];
    
    [_muArrTaskID removeAllObjects];
}

// 删除任务
- (void)deleteDownload:(NSString *)taskID {
    [_muDictProgress removeObjectForKey:taskID];
    
    [_muArrTaskID removeObject:taskID];
    if (_currentDownload && [[_currentDownload downloadTaskID] isEqualToString:taskID]) {
        [_currentDownload cancel];
        
        [self startNextDownload];
    }
    
    // 删除数据库数据，文件
    DownloadFile *model = [self downloadFileWithTaskID:taskID];
    if (model && ![model.savePath isEqualToString:DownloadFileSavePath]) {
        [FLOUtil DropFilePath:[FLOUtil FilePathInCachesWithName:model.savePath]];
    }
    [self deleteTaskDataTaskID:taskID];
}

// 暂停下载
- (void)suspendCurrentDownloadAndContinue:(BOOL)isContinue {
    NSString *taskID = [_currentDownload downloadTaskID];
    
    // 暂停下载
    [_currentDownload suspendSaveResumeData];
    
    // 下载进度存库
    NSNumber *progress = [_muDictProgress objectForKey:taskID];
    if (progress) {
        [self updateProgress:[progress floatValue] taskID:taskID];
        [_muDictProgress removeObjectForKey:taskID];
    }
    
    // 修改状态
    [self updateStatus:2 taskID:taskID];
    if (_delegate && [_delegate respondsToSelector:@selector(downloadSuspend:)]) {
        [_delegate downloadSuspend:taskID];
    }
    
    // WIFI下自动下载下一篇
    if (isContinue && [FLOUtil networkStatus]==1 && _muArrTaskID.count > 1) {
        NSString *second = [_muArrTaskID objectAtIndex:1];
        [self moveTaskToFirst:second];
        [self startNextDownload];
    }
}

- (NSString *)resumeDataPath:(NSString *)taskID {
    NSString *path = @"/flodownload/resumedata/";
    [FLOUtil CreatFilePathInCaches:path];
    
    return [path stringByAppendingFormat:@"%@.data", taskID];
}

- (void)moveTaskToFirst:(NSString *)taskID {
    NSMutableArray *muArr = [NSMutableArray arrayWithArray:_muArrTaskID];
    [muArr removeObject:taskID];
    [muArr insertObject:taskID atIndex:0];
    
    [_muArrTaskID removeAllObjects];
    [_muArrTaskID addObjectsFromArray:muArr];
}

#pragma mark - 网络变化
- (void)DeviceGetNetworkChangeedNotification:(NSNotification *)info{
    if (info != nil) {
        NSDictionary *dictionary = info.userInfo;
        if (dictionary != nil && [dictionary count]) {
            NSString *DeviceNetworkChange = [dictionary objectForKey:@"NetworkChange"];
            if (Def_CheckStringClassAndLength(DeviceNetworkChange)) {
                if ([DeviceNetworkChange isEqualToString:DEVICE_NETWORK_CHANGE_2_WIFI_NOTIFICATION]) {
                    
                    // 自动开始未完成的下载任务
                    [self addUnfinishedDownload];
                    [self startNextDownload];
                    _lastNetworkStatus = 1;
                    
                } else if ([DeviceNetworkChange isEqualToString:DEVICE_NETWORK_CHANGE_2_VIAWWAN_NOTIFICATION]) {
                    
                    // 暂停下载
                    if (_lastNetworkStatus == 1) {
                        [self suspendAndRemoveQueue];
                    }
                    
                    _lastNetworkStatus = 2;
                } else {
                    [self suspendAndRemoveQueue];
                    
                    _lastNetworkStatus = 0;
                }
            }
        }
    }
}

- (void)suspendAndRemoveQueue {
    if (_currentDownload && _currentDownload.downloading && _muArrTaskID.count > 0) {
        [self suspendCurrentDownloadAndContinue:NO];
    }
    
    [_muArrTaskID removeAllObjects];
}

#pragma mark - Core Data support
- (DownloadFile *)downloadingFile {
    NSFetchRequest *request = [DownloadFile fetchRequest];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"downloadStatus = 1"];
    request.predicate = predicate;
    NSArray *arrResult = [[APLCoreDataStackManager sharedManager].managedObjectContext executeFetchRequest:request error:nil];
    
    if (arrResult && arrResult.count > 0) {
        return arrResult[0];
    } else {
        return nil;
    }
}

- (DownloadFile *)downloadFileWithTaskID:(NSString *)taskID {
    NSFetchRequest *request = [DownloadFile fetchRequest];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"taskID = %@", taskID];
    request.predicate = predicate;
    NSArray *arrResult = [[APLCoreDataStackManager sharedManager].managedObjectContext executeFetchRequest:request error:nil];
    
    if (arrResult && arrResult.count > 0) {
        return arrResult[0];
    } else {
        return nil;
    }
}

- (NSArray *)unFinishedTaskIDs {
    NSFetchRequest *request = [DownloadFile fetchRequest];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"downloadStatus IN {0, 2}"];
    request.predicate = predicate;
    NSArray *arrResult = [[APLCoreDataStackManager sharedManager].managedObjectContext executeFetchRequest:request error:nil];
    
    NSMutableArray *muArr = [NSMutableArray arrayWithCapacity:1];
    for (DownloadFile *model in arrResult) {
        [muArr addObject:model.taskID];
    }
    return muArr;
}

// 更新下载进度
- (void)updateProgress:(float)progress taskID:(NSString *)taskID {
    DownloadFile *model = [self downloadFileWithTaskID:taskID];
    if (model) {
        model.downloadProgress = progress;
        [[APLCoreDataStackManager sharedManager].managedObjectContext save:nil];
    }
}

// 更新下载状态
- (void)updateStatus:(NSInteger)status taskID:(NSString *)taskID {
    DownloadFile *model = [self downloadFileWithTaskID:taskID];
    if (model) {
        model.downloadStatus = status;
        [[APLCoreDataStackManager sharedManager].managedObjectContext save:nil];
    }
}

// 下载完成更新文件路径
- (void)updateSavePath:(NSString *)path taskID:(NSString *)taskID {
    DownloadFile *model = [self downloadFileWithTaskID:taskID];
    if (model) {
        model.savePath = path;
        [[APLCoreDataStackManager sharedManager].managedObjectContext save:nil];
    }
}

- (void)deleteTaskDataTaskID:(NSString *)taskID {
    DownloadFile *model = [self downloadFileWithTaskID:taskID];
    if (model) {
        [[APLCoreDataStackManager sharedManager].managedObjectContext deleteObject:model];
        [[APLCoreDataStackManager sharedManager].managedObjectContext save:nil];
    }
}
@end
