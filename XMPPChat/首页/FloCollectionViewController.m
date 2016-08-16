//
//  FloCollectionViewController.m
//  XMPPChat
//
//  Created by admin on 15/12/4.
//  Copyright © 2015年 Flolangka. All rights reserved.
//

#import "FloCollectionViewController.h"
#import "FLOAccountManager.h"
#import "FLOSideMenu.h"
#import "FLOCollectionItem.h"
#import "FLOWebViewController.h"
#import "FLOCollectionViewCell.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "FLODataBaseEngin.h"
#import <MBProgressHUD.h>

#ifdef DEBUG
#import <FLEX.h>
#endif

@interface FloCollectionViewController()<UIViewControllerPreviewingDelegate>

{
    id<UIViewControllerPreviewing> previewing;
}

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@property (nonatomic, strong) NSMutableArray *dataArr;

@end

@implementation FloCollectionViewController

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.dataArr = [NSMutableArray arrayWithCapacity:20];
    
//    NSArray *recordItems = [[FLODataBaseEngin shareInstance] selectAllCollectionItem];
    NSArray *recordItems = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"CollectionPList" ofType:@"plist"]];
    for (NSDictionary *dic in recordItems) {
        FLOCollectionItem *item = [[FLOCollectionItem alloc] initWithDictionary:dic];
        [_dataArr addObject:item];
    }
    
    //背景图片
    UIImage *image = [UIImage imageNamed:@"homeback"];
    self.view.layer.contents = (id)image.CGImage;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //检查用户是否登录
    [self checkIsLogin];
}

- (void)checkIsLogin
{
    BOOL isLogin = [[FLOAccountManager shareManager] checkLoginState];
    if (isLogin) {
        
        return;
    } else {
        [[FLOSideMenu sideMenu] presentViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"SBIDloginViewController"] animated:NO completion:nil];
    }
}

//进入FLEX调试状态
- (IBAction)flexAction:(UIBarButtonItem *)sender {
#ifdef DEBUG
    [[FLEXManager sharedManager] showExplorer];
#endif
}

#pragma mark - CollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _dataArr.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    FLOCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CollectionViewCellID" forIndexPath:indexPath];
    
    FLOCollectionItem *item = _dataArr[indexPath.item];
    
    //图标
    if ([item.itemIconURLStr hasPrefix:@"http"]) {
        [cell.imageV sd_setImageWithURL:[NSURL URLWithString:item.itemIconURLStr] placeholderImage:[UIImage imageNamed:@"iOS"]];
    } else {
        cell.imageV.image = [UIImage imageNamed:item.itemIconURLStr];
    }
    
    //名称
    cell.titleL.text = item.itemName;
    
    //注册Force_Touch
    if ([item.itemAddress isEqualToString:@"Force_Touch"]) {
        previewing = [self registerForPreviewingWithDelegate:self sourceView:cell];
    }
    
    return cell;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

#pragma mark --UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    FLOCollectionItem *item = _dataArr[indexPath.item];
    NSString *itemAddress = item.itemAddress;
    if ([itemAddress hasPrefix:@"URLScheme_"]) {
        NSURL *appURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@://", [itemAddress substringFromIndex:10]]];
        if ([[UIApplication sharedApplication] canOpenURL:appURL]) {
            [[UIApplication sharedApplication] openURL:appURL];
        } else {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"打开失败" message:@"请检查是否已安装并信任应用" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil];
            [alert addAction:okAction];
            
            [self presentViewController:alert animated:YES completion:nil];
        }
    } else if ([itemAddress hasPrefix:@"SBID"]) {
        [self.navigationController pushViewController:[self.storyboard instantiateViewControllerWithIdentifier:itemAddress] animated:YES];
    } else if ([itemAddress hasPrefix:@"http"]) {
        FLOWebViewController *webViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"SBIDWebViewController"];
        webViewController.webViewAddress = itemAddress;
        
        [self.navigationController pushViewController:webViewController animated:YES];
    } else if ([itemAddress hasPrefix:@"FLO"]) {
        Class ob = NSClassFromString(itemAddress);
        UIViewController *viewController = [[ob alloc] init];
        
        [self.navigationController pushViewController:viewController animated:YES];
    } else if ([itemAddress hasPrefix:@"Present"]) {
        NSString *classStr = [itemAddress substringFromIndex:7];
        Class ob = NSClassFromString(classStr);
        UIViewController *viewController = [[ob alloc] init];
        viewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        
        [self presentViewController:viewController animated:YES completion:nil];
    } else if ([itemAddress isEqualToString:@"Force_Touch"]) {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.mode = MBProgressHUDModeText;
        hud.labelText = @"用力按我吧";
        [hud hide:YES afterDelay:1.0];
    } else {
        return;
    }
}

#pragma mark - UICollectionViewLayout
//下面2个方法确定item之间的间隔为0；
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 0.0f;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat width = [UIScreen mainScreen].bounds.size.width-32;
    return CGSizeMake(width/4.0, width/4.0+17);
}

#pragma mark - Force Touch 
- (UIViewController *)previewingContext:(id<UIViewControllerPreviewing>)previewingContext viewControllerForLocation:(CGPoint)location {
    UIViewController *childVC = [self.storyboard instantiateViewControllerWithIdentifier:@"SBIDWeiboTableViewController"];
    
    return childVC;
}
- (void)previewingContext:(id<UIViewControllerPreviewing>)previewingContext commitViewController:(UIViewController *)viewControllerToCommit {
    [self showViewController:viewControllerToCommit sender:self];
}


@end
