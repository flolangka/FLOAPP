//
//  FLOBDMapViewController.m
//  XMPPChat
//
//  Created by admin on 15/12/22.
//  Copyright © 2015年 Flolangka. All rights reserved.
//

#import "FLOBDMapViewController.h"
#import <BaiduMapAPI_Map/BMKMapView.h>
#import <BaiduMapAPI_Location/BMKLocationService.h>
#import <MBProgressHUD.h>

@interface FLOBDMapViewController ()<BMKMapViewDelegate, BMKLocationServiceDelegate, UITextFieldDelegate>

{
    CGSize size;
    UITextField *searchTF;
    NSArray *rightBtns; //右侧功能按钮
    UIImage *normalBGImage;
    UIImage *selectedBGImage; //按钮选中背景图片，imageWithColor
    
    BMKLocationService *locationService;
}

@property (nonatomic, strong) BMKMapView *mapView;

@end

@implementation FLOBDMapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    size = [UIScreen mainScreen].bounds.size;
    self.mapView = [[BMKMapView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
    self.view = _mapView;
    
    _mapView.zoomLevel = 13;
    _mapView.showMapScaleBar = YES; //比例尺
    
    [self configLocationService];
    [self configNavigationBar];
    [self configRightBtns];
    
    [_mapView addObserver:self forKeyPath:@"userTrackingMode" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    if (![keyPath isEqualToString:@"userTrackingMode"]) {
        return;
    }
    UIButton *followHeadingBtn = rightBtns[3];
    if (followHeadingBtn.selected && [change[@"new"] intValue] != BMKUserTrackingModeFollowWithHeading) {
        followHeadingBtn.selected = NO;
    }
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    //横屏后重置frame
}

#pragma mark - locationService
- (void)configLocationService
{
    _mapView.showsUserLocation = NO;
    _mapView.userTrackingMode = BMKUserTrackingModeFollow;
    _mapView.showsUserLocation = YES;
    
    BMKLocationViewDisplayParam *locationVDisplayParam = [[BMKLocationViewDisplayParam alloc] init];
    locationVDisplayParam.isRotateAngleValid = YES;
    locationVDisplayParam.isAccuracyCircleShow = YES;
    locationVDisplayParam.locationViewImgName = @"icon_cellphone.png";
    [_mapView updateLocationViewWithParam:locationVDisplayParam];
    //定位服务
    locationService = [[BMKLocationService alloc] init];
    locationService.headingFilter = 5.;
    locationService.delegate = self;
    [locationService startUserLocationService];
}

#pragma mark - 导航栏
- (void)configNavigationBar
{
    UIView *navigationV = [[UIView alloc] initWithFrame:CGRectMake(0, 20, size.width, 44)];
    
    //按钮
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    backButton.frame = CGRectMake(12, 7, 30, 30);
    backButton.layer.cornerRadius = 15.;
    backButton.clipsToBounds = YES;
    backButton.layer.borderColor = [UIColor groupTableViewBackgroundColor].CGColor;
    backButton.layer.borderWidth = 1.;
    backButton.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.8];
    
    //返回箭头
    CALayer *layer = [[CALayer alloc] init];
    layer.frame = CGRectMake(10, 8, 8, 14);
    layer.contents = (id)[UIImage imageNamed:@"goback"].CGImage;
    [backButton.layer addSublayer:layer];
    
    [backButton addTarget:self action:@selector(goBackAction) forControlEvents:UIControlEventTouchUpInside];
    
    //搜索栏
    searchTF = [[UITextField alloc] initWithFrame:CGRectMake(52, 6, size.width-52-22, 31)];
    searchTF.returnKeyType = UIReturnKeySearch;
    searchTF.placeholder = @"查找地点、公交、地铁";
    searchTF.clearButtonMode = UITextFieldViewModeWhileEditing;
    searchTF.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.8];
    searchTF.borderStyle = UITextBorderStyleRoundedRect;
    searchTF.layer.borderColor = [UIColor groupTableViewBackgroundColor].CGColor;
    searchTF.delegate = self;
    
    [navigationV addSubview:backButton];
    [navigationV addSubview:searchTF];
    [_mapView addSubview:navigationV];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [_mapView viewWillAppear];
    _mapView.delegate = self; // 此处记得不用的时候需要置nil，否则影响内存的释放
    
    //设置指南针位置
    _mapView.overlooking = -30;
    _mapView.compassPosition = CGPointMake(10, 65);
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [locationService stopUserLocationService];
    [_mapView viewWillDisappear];
    _mapView.delegate = nil; // 不用时，置nil
    
    [_mapView removeObserver:self forKeyPath:@"userTrackingMode" context:nil];
}

- (void)goBackAction
{
    [searchTF resignFirstResponder];
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - 搜索栏点击搜索代理
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
#warning 搜索
    
    return YES;
}

#pragma mark - 右侧按钮
- (void)configRightBtns
{
    normalBGImage = [self imageFromColor:[UIColor whiteColor]];
    selectedBGImage = [self imageFromColor:[UIColor colorWithRed:30/255. green:191/255. blue:230/255. alpha:1.0]];
    
    //卫星图
    UIButton *satelliteMapBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [satelliteMapBtn setAttributedTitle:[[NSAttributedString alloc] initWithString:@"卫星图" attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:9], NSForegroundColorAttributeName: [UIColor grayColor]}] forState:UIControlStateNormal];
    [satelliteMapBtn addTarget:self action:@selector(satelliteMapBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    
    //实时路况
    UIButton *trafficBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [trafficBtn setAttributedTitle:[[NSAttributedString alloc] initWithString:@"路况图" attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:9], NSForegroundColorAttributeName: [UIColor grayColor]}] forState:UIControlStateNormal];
    [trafficBtn addTarget:self action:@selector(trafficBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    
    //热力图
    UIButton *heatMapBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [heatMapBtn setAttributedTitle:[[NSAttributedString alloc] initWithString:@"热力图" attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:9], NSForegroundColorAttributeName: [UIColor grayColor]}] forState:UIControlStateNormal];
    [heatMapBtn addTarget:self action:@selector(heatMapBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    
    //罗盘
    UIButton *followHeadingBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [followHeadingBtn setAttributedTitle:[[NSAttributedString alloc] initWithString:@"罗盘" attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:9], NSForegroundColorAttributeName: [UIColor grayColor]}] forState:UIControlStateNormal];
    [followHeadingBtn addTarget:self action:@selector(followHeadingBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    
    //
    
    rightBtns = @[satelliteMapBtn, trafficBtn, heatMapBtn, followHeadingBtn];
    [self layoutRightBtns];
}

- (void)layoutRightBtns
{
    for (int i=0; i < rightBtns.count; i++) {
        UIButton *btn = rightBtns[i];
        [btn setBackgroundImage:normalBGImage forState:UIControlStateNormal];
        [btn setBackgroundImage:selectedBGImage forState:UIControlStateSelected];
        btn.layer.cornerRadius = 8.;
        btn.clipsToBounds = YES;
        btn.layer.borderColor = [UIColor lightGrayColor].CGColor;
        btn.layer.borderWidth = 1.;
        
        btn.frame = CGRectMake(size.width-50, 80+37*i, 35, 27);
        [_mapView addSubview:btn];
    }
}

- (UIImage *)imageFromColor:(UIColor *)color {
    CGRect rect = CGRectMake(0, 0, 1, 1);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

#pragma mark - 右侧按钮事件
//卫星图
- (void)satelliteMapBtnAction:(UIButton *)sender
{
    sender.selected = !sender.selected;
    if (sender.selected) {
        [_mapView setMapType:BMKMapTypeSatellite];
    } else {
        [_mapView setMapType:BMKMapTypeStandard];
    }
}

//路况图
- (void)trafficBtnAction:(UIButton *)sender
{
    sender.selected = !sender.selected;
    if (sender.selected) {
        [_mapView setTrafficEnabled:YES];
    } else {
        [_mapView setTrafficEnabled:NO];
    }
}

//热力图
- (void)heatMapBtnAction:(UIButton *)sender
{
    sender.selected = !sender.selected;
    if (sender.selected) {
        [_mapView setBaiduHeatMapEnabled:YES];
    } else {
        [_mapView setBaiduHeatMapEnabled:NO];
    }
}

//罗盘
- (void)followHeadingBtnAction:(UIButton *)sender
{
    _mapView.showsUserLocation = NO;
    sender.selected = !sender.selected;
    if (sender.selected) {
        //进入罗盘状态
        _mapView.userTrackingMode = BMKUserTrackingModeFollowWithHeading;
    } else {
        _mapView.userTrackingMode = BMKUserTrackingModeFollow;
    }
    _mapView.showsUserLocation = YES;
}

#pragma mark - 右下角放大/缩小按钮
//- (void)config


#pragma mark - 定位服务
//位置更新
- (void)didUpdateBMKUserLocation:(BMKUserLocation *)userLocation
{
    [_mapView updateLocationData:userLocation];
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _mapView.zoomLevel = 18;
        _mapView.overlooking = 0;
        [_mapView setCenterCoordinate:userLocation.location.coordinate animated:YES];
    });
}

//方向更新
- (void)didUpdateUserHeading:(BMKUserLocation *)userLocation
{
    [_mapView updateLocationData:userLocation];
}

//定位失败
- (void)didFailToLocateUserWithError:(NSError *)error
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeText;
    hud.labelText = @"定位失败";
    [hud hide:YES afterDelay:1.0];
}

@end
