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

@interface FloCollectionViewController()

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@property (nonatomic, strong) NSMutableArray *dataArr;

@end

@implementation FloCollectionViewController

- (void)awakeFromNib
{
    self.dataArr = [NSMutableArray array];
    [self.dataArr addObject:[[FLOCollectionItem alloc] initWithDictionary:@{@"ItemName": @"XMPPChat",
                                                                           @"ItemIconURL": @"http://a1791.phobos.apple.com/us/r30/Purple/1a/91/fc/mzl.ajlfscng.png",
                                                                           @"ItemAddress": @"SBIDFLOTabBarVCID"}]];
    [self.dataArr addObject:[[FLOCollectionItem alloc] initWithDictionary:@{@"ItemName": @"UIFont",
                                                                            @"ItemIconURL": @"https://cdn.rawgit.com/dtgm/chocolatey-packages/09cd515153eed9aaa929eaf022889bcb8419d601/icons/nexusfont.png",
                                                                            @"ItemAddress": @"SBIDFontTableViewController"}]];
    
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

#pragma mark - CollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _dataArr.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    FLOCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CollectionViewCellID" forIndexPath:indexPath];
    
    FLOCollectionItem *item = _dataArr[indexPath.item];
    [cell.imageV sd_setImageWithURL:item.itemIconURL placeholderImage:[UIImage imageNamed:@"iOS"]];
    cell.titleL.text = item.itemName;
    
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
    if ([itemAddress isEqualToString:@"SBIDFLOTabBarVCID"]) {
        //切换到聊天
        [self.sideMenuViewController setContentViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"SBIDFLOTabBarVCID"]
                                                     animated:YES];
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


@end
