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
#import "FLOCollectionViewLayout.h"
#import "UIView+FLOUtil.h"
#import "YYFPSLabel.h"
#import "MVVMRouter.h"

#import <UIView+YYAdd.h>
#import <MBProgressHUD.h>
#import <SDWebImage/UIImageView+WebCache.h>

#ifdef DEBUG
#import <FLEX.h>
#endif

@interface FloCollectionViewController()
<UICollectionViewDelegate,
UICollectionViewDataSource,
UICollectionViewDelegateFlowLayout,
UIViewControllerPreviewingDelegate>

{
    id<UIViewControllerPreviewing> previewing;
    UICollectionView *collectionV;
    CGFloat width;
}

@property (nonatomic, strong) NSMutableArray *dataArr;

@end

@implementation FloCollectionViewController

- (void)awakeFromNib {
    [super awakeFromNib];
    self.dataArr = [NSMutableArray arrayWithCapacity:20];
    
    // 读取数据
    NSArray *recordItems = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"CollectionPList" ofType:@"plist"]];
    for (NSDictionary *dic in recordItems) {
        FLOCollectionItem *item = [[FLOCollectionItem alloc] initWithDictionary:dic];
        [_dataArr addObject:item];
    }
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initCollectionView];
    
    /*/ FPS指示器
    YYFPSLabel *fps = [YYFPSLabel new];
    fps.centerY = 24;
    fps.centerX = DEVICE_SCREEN_WIDTH/2.;
    [[UIApplication sharedApplication].keyWindow addSubview:fps];
     */
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    BOOL animate = self.presentedViewController == nil;
    [self.navigationController setNavigationBarHidden:YES animated:animate];
    
    //检查用户是否登录
    //[self checkIsLogin];  2018-02-05 17:37:33 免登陆
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)initCollectionView {
    // CollectionView布局样式
    CGFloat maxWidth = 70;
    CGFloat space = 27;
    int num = 3;
    do {
        width = (DEVICE_SCREEN_WIDTH - (num+1)*space)/(float)num;
        num += 1;
    } while (width > maxWidth);
    
    FLOCollectionViewLayout *layout = [[FLOCollectionViewLayout alloc] init];
    layout.numberOfColum = num - 1;
    layout.horizontalSpace = space;
    layout.verticalSpace = 12;
    CGFloat weakWidth = width;
    layout.itemHeight = ^CGFloat(NSIndexPath *indexPath){
        return weakWidth+17;
    };
    
    collectionV = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, DEVICE_SCREEN_WIDTH, DEVICE_SCREEN_HEIGHT) collectionViewLayout:layout];
    collectionV.backgroundColor = [UIColor clearColor];
    collectionV.contentInset = UIEdgeInsetsMake(0, 0, 20, 0);
    collectionV.dataSource = self;
    collectionV.delegate = self;
    [collectionV registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"CollectionViewCellID"];
    [collectionV registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"CollectionViewForce_TouchCellID"];
    [self.view addSubview:collectionV];
    
    //背景图片
    UIImage *image = [UIImage imageNamed:@"homeback.jpg"];
    self.view.layer.contents = (id)image.CGImage;
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
    FLOCollectionItem *item = _dataArr[indexPath.item];
    
    UICollectionViewCell *cell = nil;
    if ([item.itemAddress isEqualToString:@"Force_Touch"]) {
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CollectionViewForce_TouchCellID" forIndexPath:indexPath];
        
        //注册Force_Touch
        previewing = [self registerForPreviewingWithDelegate:self sourceView:cell];
    } else {
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CollectionViewCellID" forIndexPath:indexPath];
    }
    
    UIImageView *imageV = [cell.contentView viewWithTag:4444];
    UILabel *label = [cell.contentView viewWithTag:5555];
    if (!imageV) {
        imageV = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, width, width)];
        [imageV flo_setCornerRadius:10];
        imageV.tag = 4444;
        
        label = [[UILabel alloc] initWithFrame:CGRectMake(0, width, width, 17)];
        label.font = [UIFont systemFontOfSize:12];
        label.textColor = [UIColor whiteColor];
        label.textAlignment = NSTextAlignmentCenter;
        label.tag = 5555;
        
        [cell.contentView addSubview:imageV];
        [cell.contentView addSubview:label];
    }
    
    //图标
    if ([item.itemIconURLStr hasPrefix:@"http"]) {
        [imageV sd_setImageWithURL:[NSURL URLWithString:item.itemIconURLStr] placeholderImage:[UIImage imageNamed:@"interesting"]];
    } else {
        imageV.image = [UIImage imageNamed:item.itemIconURLStr];
    }
    
    //名称
    label.text = item.itemName;
    
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
    } else if ([itemAddress hasPrefix:@"Present"]) {
        NSString *classStr = [itemAddress substringFromIndex:7];
        
        BOOL nav = [classStr hasPrefix:@"NavigationController"];
        if (nav) {
            classStr = [classStr substringFromIndex:[@"NavigationController" length]];
        }
        
        UIViewController *vc = nil;
        if ([classStr hasSuffix:@"ViewModel"]) {
            vc = [MVVMRouter viewControllerForViewModelClassString:classStr];
        } else {
            Class ob = NSClassFromString(classStr);
            vc = [[ob alloc] init];
            vc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        }
        
        if (nav) {
            UINavigationController *navC = [[UINavigationController alloc] initWithRootViewController:vc];
            [self presentViewController:navC animated:NO completion:nil];
        } else {
            [self presentViewController:vc animated:NO completion:nil];
        }
    } else if ([itemAddress hasSuffix:@"ViewModel"]) {
        FLOBaseViewController *viewController = [MVVMRouter viewControllerForViewModelClassString:itemAddress];
        
        [self.navigationController pushViewController:viewController animated:YES];
    } else if ([itemAddress hasPrefix:@"FLO"]) {
        Class ob = NSClassFromString(itemAddress);
        UIViewController *viewController = [[ob alloc] init];
        
        [self.navigationController pushViewController:viewController animated:YES];
    } else if ([itemAddress isEqualToString:@"Force_Touch"]) {
        Def_MBProgressStringDelay(@"用力按我吧", 1);
    } else if ([itemAddress isEqualToString:@"ReactNative"]) {
        Def_MBProgressStringDelay(@"敬请期待", 1);
    } else {
        return;
    }
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
