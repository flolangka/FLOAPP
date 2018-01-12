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

#import <AVKit/AVKit.h>
#import <AVFoundation/AVFoundation.h>
#import <QuickLook/QuickLook.h>

@interface FLOShareDirectoryTableViewController ()

{
    dispatch_queue_t _zDispatchQueue;
    dispatch_source_t _zSource;
    
    NSArray *dataArr;
}

@end

@implementation FLOShareDirectoryTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"共享文件夹";
    
    dataArr = [NSArray arrayWithArray:[self filesInDocument]];
    
    // 监听Document目录的文件改动
    [self startMonitoringDocumentAsynchronous];
}

// 开始监听Document目录文件改动, 一旦发生修改则发出一个名为ZFileChangedNotification的通知
- (void)startMonitoringDocumentAsynchronous {
    // 获取沙盒的Document目录
    NSString *docuPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    
    [self startMonitoringDirectory:docuPath];
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
    
    NSArray <NSString *> *fileArray = [self filesInDocument];
    FLOAsyncMainQueueBlock(^{
        dataArr = [NSArray arrayWithArray:fileArray];
        [self.tableView reloadData];
    });
}

// 获取文件夹下所有文件
- (NSArray <NSString *>*)filesInDocument {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSString *filePath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    
    NSError *error;
    // 获取指定路径对应文件夹下的所有文件
    NSArray <NSString *> *fileArray = [fileManager contentsOfDirectoryAtPath:filePath error:&error];
    
    return (fileArray ? : @[]);
}

// 打开文件
- (void)openFile:(NSString *)fileName {
    NSString *filePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:fileName];
    NSURL *fileURL = [NSURL fileURLWithPath:filePath];
    
    AVAsset *asset = [AVAsset assetWithURL:fileURL];
    if (asset.playable) {
        // 音视频
        AVPlayerViewController *playerVC = [[AVPlayerViewController alloc] init];
        playerVC.player = [AVPlayer playerWithURL:fileURL];
        [self presentViewController:playerVC animated:YES completion:nil];
        
    } else if ([filePath hasSuffix:@".html"]) {
        // 网页
        FLOWebViewController *webViewController = [[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"SBIDWebViewController"];
        webViewController.webViewAddress = filePath;
        [self.navigationController pushViewController:webViewController animated:YES];
        
    }  else if ([QLPreviewController canPreviewItem:fileURL]) {
        // 文档
        FLODocumentPreviewViewController *preview = [[FLODocumentPreviewViewController alloc] init];
        preview.docName = fileName;
        preview.docPath = filePath;
        [self.navigationController pushViewController:preview animated:YES];
        
    } else {
        NSArray <NSString *> *fileArray = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:filePath error:nil];
        
        if (Def_CheckArrayClassAndCount(fileArray) && [fileArray containsObject:@"index.html"]) {            
            // 整个站点资源
            FLOWebViewController *webViewController = [[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"SBIDWebViewController"];
            webViewController.webViewAddress = [filePath stringByAppendingPathComponent:@"index.html"];
            [self.navigationController pushViewController:webViewController animated:YES];
            
        } else {
            Def_MBProgressString(@"不支持的文件格式");
        }
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return dataArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"reuseIdentifier"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"reuseIdentifier"];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    cell.textLabel.text = dataArr[indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    [self openFile:dataArr[indexPath.row]];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSString *fileName = dataArr[indexPath.row];
        NSString *filePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:fileName];
        NSError *error;
        [[NSFileManager defaultManager] removeItemAtPath:filePath error:&error];
        if (error) {
            DLog(@"删除文件报错 >> %@", [error localizedDescription]);
        }
        
        NSMutableArray *muArr = [NSMutableArray arrayWithArray:dataArr];
        [muArr removeObject:fileName];
    }
}

@end
