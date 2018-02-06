//
//  FLOLeftMenuVC.m
//  XMPPChat
//
//  Created by admin on 15/11/25.
//  Copyright © 2015年 Flolangka. All rights reserved.
//

#import "FLOLeftMenuVC.h"
#import <RESideMenu.h>
#import "FLOAccountManager.h"
#import "FLOWeiboAuthorization.h"

@interface FLOLeftMenuVC ()<UITableViewDataSource, UITableViewDelegate, RESideMenuDelegate>

{
    NSArray *_titles;
    NSArray *_images;
}

@property (strong, readwrite, nonatomic) UITableView *tableView;

//注销、登陆按钮
@property (nonatomic, strong) UIButton *bottomBtn;

@end

@implementation FLOLeftMenuVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _titles = @[@"首页", @"设置"];
    _images = @[@"IconHome", @"IconSettings"];
    
    self.tableView = ({
        UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 100, self.view.frame.size.width, 100 + 54 * _titles.count) style:UITableViewStylePlain];
        tableView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth;
        tableView.delegate = self;
        tableView.dataSource = self;
        tableView.opaque = NO;
        tableView.backgroundColor = [UIColor clearColor];
        tableView.backgroundView = nil;
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        tableView.bounces = NO;
        tableView.scrollsToTop = NO;
        tableView;
    });
    [self.view addSubview:self.tableView];
    
    _bottomBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _bottomBtn.frame = CGRectMake(10, [UIScreen mainScreen].bounds.size.height-44, 80, 44);
    _bottomBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    _bottomBtn.tintColor = [UIColor whiteColor];
    [_bottomBtn addTarget:self action:@selector(bottomButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_bottomBtn];
    [self refreshBottomBtnTitle];
}

//注销
- (void)bottomButtonAction:(id)sender
{
    BOOL isLogin = [[FLOAccountManager shareManager] checkLoginState];
    if (isLogin) {
        //注销
        [[FLOAccountManager shareManager] logOut];
        [[FLOWeiboAuthorization sharedAuthorization] logout];
        
        //返回首页
        [self.sideMenuViewController setContentViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"SBIDFloCollectionNavigationController"]
                                                     animated:YES];
        [self.sideMenuViewController hideMenuViewController];
    } else {
        //登录
        [self.sideMenuViewController presentViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"SBIDloginViewController"] animated:NO completion:nil];
    }
}

//刷新用户名
- (void)refreshView
{
    [self refreshBottomBtnTitle];
    [self.tableView reloadData];
}

- (void)refreshBottomBtnTitle {
    NSString *btnTitle = [[FLOAccountManager shareManager] checkLoginState] ? @"Logout" : @"Login";
    [_bottomBtn setTitle:btnTitle forState:UIControlStateNormal];
}

#pragma mark - UITableView Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 0) {
        return;
    }
    
    switch (indexPath.row) {
        case 0:
            [self.sideMenuViewController setContentViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"SBIDFloCollectionNavigationController"]
                                                         animated:YES];
            [self.sideMenuViewController hideMenuViewController];
            break;
//        case 1:
//            [self.sideMenuViewController setContentViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"SBIDFLOTabBarVCID"]
//                                                         animated:YES];
//            [self.sideMenuViewController hideMenuViewController];
//            break;
        case 1:
            [self.sideMenuViewController setContentViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"settigViewController"]
                                                         animated:YES];
            [self.sideMenuViewController hideMenuViewController];
            break;
        default:
            break;
    }
}

#pragma mark -
#pragma mark UITableView Datasource

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return indexPath.row == 0 ? 80 : 54;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectionIndex
{
    return sectionIndex == 0 ? 1 : _titles.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.backgroundColor = [UIColor clearColor];
        
        cell.textLabel.highlightedTextColor = [UIColor lightGrayColor];
        cell.selectedBackgroundView = [[UIView alloc] init];
    }
    
    if (indexPath.section == 0) {
        for (UIView *subView in cell.contentView.subviews) {
            [subView removeFromSuperview];
        }
        
        //未登录显示游客
        NSString *name = [[NSUserDefaults standardUserDefaults] objectForKey:@"username"];
        if (!Def_CheckStringClassAndLength(name)) {
            name = @"游客";
        }
        
        //用户
        UILabel *nameLabel = [[UILabel alloc] init];
        nameLabel.text = name;
        nameLabel.font = [UIFont fontWithName:@"Chalkduster" size:28];
        nameLabel.textColor = [UIColor whiteColor];
        nameLabel.textAlignment = NSTextAlignmentCenter;
        CGRect nameLabelRect = [nameLabel textRectForBounds:CGRectMake(0, 0, 200, 60) limitedToNumberOfLines:1];
        CGFloat lastWidth = nameLabelRect.size.width + 30;
        CGFloat nameLabelWidth = lastWidth > 60 ? lastWidth : 60.0;
        nameLabel.frame = CGRectMake(30, 10, nameLabelWidth, 60);
        nameLabel.layer.cornerRadius = 30.0;
        nameLabel.clipsToBounds = YES;
        
        //透明背景
        CALayer *backgroundLayer = [[CALayer alloc] init];
        backgroundLayer.frame = CGRectMake(0, 0, nameLabelWidth, 60);
        backgroundLayer.backgroundColor = [UIColor groupTableViewBackgroundColor].CGColor;
        backgroundLayer.opacity = 0.4;
        backgroundLayer.cornerRadius = 30.0;
        [nameLabel.layer addSublayer:backgroundLayer];
        
        [cell.contentView addSubview:nameLabel];
        
    } else {
        //菜单
        cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:21];
        cell.textLabel.textColor = [UIColor whiteColor];
        
        cell.textLabel.text = _titles[indexPath.row];
        cell.imageView.image = [UIImage imageNamed:_images[indexPath.row]];
    }
    
    return cell;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
