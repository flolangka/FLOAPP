//
//  FLOWeiboDetailViewController.m
//  XMPPChat
//
//  Created by admin on 15/12/20.
//  Copyright © 2015年 Flolangka. All rights reserved.
//

#import "FLOWeiboDetailViewController.h"
#import "FLOWeiboAuthorization.h"
#import "FLOWeiboStatusModel.h"
#import <AFHTTPSessionManager.h>
#import "FLOWeiboCommentModel.h"
#import <MBProgressHUD.h>
#import "FLOWeiboStatusTableViewCell.h"
#import "FLOWeiboCommentTableViewCell.h"
#import "FLOWeiboReportComViewController.h"

static NSString * const kShowCommentsURL = @"https://api.weibo.com/2/comments/show.json";

@interface FLOWeiboDetailViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) NSMutableArray *dataArr;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation FLOWeiboDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.dataArr = [NSMutableArray array];
    [self configTabBarV];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self requestData];
}

#pragma mark - 底部转发与评论
- (void)configTabBarV
{
    CGFloat width = self.view.frame.size.width;
    CGFloat height = self.view.frame.size.height;
    
    UIView *footerV = [[UIView alloc] initWithFrame:CGRectMake(0, height-104, width, 44)];
    footerV.backgroundColor = [UIColor groupTableViewBackgroundColor];
    UIButton *repostBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    repostBtn.frame = CGRectMake(0, 0, width/2-1, 43);
    [repostBtn setImage:[UIImage imageNamed:@"statusdetail_icon_retweet"] forState:UIControlStateNormal];
    [repostBtn setTitle:@" 转发" forState:UIControlStateNormal];
    [repostBtn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    [repostBtn addTarget:self action:@selector(repostAction) forControlEvents:UIControlEventTouchUpInside];
    
    UIView *spaceV = [[UIView alloc] initWithFrame:CGRectMake(width/2-1, 12, 1, 20)];
    spaceV.backgroundColor = [UIColor lightGrayColor];
    UIView *topV = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, 1)];
    topV.backgroundColor = [UIColor lightGrayColor];
    
    UIButton *commentBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    commentBtn.frame = CGRectMake(width/2, 0, width/2, 43);
    [commentBtn setImage:[UIImage imageNamed:@"statusdetail_icon_comment"] forState:UIControlStateNormal];
    [commentBtn setTitle:@" 评论" forState:UIControlStateNormal];
    [commentBtn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    [commentBtn addTarget:self action:@selector(commentAction) forControlEvents:UIControlEventTouchUpInside];
    [footerV addSubview:topV];
    [footerV addSubview:commentBtn];
    [footerV addSubview:spaceV];
    [footerV addSubview:repostBtn];
    [self.view addSubview:footerV];
}

- (void)repostAction
{
    FLOWeiboReportComViewController *reportComVC = [self.storyboard instantiateViewControllerWithIdentifier:@"weiboCommandVC"];
    reportComVC.statusID = _status.statusID;
    reportComVC.title = @"转发微博";
    
    [self.navigationController pushViewController:reportComVC animated:YES];
}

- (void)commentAction
{
    FLOWeiboReportComViewController *reportComVC = [self.storyboard instantiateViewControllerWithIdentifier:@"weiboCommandVC"];
    reportComVC.statusID = _status.statusID;
    reportComVC.title = @"评论微博";
    
    [self.navigationController pushViewController:reportComVC animated:YES];
}

#pragma mark - 请求评论数据
- (void)requestData
{
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setObject:[FLOWeiboAuthorization sharedAuthorization].token forKey:kAccessToken];
    [parameters setObject:_status.statusID forKey:@"id"];
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager GET:kShowCommentsURL parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *result = (NSDictionary *)responseObject;
        NSArray *comments = result[@"comments"];
        
        self.dataArr = [NSMutableArray array];
        for (NSDictionary *comDic in comments) {
            FLOWeiboCommentModel *comModel = [[FLOWeiboCommentModel alloc] initWithDictionary:comDic];
            [self.dataArr addObject:comModel];
        }
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationNone];
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.mode = MBProgressHUDModeText;
        hud.labelText = [NSString stringWithFormat:@"错误:%@", error.localizedDescription];
        [hud hide:YES afterDelay:1.0];
    }];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return section == 0 ? 1 : _dataArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell;
    if (indexPath.section == 0) {
        FLOWeiboStatusTableViewCell *mycell = [tableView dequeueReusableCellWithIdentifier:@"statusCell"];
        [mycell setContentWithStatus:_status];
        
        cell = mycell;
    } else {
        // 评论或转发列表
        FLOWeiboCommentTableViewCell *mycell = [tableView dequeueReusableCellWithIdentifier:@"CommentCell"];
        [mycell setContentWithCommentModel:_dataArr[indexPath.row]];
        cell = mycell;
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        FLOWeiboStatusTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"statusCell"];
        
        //取出要显示的数据
        return [cell cellHeight4StatusModel:_status]+5;
    }else{
        FLOWeiboCommentTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CommentCell"];
        [cell setContentWithCommentModel:_dataArr[indexPath.row]];
        
        //计算出根据内容显示的区域
        CGSize size = [cell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
        return size.height + 5;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    CGFloat height = 0;
    if (section == 0) {
        height = 0.5;
    } else {
        height = 30;
    }
    return height;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 1) {
        return @"评论";
    }
    return nil;
}

@end
