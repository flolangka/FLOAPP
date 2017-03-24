//
//  FLOMediaAddressTableViewController.m
//  FLOAPP
//
//  Created by 沈敏 on 2017/1/4.
//  Copyright © 2017年 Flolangka. All rights reserved.
//

#import "FLOMediaAddressTableViewController.h"
#import "MediaAddress+CoreDataClass.h"
#import "FLOAddBookMarkMaskView.h"
#import "APLCoreDataStackManager.h"

#import <AVKit/AVKit.h>
#import <AVFoundation/AVFoundation.h>

@interface FLOMediaAddressTableViewController ()

{
    NSMutableArray *dataArr;
}
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

@end

@implementation FLOMediaAddressTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"流媒体";
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addMediaAddress)];
    
    [self initData];
    [self checkPasteboard];
    
    self.tableView.tableFooterView = [UIView new];
}

- (void)initData {
    //查询数据库
    //建立请求
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"MediaAddress"];
    //读取数据
    NSArray *array = [self.managedObjectContext executeFetchRequest:request error:nil];
    
    dataArr = [NSMutableArray arrayWithArray:array];
}

// 检测剪切板网址
- (void)checkPasteboard {
    NSString *pasteboardString = [UIPasteboard generalPasteboard].string;
    if (pasteboardString && ([pasteboardString hasPrefix:@"http://"] || [pasteboardString hasPrefix:@"https://"])) {
        __block BOOL selected = NO;
        
        [dataArr enumerateObjectsUsingBlock:^(MediaAddress *obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj.url isEqualToString:pasteboardString]) {
                selected = YES;
                *stop = YES;
            }
        }];
        
        if (!selected) {
            [self addMediaAddressName:@"" url:pasteboardString];
            
            Def_MBProgressString(@"检测到剪切板网址");
        }
    }
}

- (void)addMediaAddress {
    [self addMediaAddressName:@"" url:@""];
}

- (void)addMediaAddressName:(NSString *)name url:(NSString *)url {
    FLOAddBookMarkMaskView *maskView = [[[NSBundle mainBundle] loadNibNamed:@"FLOAddBookMarkMaskView" owner:nil options:nil] objectAtIndex:0];
    maskView.navBar.topItem.title = @"添加流媒体地址";
    maskView.bookMarkNameTF.text = name;
    maskView.bookMarkURLTF.text = url;
    maskView.submit = ^void(NSString *name, NSString *urlStr){
        // 插入数据库
        MediaAddress *obj = [NSEntityDescription insertNewObjectForEntityForName:@"MediaAddress" inManagedObjectContext:self.managedObjectContext];
        obj.name = name;
        obj.url = urlStr;
        [self.managedObjectContext save:nil];
        
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
    
    MediaAddress *obj = dataArr[indexPath.row];
    cell.textLabel.text = obj.name;
    cell.detailTextLabel.text = obj.url;
    
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
        [self.managedObjectContext deleteObject:dataArr[indexPath.row]];
        [self.managedObjectContext save:nil];
        
        [dataArr removeObjectAtIndex:indexPath.row];
        
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    MediaAddress *obj = [dataArr objectAtIndex:indexPath.row];
    
    AVPlayerViewController *playerVC = [[AVPlayerViewController alloc] init];
    playerVC.player = [AVPlayer playerWithURL:[NSURL URLWithString:obj.url]];
    
    [self presentViewController:playerVC animated:YES completion:nil];
}

#pragma mark - Core Data support
- (NSManagedObjectContext *)managedObjectContext {
    if (_managedObjectContext) {
        return _managedObjectContext;
    }
    
    _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    _managedObjectContext.persistentStoreCoordinator = [[APLCoreDataStackManager sharedManager] persistentStoreCoordinator];
    
    return _managedObjectContext;
}

@end
