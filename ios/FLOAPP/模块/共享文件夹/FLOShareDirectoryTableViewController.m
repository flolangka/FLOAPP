//
//  FLOShareDirectoryTableViewController.m
//  FLOAPP
//
//  Created by 360doc on 2017/7/19.
//  Copyright © 2017年 Flolangka. All rights reserved.
//

#import "FLOShareDirectoryTableViewController.h"

#import "FLODocumentPreviewViewController.h"
#import "FLOWebViewController.h"
#import "FLOFileBrowserTableViewController.h"
#import "FLOTextViewViewController.h"

#import <AVKit/AVKit.h>
#import <AVFoundation/AVFoundation.h>
#import <QuickLook/QuickLook.h>

@interface FLOShareDirectoryTableViewController ()

{
    dispatch_queue_t _zDispatchQueue;
    dispatch_source_t _zSource;
}

@property (nonatomic, copy) NSString *path;
@property (nonatomic, copy) NSArray *childPaths;
@property (nonatomic, strong) NSNumber *recursiveSize;

@end

@implementation FLOShareDirectoryTableViewController

- (instancetype)init {
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        self.title = @"Document";
        
        // 获取沙盒的Document目录
        self.path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self reloadChildPaths];
    
    // 监听Document目录的文件改动
    [self startMonitoringDocumentAsynchronous];
}

// 开始监听Document目录文件改动, 一旦发生修改则发出一个名为ZFileChangedNotification的通知
- (void)startMonitoringDocumentAsynchronous {
    [self startMonitoringDirectory:_path];
}

// 监听指定目录的文件改动
- (void)startMonitoringDirectory:(NSString *)directoryPath {
    // 创建 file descriptor (需要将NSString转换成C语言的字符串)
    // open() 函数会建立 file 与 file descriptor 之间的连接
    int filedes = open([directoryPath cStringUsingEncoding:NSASCIIStringEncoding], O_EVTONLY);
    
    // 创建 dispatch queue, 当文件改变事件发生时会发送到该 queue
    _zDispatchQueue = dispatch_queue_create("ZFileMonitorQueue", 0);
    
    // 创建 GCD source. 将用于监听 file descriptor 来判断是否有文件写入操作
    _zSource = dispatch_source_create(DISPATCH_SOURCE_TYPE_VNODE, filedes, DISPATCH_VNODE_WRITE, _zDispatchQueue);
    
    // 当文件发生改变时会调用该 block
    dispatch_source_set_event_handler(_zSource, ^{
        // 文件发生改变
        [self fileChanage];
    });
    
    // 当文件监听停止时会调用该 block
    dispatch_source_set_cancel_handler(_zSource, ^{
        // 关闭文件监听时, 关闭该 file descriptor
        close(filedes);
    });
    
    // 开始监听文件
    dispatch_resume(_zSource);
}

- (void)dealloc {
    // 取消监听Document目录的文件改动
    dispatch_cancel(_zSource);
}

// 消息是在子线程中发出的, 因此方法会在子线程中执行
- (void)fileChanage {
    DLog(@"文件夹内容发生了改变");
    
    FLOAsyncMainQueueBlock(^{
        [self reloadChildPaths];
        [self.tableView reloadData];
    });
}

// 获取文件夹下所有文件
- (void)reloadChildPaths {
    FLOWeakObj(self);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSDictionary *attributes = [fileManager attributesOfItemAtPath:weakself.path error:NULL];
        uint64_t totalSize = [attributes fileSize];
        
        for (NSString *fileName in [fileManager enumeratorAtPath:weakself.path]) {
            attributes = [fileManager attributesOfItemAtPath:[weakself.path stringByAppendingPathComponent:fileName] error:NULL];
            totalSize += [attributes fileSize];
            
            // Bail if the interested view controller has gone away.
            if (!weakself) {
                return;
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            FLOShareDirectoryTableViewController *__strong strongSelf = weakself;
            strongSelf.recursiveSize = @(totalSize);
            [strongSelf.tableView reloadData];
        });
    });
    
    NSMutableArray *childPaths = [NSMutableArray array];
    NSArray *subpaths = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:self.path error:NULL];
    for (NSString *subpath in subpaths) {
        [childPaths addObject:[self.path stringByAppendingPathComponent:subpath]];
    }
    self.childPaths = childPaths;
}

// 打开文件
- (void)openFilePath:(NSString *)fullPath {
    NSString *subpath = [fullPath lastPathComponent];
    NSString *pathExtension = [subpath pathExtension];
    
    BOOL isDirectory = NO;
    BOOL stillExists = [[NSFileManager defaultManager] fileExistsAtPath:fullPath isDirectory:&isDirectory];
    
    if (stillExists) {
        if (isDirectory) {
            UIViewController *drillInViewController = [[FLOFileBrowserTableViewController alloc] initWithPath:fullPath];
            drillInViewController.title = [subpath lastPathComponent];
            [self.navigationController pushViewController:drillInViewController animated:YES];
            
        } else {
            NSURL *fileURL = [NSURL fileURLWithPath:fullPath];
            
            AVAsset *asset = [AVAsset assetWithURL:fileURL];
            if (asset.playable) {
                // 音视频
                AVPlayerViewController *playerVC = [[AVPlayerViewController alloc] init];
                playerVC.player = [AVPlayer playerWithURL:fileURL];
                [self presentViewController:playerVC animated:YES completion:nil];
                
            } else if ([pathExtension isEqualToString:@"html"]) {
                // 网页
                FLOWebViewController *webViewController = [[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"SBIDWebViewController"];
                webViewController.webViewAddress = fullPath;
                [self.navigationController pushViewController:webViewController animated:YES];
                
            } else if ([pathExtension isEqualToString:@"plist"]) {
                //plist
                NSData *fileData = [NSData dataWithContentsOfFile:fullPath];
                NSString *prettyString = [[NSPropertyListSerialization propertyListWithData:fileData options:0 format:NULL error:NULL] description];
                
                FLOTextViewViewController *tvVC = [[FLOTextViewViewController alloc] init];
                tvVC.contentText = prettyString;
                [self.navigationController pushViewController:tvVC animated:YES];
                
            } else if ([QLPreviewController canPreviewItem:fileURL]) {
                // 文档
                FLODocumentPreviewViewController *preview = [[FLODocumentPreviewViewController alloc] init];
                preview.docName = subpath;
                preview.docPath = fullPath;
                [self.navigationController pushViewController:preview animated:YES];
                
            } else {
                /*
                NSArray <NSString *> *fileArray = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:filePath error:nil];
                
                if (Def_CheckArrayClassAndCount(fileArray) && [fileArray containsObject:@"index.html"]) {
                    // 整个站点资源
                    FLOWebViewController *webViewController = [[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"SBIDWebViewController"];
                    webViewController.webViewAddress = [filePath stringByAppendingPathComponent:@"index.html"];
                    [self.navigationController pushViewController:webViewController animated:YES];
                    
                } else {
                    Def_MBProgressString(@"不支持的文件格式");
                }
                 */
                
                //分享
                UIActivityViewController *vc = [[UIActivityViewController alloc] initWithActivityItems:@[fileURL] applicationActivities:nil];
                [self presentViewController:vc animated:YES completion:nil];
            }
        }
    }
    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _childPaths.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSNumber *currentSize = self.recursiveSize;
    
    NSString *sizeString = nil;
    if (!currentSize) {
        sizeString = @"Computing size…";
    } else {
        sizeString = [NSByteCountFormatter stringFromByteCount:[currentSize longLongValue] countStyle:NSByteCountFormatterCountStyleFile];
    }
    
    return [NSString stringWithFormat:@"%lu files (%@)", (unsigned long)[self.childPaths count], sizeString];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *fullPath = self.childPaths[indexPath.row];
    NSDictionary *attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:fullPath error:NULL];
    BOOL isDirectory = [[attributes fileType] isEqual:NSFileTypeDirectory];
    NSString *subtitle = nil;
    if (isDirectory) {
        NSUInteger count = [[[NSFileManager defaultManager] contentsOfDirectoryAtPath:fullPath error:NULL] count];
        subtitle = [NSString stringWithFormat:@"%lu file%@", (unsigned long)count, (count == 1 ? @"" : @"s")];
    } else {
        NSString *sizeString = [NSByteCountFormatter stringFromByteCount:[attributes fileSize] countStyle:NSByteCountFormatterCountStyleFile];
        subtitle = [NSString stringWithFormat:@"%@ - %@", sizeString, [attributes fileModificationDate]];
    }
    
    static NSString *FLOShareDirectoryTableViewCellID = @"FLOShareDirectoryTableViewCellID";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:FLOShareDirectoryTableViewCellID];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:FLOShareDirectoryTableViewCellID];
        cell.detailTextLabel.textColor = [UIColor grayColor];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    NSString *cellTitle = [fullPath lastPathComponent];
    cell.textLabel.text = cellTitle;
    cell.detailTextLabel.text = subtitle;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    [self openFilePath:_childPaths[indexPath.row]];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSString *fullPath = self.childPaths[indexPath.row];
        NSError *error;
        [[NSFileManager defaultManager] removeItemAtPath:fullPath error:&error];
        if (error) {
            DLog(@"删除文件报错 >> %@", [error localizedDescription]);
        }
        
        [self reloadChildPaths];
        [self.tableView reloadData];
    }
}

@end
