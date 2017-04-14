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

#define FileSavePath @"/flodownload/file/"

@interface FLODownloadTableViewController ()

{
    NSMutableArray *dataArr;
}

@end

@implementation FLODownloadTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"下载";
    [FLOUtil CreatFilePathInCachesWithName:FileSavePath];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addDownload)];
    
    [self initData];
    [self checkPasteboard];
    
    self.tableView.tableFooterView = [UIView new];
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
    maskView.navBar.topItem.title = @"添加下载地址";
    maskView.bookMarkNameTF.text = name;
    maskView.bookMarkURLTF.text = url;
    maskView.submit = ^void(NSString *name, NSString *urlStr){
        // 插入数据库
        DownloadFile *obj = [NSEntityDescription insertNewObjectForEntityForName:@"DownloadFile" inManagedObjectContext:[APLCoreDataStackManager sharedManager].managedObjectContext];
        obj.downloadURL = urlStr;
        obj.downloadStatus = 0;
        obj.downloadProgress = 0;
        obj.fileName = name;
        obj.taskID = [NSString stringWithFormat:@"com.flolangka.FloAPP.%.0f", [NSDate timeIntervalSinceReferenceDate]];
        obj.savePath = FileSavePath;
        obj.downloadDate = [NSDate date];
        [[APLCoreDataStackManager sharedManager].managedObjectContext save:nil];
        
        // 添加到下载队列
        [[FLODownloadManager manager] downloadTask:obj.taskID];
        
        // 刷新页面
        [dataArr addObject:obj];
        [self.tableView reloadData];
    };
    
    CGSize size = [UIScreen mainScreen].bounds.size;
    maskView.frame = CGRectMake(size.width, 20, size.width, size.height-20);
    [[UIApplication sharedApplication].keyWindow addSubview:maskView];
    
    [UIView animateWithDuration:0.25 animations:^{
        maskView.frame = CGRectMake(0, 20, size.width, size.height-20);
    }];
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
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
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
