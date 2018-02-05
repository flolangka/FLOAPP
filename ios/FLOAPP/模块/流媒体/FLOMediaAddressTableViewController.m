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
    NSArray *array = [[APLCoreDataStackManager sharedManager].managedObjectContext executeFetchRequest:request error:nil];
    
    dataArr = [NSMutableArray arrayWithArray:array];
    
    if (dataArr.count == 0) {
        [self addMediaAddressName:@"三分钟 - 陈可辛 - 用 iPhone X 拍摄" url:@"https://images.apple.com/media/cn/chinese-new-year/three-minutes/2018/f14ed516_730e_499a_8374_afd743848de6/films/three-minutes/iphone-three-minutes-tpl-cn-20180201_1280x720h.mp4"];
    }
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
            [self loadAddMaskViewName:@"" url:pasteboardString];
            
            Def_MBProgressString(@"检测到剪切板网址");
        }
    }
}

- (void)addMediaAddress {
    [self loadAddMaskViewName:@"" url:@""];
}

- (void)loadAddMaskViewName:(NSString *)name url:(NSString *)url {
    FLOAddBookMarkMaskView *maskView = [[[NSBundle mainBundle] loadNibNamed:@"FLOAddBookMarkMaskView" owner:nil options:nil] objectAtIndex:0];
    maskView.navBar.topItem.title = @"添加流媒体地址";
    maskView.bookMarkNameTF.text = name;
    maskView.bookMarkURLTF.text = url;
    
    FLOWeakObj(self);
    maskView.submit = ^void(NSString *name, NSString *urlStr){
        [weakself addMediaAddressName:name url:urlStr];
    };
    
    CGSize size = [UIScreen mainScreen].bounds.size;
    maskView.frame = CGRectMake(size.width, 20, size.width, size.height-20);
    [[UIApplication sharedApplication].keyWindow addSubview:maskView];
    
    [UIView animateWithDuration:0.25 animations:^{
        maskView.frame = CGRectMake(0, 20, size.width, size.height-20);
    }];
}

- (void)addMediaAddressName:(NSString *)name url:(NSString *)url {
    // 插入数据库
    MediaAddress *obj = [NSEntityDescription insertNewObjectForEntityForName:@"MediaAddress" inManagedObjectContext:[APLCoreDataStackManager sharedManager].managedObjectContext];
    obj.name = name;
    obj.url = url;
    [[APLCoreDataStackManager sharedManager].managedObjectContext save:nil];
    
    // 刷新页面
    [dataArr addObject:obj];
    [self.tableView reloadData];
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
        [[APLCoreDataStackManager sharedManager].managedObjectContext deleteObject:dataArr[indexPath.row]];
        [[APLCoreDataStackManager sharedManager].managedObjectContext save:nil];
        
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

@end
