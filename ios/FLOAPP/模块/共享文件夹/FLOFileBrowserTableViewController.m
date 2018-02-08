//
//  FLOFileBrowserTableViewController.m
//  FLOAPP
//
//  Created by 360doc on 2018/2/8.
//  Copyright © 2018年 Flolangka. All rights reserved.
//

#import "FLOFileBrowserTableViewController.h"
#import "FLODocumentPreviewViewController.h"
#import "FLOWebViewController.h"
#import "FLOTextViewViewController.h"

#import <AVKit/AVKit.h>
#import <AVFoundation/AVFoundation.h>
#import <QuickLook/QuickLook.h>

@interface FLOFileBrowserTableViewController ()

@property (nonatomic, copy) NSString *path;
@property (nonatomic, copy) NSArray *childPaths;
@property (nonatomic, strong) NSNumber *recursiveSize;

@end

@implementation FLOFileBrowserTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    return [self initWithPath:NSHomeDirectory()];
}

- (id)initWithPath:(NSString *)path
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        self.path = path;
        self.title = [path lastPathComponent];
        
        //computing path size
        FLOFileBrowserTableViewController *__weak weakSelf = self;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSFileManager *fileManager = [NSFileManager defaultManager];
            NSDictionary *attributes = [fileManager attributesOfItemAtPath:path error:NULL];
            uint64_t totalSize = [attributes fileSize];
            
            for (NSString *fileName in [fileManager enumeratorAtPath:path]) {
                attributes = [fileManager attributesOfItemAtPath:[path stringByAppendingPathComponent:fileName] error:NULL];
                totalSize += [attributes fileSize];
                
                // Bail if the interested view controller has gone away.
                if (!weakSelf) {
                    return;
                }
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                FLOFileBrowserTableViewController *__strong strongSelf = weakSelf;
                strongSelf.recursiveSize = @(totalSize);
                [strongSelf.tableView reloadData];
            });
        });
        
        [self reloadChildPaths];
    }
    return self;
}

- (void)reloadChildPaths {
    NSMutableArray *childPaths = [NSMutableArray array];
    NSArray *subpaths = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:self.path error:NULL];
    for (NSString *subpath in subpaths) {
        [childPaths addObject:[self.path stringByAppendingPathComponent:subpath]];
    }
    self.childPaths = childPaths;
}

#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
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
    return [self.childPaths count];
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
    
    static NSString *FLOFileBrowserTableViewCellID = @"FLOFileBrowserTableViewCellID";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:FLOFileBrowserTableViewCellID];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:FLOFileBrowserTableViewCellID];
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
    
    NSString *fullPath = self.childPaths[indexPath.row];
    
    NSString *subpath = [fullPath lastPathComponent];
    NSString *pathExtension = [subpath pathExtension];
    
    BOOL isDirectory = NO;
    BOOL stillExists = [[NSFileManager defaultManager] fileExistsAtPath:fullPath isDirectory:&isDirectory];
    
    if (stillExists) {
        if (isDirectory) {
            UIViewController *drillInViewController = [[[self class] alloc] initWithPath:fullPath];
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

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

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
