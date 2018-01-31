//
//  FLOQSBKTableViewController.m
//  FLOAPP
//
//  Created by 360doc on 2018/1/29.
//  Copyright © 2018年 Flolangka. All rights reserved.
//

#import "FLOQSBKTableViewController.h"

#import "FLOQSBKTableViewCell.h"
#import "FLOQSBKTopicTableViewCell.h"

#import "FLOQSBKItem.h"
#import "FLOQSBKTopicItem.h"

#import "FLONetworkUtil.h"

#import <MJRefresh.h>
#import <AVKit/AVKit.h>
#import <MWPhotoBrowser.h>
#import <SDWebImage/SDImageCache.h>

@interface FLOQSBKTableViewController () <MWPhotoBrowserDelegate>

//是否是WiFi环境
@property (nonatomic, assign) BOOL isWIFI;

@property (nonatomic, strong) UISegmentedControl *seg;

//请求锁
@property (nonatomic, assign) BOOL requesting;

//糗事数据
@property (nonatomic, strong) NSMutableArray <FLOQSBKItem *>*dataArr;

//话题数据
@property (nonatomic, copy  ) NSString *currentTopic;
@property (nonatomic, assign) NSInteger topicPage;
@property (nonatomic, strong) NSMutableArray <FLOQSBKTopicItem *>*dataArrTopic;

//浏览图片数据
@property (nonatomic, strong) NSMutableArray *dataArrPicture;

@end

@implementation FLOQSBKTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _isWIFI = [AFNetworkReachabilityManager sharedManager].isReachableViaWiFi;
    
    _requesting = NO;
    
    _dataArr = [NSMutableArray arrayWithCapacity:42];
    
    _currentTopic = @"";
    _dataArrTopic = [NSMutableArray arrayWithCapacity:42];
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor = COLOR_HEX(0xefeff4);
    
    //导航栏
    [self configNav];
    
    //刷新控件
    [self configRefresh];
    
    [self requestNewData];
}

- (void)dealloc {
    [[SDImageCache sharedImageCache] clearMemory];
}

- (void)configNav {    
    _seg = [[UISegmentedControl alloc] initWithItems:@[@"糗事", @"话题"]];
    _seg.selectedSegmentIndex = 0;
    [_seg addTarget:self action:@selector(segmentedControlAction:) forControlEvents:UIControlEventValueChanged];
    self.navigationItem.titleView = _seg;
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:@selector(rightBarButtonItemAction)];
}

- (void)segmentedControlAction:(UISegmentedControl *)seg {
    //切换数据源
    [self.tableView reloadData];
    
    if (seg.selectedSegmentIndex == 0) {
        if (_dataArr.count == 0) {
            [self requestNewData];
        }
    } else {
        if (Def_CheckStringClassAndLength(_currentTopic)) {
            if (_dataArrTopic.count == 0) {
                [self requestNewData];
            }
        } else {
            [self rightBarButtonItemAction];
        }
    }
}

- (void)rightBarButtonItemAction {    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"TopicID" message:nil preferredStyle:UIAlertControllerStyleAlert];
    
    //输入框
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"1994";
        textField.keyboardType = UIKeyboardTypeASCIICapableNumberPad;
    }];
    
    //取消
    [alertController addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }]];
    
    //确定
    FLOWeakObj(self);
    FLOWeakObj(alertController);
    [alertController addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [weakself topicSubmit:weakalertController];
    }]];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)topicSubmit:(UIAlertController *)alertController {
    NSString *text = alertController.textFields.firstObject.text;
    
    if (Def_CheckStringClassAndLength(text)) {
        [self loadTopic:text];
    }
}

- (void)loadTopic:(NSString *)topic {
    _currentTopic = topic;
    [self requestNewData];
}

#pragma mark - MJRefresh
- (void)configRefresh {
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(requestNewData)];
    self.tableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(requestMoreData)];
}

//下拉刷新
- (void)requestNewData {
    if (_seg.selectedSegmentIndex == 0) {
        [self requestDataForNew:YES];
    } else {
        _topicPage = 0;
        [self requestDataForNew:YES];
    }
}

//上拉加载更多
- (void)requestMoreData {
    [self requestDataForNew:NO];
}

- (void)requestDataForNew:(BOOL)new {
    if (_requesting) {
        [self endRequest];
        return;
    }
    
    if (_seg.selectedSegmentIndex == 0) {
        _requesting = YES;
        if (new) {
            Def_MBProgressShow;
        }
        
        NSString *adID = [NSString stringWithFormat:@"%.0f000000000000", [[NSDate date] timeIntervalSince1970]];
        NSString *str = [NSString stringWithFormat:@"http://m2.qiushibaike.com/article/newlist?new=%d&AdID=%@", new ? 1 : 0, adID];
        
        [FLONetworkUtil HTTPSessionSetTextHTMLResponseSerializer];
        [[FLONetworkUtil sharedHTTPSession] GET:str parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            
            //解析请求结果
            NSArray *itemArr = nil;
            NSDictionary *result = (NSDictionary *)responseObject;
            if ([responseObject isKindOfClass:[NSData class]]) {
                result = [(NSData *)responseObject flo_objectFromJSONData];
            }
            
            if (Def_CheckDictionaryClassAndCount(result)) {
                NSArray *items = result[@"items"];
                if (Def_CheckArrayClassAndCount(items)) {
                    itemArr = items;
                }
            }
            
            //转model
            NSMutableArray *muarr = [NSMutableArray arrayWithCapacity:itemArr.count];
            for (NSDictionary *dict in itemArr) {
                FLOQSBKItem *item = [FLOQSBKItem itemWithDictionary:dict];
                if (item) {
                    [muarr addObject:item];
                }
            }
            
            //添加到数据源，刷新页面
            if (muarr.count > 0) {
                if (new) {
                    [_dataArr removeAllObjects];
                    [_dataArr addObjectsFromArray:muarr];
                    [self.tableView reloadData];
                } else {
                    NSMutableArray *muArr = [NSMutableArray array];
                    for (int i = 0; i < muarr.count; i++) {
                        [muArr addObject:[NSIndexPath indexPathForRow:_dataArr.count+i inSection:0]];
                    }
                    [_dataArr addObjectsFromArray:muarr];
                    [self.tableView insertRowsAtIndexPaths:muArr withRowAnimation:UITableViewRowAnimationBottom];
                }
            }
            
            Def_MBProgressHide;
            [self endRequest];
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            Def_MBProgressHide;
            [self endRequest];
        }];
    } else {
        if (Def_CheckStringClassAndLength(_currentTopic)) {
            _requesting = YES;
            if (_topicPage == 0) {
                Def_MBProgressShow;
            }
            
            NSString *adID = [NSString stringWithFormat:@"%.0f000000000000", [[NSDate date] timeIntervalSince1970]];
            NSString *str = [NSString stringWithFormat:@"https://circle.qiushibaike.com/article/topic/%@/all?page=%ld&AdID=%@", _currentTopic, _topicPage+1, adID];
            
            [[FLONetworkUtil sharedHTTPSession] GET:str parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                
                //解析请求结果
                NSArray *itemArr = nil;
                NSDictionary *result = (NSDictionary *)responseObject;
                if ([responseObject isKindOfClass:[NSData class]]) {
                    result = [(NSData *)responseObject flo_objectFromJSONData];
                }
                
                if (Def_CheckDictionaryClassAndCount(result)) {
                    NSArray *items = result[@"data"];
                    if (Def_CheckArrayClassAndCount(items)) {
                        itemArr = items;
                    }
                }
                
                //转model
                NSMutableArray *muarr = [NSMutableArray arrayWithCapacity:itemArr.count];
                for (NSDictionary *dict in itemArr) {
                    FLOQSBKTopicItem *item = [FLOQSBKTopicItem itemWithDictionary:dict];
                    if (item) {
                        [muarr addObject:item];
                    }
                }
                
                //添加到数据源，刷新页面
                if (muarr.count > 0) {
                    if (_topicPage == 0) {
                        [_dataArrTopic removeAllObjects];
                        [_dataArrTopic addObjectsFromArray:muarr];
                        [self.tableView reloadData];
                    } else {
                        NSMutableArray *muArr = [NSMutableArray array];
                        for (int i = 0; i < muarr.count; i++) {
                            [muArr addObject:[NSIndexPath indexPathForRow:_dataArrTopic.count+i inSection:0]];
                        }
                        [_dataArrTopic addObjectsFromArray:muarr];
                        [self.tableView insertRowsAtIndexPaths:muArr withRowAnimation:UITableViewRowAnimationBottom];
                    }
                    
                    //页码+1
                    _topicPage ++;
                }
                
                Def_MBProgressHide;
                [self endRequest];
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                Def_MBProgressHide;
                [self endRequest];
            }];
        } else {
            [self endRequest];
        }
    }
}

- (void)endRequest {
    [self.tableView.mj_header endRefreshing];
    [self.tableView.mj_footer endRefreshing];
    
    [FLONetworkUtil HTTPSessionSetJSONResponseSerializer];
    
    _requesting = NO;
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (_seg.selectedSegmentIndex == 1) {
        return _dataArrTopic.count;
    }
    return _dataArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (_seg.selectedSegmentIndex == 1) {
        NSString *cellID = @"FLOQSBKTopicCellID";
        
        FLOQSBKTopicTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
        if (!cell) {
            cell = [[FLOQSBKTopicTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
        }
        
        FLOQSBKTopicItem *item = _dataArrTopic[indexPath.row];
        [cell configUserIcon:item.userIcon
                    userName:item.userName
                  createTime:item.createTime
                     content:item.content
                    pictures:item.pictures];
        
        NSArray *imgPaths = item.pictures;
        FLOWeakObj(self);
        cell.imgAction = ^(NSInteger index) {
            [weakself pictureBrowser:imgPaths index:index];
        };
        return cell;
    }
    
    NSString *cellID = @"FLOQSBKCellID";
    
    FLOQSBKTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (!cell) {
        cell = [[FLOQSBKTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    }
    
    FLOQSBKItem *item = _dataArr[indexPath.row];
    if ([item isKindOfClass:[FLOQSBKWordItem class]]) {
        [cell configUserIcon:item.userIcon
                    userName:item.userName
                  createTime:item.createTime
                     content:item.content];
        
        cell.imgAction = nil;
    } else if ([item isKindOfClass:[FLOQSBKImageItem class]]) {
        FLOQSBKImageItem *imgItem = (FLOQSBKImageItem *)item;
        [cell configUserIcon:imgItem.userIcon
                    userName:imgItem.userName
                  createTime:imgItem.createTime
                     content:imgItem.content
                   imagePath:(_isWIFI ? imgItem.mediumImgPath : imgItem.smallImgPath)
                   imageSize:imgItem.size];
        
        NSString *imgPath = imgItem.mediumImgPath;
        FLOWeakObj(self);
        cell.imgAction = ^{
            [weakself pictureBrowser:@[imgPath] index:0];
        };
    } else if ([item isKindOfClass:[FLOQSBKVideoItem class]]) {
        FLOQSBKVideoItem *videoItem = (FLOQSBKVideoItem *)item;
        [cell configUserIcon:videoItem.userIcon
                    userName:videoItem.userName
                  createTime:videoItem.createTime
                     content:videoItem.content
                videoPicture:videoItem.imgPath
                   videoSize:videoItem.size];
        
        NSString *videoPath = videoItem.videoPath;
        FLOWeakObj(self);
        cell.imgAction = ^{
            [weakself playVideo:videoPath];
        };
    }
    
    return cell;
}

#pragma mark - tableView delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    [[UIMenuController sharedMenuController] setMenuVisible:NO animated:YES];
    [[UIMenuController sharedMenuController] setMenuItems:@[]];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [[UIMenuController sharedMenuController] setMenuVisible:NO animated:YES];
    [[UIMenuController sharedMenuController] setMenuItems:@[]];
}

#pragma mark - 浏览图片
- (void)pictureBrowser:(NSArray *)pictures index:(NSInteger)index {
    _dataArrPicture = [NSMutableArray array];
    for (NSString *img in pictures) {
        [_dataArrPicture addObject:[MWPhoto photoWithURL:[NSURL URLWithString:img]]];
    }
    
    MWPhotoBrowser *browser = [[MWPhotoBrowser alloc] initWithDelegate:self];
    
    // Set options
    browser.zoomPhotosToFill = YES; // Images that almost fill the screen will be initially zoomed to fill (defaults to YES)
    browser.enableGrid = NO; // Whether to allow the viewing of all the photo thumbnails on a grid (defaults to YES)
    
    [browser setCurrentPhotoIndex:index];
    
    // Present
    [self.navigationController pushViewController:browser animated:YES];
}

- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser {
    return _dataArrPicture.count;
}

- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index {
    if (index < _dataArrPicture.count) {
        return [_dataArrPicture objectAtIndex:index];
    }
    return nil;
}

#pragma mark - 打开视频
- (void)playVideo:(NSString *)videoPath {
    AVPlayerViewController *playerVC = [[AVPlayerViewController alloc] init];
    playerVC.player = [AVPlayer playerWithURL:[NSURL URLWithString:videoPath]];
    
    [self presentViewController:playerVC animated:YES completion:nil];
}
@end
