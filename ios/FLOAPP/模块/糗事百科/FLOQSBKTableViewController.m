//
//  FLOQSBKTableViewController.m
//  FLOAPP
//
//  Created by 360doc on 2018/1/29.
//  Copyright © 2018年 Flolangka. All rights reserved.
//

#import "FLOQSBKTableViewController.h"

#import "FLOQSBKTopicItem.h"

#import "FLOQSBKTopicTableViewCell.h"

#import <MJRefresh.h>
#import <AFHTTPSessionManager.h>

@interface FLOQSBKTableViewController ()

@property (nonatomic, assign) BOOL requesting;

@property (nonatomic, copy  ) NSString *currentTopic;
@property (nonatomic, strong) NSMutableArray <FLOQSBKTopicItem *>*dataArrTopic;
@property (nonatomic, assign) NSInteger topicPage;

@end

@implementation FLOQSBKTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _requesting = NO;
    _currentTopic = @"";
    _dataArrTopic = [NSMutableArray arrayWithCapacity:42];
    
    //导航栏
    [self configNav];
    [self configRefresh];
}

- (void)configNav {
    self.title = @"话题";
    
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
//    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addTimeNoti)];
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    [super setEditing:editing animated:animated];
    
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
    [self requestNewTopicData];
}

#pragma mark - MJRefresh
- (void)configRefresh {
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(requestNewTopicData)];
    self.tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(requestTopicData)];
}

//下拉刷新
- (void)requestNewTopicData {
    _topicPage = 0;
    [self requestTopicData];
}

//上拉加载更多
- (void)requestTopicData {
    if (Def_CheckStringClassAndLength(_currentTopic)) {
        _requesting = YES;
        
        NSString *adID = [NSString stringWithFormat:@"%.0f000000000000", [[NSDate date] timeIntervalSince1970]];
        NSString *str = [NSString stringWithFormat:@"https://circle.qiushibaike.com/article/topic/%@/all?page=%ld&AdID=%@", _currentTopic, _topicPage+1, adID];
        
        [[AFHTTPSessionManager manager] GET:str parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            
            //解析请求结果
            NSArray *itemArr = nil;
            NSDictionary *result = (NSDictionary *)responseObject;
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
                }
                [_dataArrTopic addObjectsFromArray:muarr];
                [self.tableView reloadData];
                
                //页码+1
                _topicPage ++;
            }
            
            [self endRequest];
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            [self endRequest];
        }];
    } else {
        [self endRequest];
    }
}

- (void)endRequest {
    [self.tableView.mj_header endRefreshing];
    [self.tableView.mj_footer endRefreshing];
    
    _requesting = NO;
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _dataArrTopic.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellID = @"FLOQSBKTopicItem";
    
    FLOQSBKTopicTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (!cell) {
        cell = [[FLOQSBKTopicTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    }
    
    [cell configTopicItem:_dataArrTopic[indexPath.row]];
    
    return cell;
}

#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    FLOQSBKTopicItem *topicItem = _dataArrTopic[indexPath.row];
    
    return topicItem.cellHeight;
}

@end
