//
//  FLODownloadTableViewController.m
//  FLOAPP
//
//  Created by 360doc on 2017/4/14.
//  Copyright © 2017年 Flolangka. All rights reserved.
//

#import "FLODownloadTableViewController.h"
#import "APLCoreDataStackManager.h"
#import "DownloadFile+CoreDataClass.h"
#import "FLOAddBookMarkMaskView.h"
#import "FLODownloadManager.h"
#import "FLODocumentPreviewViewController.h"
#import "FLOWebViewController.h"

#import <AVKit/AVKit.h>
#import <AVFoundation/AVFoundation.h>
#import <QuickLook/QuickLook.h>

@interface FLODownloadTableViewController () <FLODownloadManagerDelegate>

{
    NSMutableArray *dataArr;
    NSDateFormatter *dataFormatter;
    
    // 正在下载数据显示进度的label
    UILabel *progressLabel;
}

@end

@implementation FLODownloadTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"下载";
    [FLOUtil CreatFilePathInCaches:DownloadFileSavePath];    
    [FLODownloadManager manager].delegate = self;
    
    dataFormatter = [[NSDateFormatter alloc] init];
    [dataFormatter setDateFormat:@"yyyy/MM/dd HH:mm:ss"];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addDownload)];
    
    [self initData];
//    [self checkPasteboard];
    
    self.tableView.tableFooterView = [UIView new];
    
    // 从widget进来的
    if (_URLStr) {
        __block BOOL selected = NO;
        [dataArr enumerateObjectsUsingBlock:^(DownloadFile *obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj.downloadURL isEqualToString:_URLStr]) {
                selected = YES;
                *stop = YES;
            }
        }];
        
        if (!selected) {
            [self addDownloadFileName:@"" url:_URLStr];
        } else {
            Def_MBProgressString(@"该地址已下载");
        }
    }
}

- (void)initData {
    NSFetchRequest *request = [DownloadFile fetchRequest];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"taskID" ascending:NO]];
    NSArray *array = [[APLCoreDataStackManager sharedManager].managedObjectContext executeFetchRequest:request error:nil];
    
    dataArr = [NSMutableArray arrayWithArray:array];
}

// 检测剪切板网址
- (void)checkPasteboard {
    NSString *pasteboardString = [UIPasteboard generalPasteboard].string;
    [[UIPasteboard generalPasteboard] setString:@""];
    
    if (pasteboardString && ([pasteboardString hasPrefix:@"http://"] || [pasteboardString hasPrefix:@"https://"] || [pasteboardString hasPrefix:@"thunder://"])) {
        
        [self addDownloadFileName:@"" url:pasteboardString];
        
        Def_MBProgressString(@"检测到剪切板网址");
    }
}

- (void)addDownload {
    [self addDownloadFileName:@"" url:@""];
}

- (void)addDownloadFileName:(NSString *)name url:(NSString *)url {
    FLOAddBookMarkMaskView *maskView = [[[NSBundle mainBundle] loadNibNamed:@"FLOAddBookMarkMaskView" owner:nil options:nil] objectAtIndex:0];
    maskView.navBar.topItem.title = @"添加下载任务";
    maskView.bookMarkNameTF.text = name;
    maskView.bookMarkURLTF.text = url;
    maskView.submit = ^void(NSString *name, NSString *urlStr){
        // 解析地址
        NSString *url = [FLOUtil parseDownloadPath:urlStr];
        if (url) {
            // 插入数据库
            DownloadFile *obj = [NSEntityDescription insertNewObjectForEntityForName:@"DownloadFile" inManagedObjectContext:[APLCoreDataStackManager sharedManager].managedObjectContext];
            obj.downloadURL = url;
            obj.downloadStatus = 0;
            obj.downloadProgress = 0;
            obj.fileName = name;
            obj.taskID = [NSString stringWithFormat:@"com.flolangka.FloAPP.%.0f", [NSDate timeIntervalSinceReferenceDate]];
            obj.savePath = DownloadFileSavePath;
            obj.downloadDate = [NSDate date];
            [[APLCoreDataStackManager sharedManager].managedObjectContext save:nil];
            
            // 添加到下载队列
            [[FLODownloadManager manager] downloadTask:obj.taskID];
            
            // 刷新页面
            [dataArr insertObject:obj atIndex:0];
            [self.tableView reloadData];
        }        
    };
    
    CGSize size = [UIScreen mainScreen].bounds.size;
    maskView.frame = CGRectMake(size.width, 20, size.width, size.height-20);
    [[UIApplication sharedApplication].keyWindow addSubview:maskView];
    
    [UIView animateWithDuration:0.25 animations:^{
        maskView.frame = CGRectMake(0, 20, size.width, size.height-20);
    }];
}

- (void)openDownloadFile:(DownloadFile *)model {
    NSString *filePath = [FLOUtil FilePathInCachesWithName:model.savePath];
    NSURL *fileURL = [NSURL fileURLWithPath:filePath];
    
    AVAsset *asset = [AVAsset assetWithURL:fileURL];
    if (asset.playable) {
        AVPlayerViewController *playerVC = [[AVPlayerViewController alloc] init];
        playerVC.player = [AVPlayer playerWithURL:fileURL];
        [self presentViewController:playerVC animated:YES completion:nil];
    } else if ([filePath hasSuffix:@".html"]) {
        FLOWebViewController *webViewController = [[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"SBIDWebViewController"];
        webViewController.webViewAddress = filePath;
        [self.navigationController pushViewController:webViewController animated:YES];
    }  else if ([QLPreviewController canPreviewItem:fileURL]) {
        FLODocumentPreviewViewController *preview = [[FLODocumentPreviewViewController alloc] init];
        preview.docName = model.savePath;
        preview.docPath = filePath;
        [self.navigationController pushViewController:preview animated:YES];
    } else {
        Def_MBProgressString(@"不支持的文件格式");
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"reuseIdentifier"];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    DownloadFile *obj = [dataArr objectAtIndex:indexPath.row];
    
    // 复用问题
    if (cell.detailTextLabel == progressLabel && obj.downloadStatus != 1) {
        progressLabel = nil;
    }
    
    NSString *status = @"";
    switch (obj.downloadStatus) {
        case -1:
            status = @"下载失败";
            break;
        case 0:
            status = @"待下载";
            break;
        case 1:
        {
            status = [NSString stringWithFormat:@"下载中：%.1f%%", obj.downloadProgress*100];
            
            progressLabel = cell.detailTextLabel;
        }
            break;
        case 2:
            status = [NSString stringWithFormat:@"暂停下载：%.1f%%", obj.downloadProgress*100];
            break;
        case 3:
        {
            NSDictionary *dic = [FLOUtil FileAttributesInCachesPath:obj.savePath];
            status = [NSString stringWithFormat:@"%@", [FLOUtil FileSizeWithBytes:[dic[@"NSFileSize"] unsignedLongLongValue]]];
        }
            break;
        default:
            break;
    }
    
    cell.textLabel.text = obj.fileName;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ | %@", [dataFormatter stringFromDate:(NSDate *)obj.downloadDate], status];
    
    return cell;
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self deleteDownload:[dataArr objectAtIndex:indexPath.row]];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    DownloadFile *obj = [dataArr objectAtIndex:indexPath.row];
    switch (obj.downloadStatus) {
        case -1: // 下载失败
        {
            [self alertDownloadFailed:dataArr[indexPath.row]];
        }
            break;
        case 0: // 待下载
        {
            [self alertDownload:obj];
        }
            break;
        case 1: // 正在下载
        {
            [[FLODownloadManager manager] suspendCurrentDownloadAndContinue:YES];
        }
            break;
        case 2: // 已暂停
        {
            [self alertDownloadContinue:obj];
        }
            break;
        case 3: // 下载成功
        {
            [self openDownloadFile:obj];
        }
            break;
            
        default:
            break;
    }
}

#pragma mark - 重新下载文档提示框
- (void)alertDownload:(DownloadFile *)model {
    [self alertDownload:model title:@"下载该文档" downloadTitle:@"立即下载"];
}

- (void)alertDownloadContinue:(DownloadFile *)model {
    [self alertDownload:model title:@"继续下载该文档" downloadTitle:@"继续下载"];
}

- (void)alertDownloadFailed:(DownloadFile *)model {
    [self alertDownload:model title:@"重新下载该文档" downloadTitle:@"重新下载"];
}

- (void)alertDownload:(DownloadFile *)model title:(NSString *)title downloadTitle:(NSString *)downloadTitle {
    // 判断网络
    NSInteger network = [FLOUtil networkStatus];
    if (network <= 0) {
        Def_MBProgressString(@"网络异常");
        return;
    }
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:nil preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *downloadAction = [UIAlertAction actionWithTitle:downloadTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self downloadDocument:model];
    }];
    UIAlertAction *deleteAction = [UIAlertAction actionWithTitle:@"删除任务" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        [self deleteDownload:model];
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    
    [alertController addAction:downloadAction];
    [alertController addAction:deleteAction];
    [alertController addAction:cancelAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)downloadDocument:(DownloadFile *)model {
    [[FLODownloadManager manager] downloadTask:model.taskID];
}

- (void)deleteDownload:(DownloadFile *)model {
    [[FLODownloadManager manager] deleteDownload:model.taskID];
    
    // 从列表删除数据
    NSInteger index = [dataArr indexOfObject:model];
    [dataArr removeObject:model];
    [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
}

#pragma mark - 下载代理
- (void)downloadStarted:(NSString *)taskID {
    DownloadFile *model = [self selectModelWithTaskID:taskID];
    if (model) {
        model.downloadStatus = 1;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[dataArr indexOfObject:model] inSection:0];
            [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
            
            progressLabel = nil;
            UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
            if (cell) {
                progressLabel = cell.detailTextLabel;
            }
        });
    }
}

- (void)downloadSuspend:(NSString *)taskID {
    dispatch_async(dispatch_get_main_queue(), ^{
        DownloadFile *model = [self selectModelWithTaskID:taskID];
        if (model) {
            model.downloadStatus = 2;
            [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:[dataArr indexOfObject:model] inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
        }
    });
}

- (void)downloadFinished:(NSString *)taskID fileName:(NSString *)fileName{
    DownloadFile *model = [self selectModelWithTaskID:taskID];
    if (model) {
        dispatch_async(dispatch_get_main_queue(), ^{
            model.downloadStatus = 3;
            if (![model.savePath hasSuffix:fileName]) {
                model.savePath = [model.savePath stringByAppendingPathComponent:fileName];
            }
            [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:[dataArr indexOfObject:model] inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
        });
    }
}

- (void)downloadFailed:(NSString *)taskID {
    dispatch_async(dispatch_get_main_queue(), ^{
        DownloadFile *model = [self selectModelWithTaskID:taskID];
        if (model) {
            model.downloadStatus = -1;
            [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:[dataArr indexOfObject:model] inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
        }
    });
}

- (void)downloadProgress:(float)progress taskID:(NSString *)taskID {
    DownloadFile *model = [self selectModelWithTaskID:taskID];
    if (model) {
        model.downloadProgress = progress;
        
        if (progressLabel) {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSString *status = [NSString stringWithFormat:@"下载中：%.1f%%", model.downloadProgress*100];
                progressLabel.text = [NSString stringWithFormat:@"%@ | %@", [dataFormatter stringFromDate:(NSDate *)model.downloadDate], status];
            });
        }
    }
}

- (DownloadFile *)selectModelWithTaskID:(NSString *)taskID {
    NSArray *arr = [NSArray arrayWithArray:dataArr];
    
    __block DownloadFile *model = nil;
    [arr enumerateObjectsUsingBlock:^(DownloadFile *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.taskID isEqualToString:taskID]) {
            model = obj;
            *stop = YES;
        }
    }];
    
    return model;
}

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
