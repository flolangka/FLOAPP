//
//  FLOBDMapViewController.m
//  XMPPChat
//
//  Created by admin on 15/12/22.
//  Copyright © 2015年 Flolangka. All rights reserved.
//

#import "FLOBDMapViewController.h"
#import <BaiduMapAPI_Location/BMKLocationComponent.h>
#import <BaiduMapAPI_Map/BMKMapComponent.h>
#import <BaiduMapAPI_Search/BMKSearchComponent.h>
#import <BaiduMapAPI_Base/BMKTypes.h>
#import <MBProgressHUD.h>

@interface FLOBDMapViewController ()<BMKMapViewDelegate, BMKLocationServiceDelegate, UITextFieldDelegate, BMKPoiSearchDelegate, BMKRouteSearchDelegate>

{
    CGSize size;
    UITextField *searchTF;
    NSArray *rightBtns; //右侧功能按钮
    UIImage *normalBGImage;
    UIImage *selectedBGImage; //按钮选中背景图片，imageWithColor
    
    BMKLocationService *locationService;
    BMKPoiSearch *poiSearch;
}

@property (nonatomic, strong) BMKMapView *mapView;

@end

@implementation FLOBDMapViewController

- (instancetype)init {
    self = [super init];
    if (self) {
        
        //注册百度地图
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            BMKMapManager *bdManager = [[BMKMapManager alloc]init];
            [bdManager start:@"ZbXFn3fQqGNxn3TYmtqRhUUB" generalDelegate:nil];
        });
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    size = [UIScreen mainScreen].bounds.size;
    self.mapView = [[BMKMapView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
    self.view = _mapView;
    
    _mapView.zoomLevel = 13;
    _mapView.showMapScaleBar = YES; //比例尺
    _mapView.isSelectedAnnotationViewFront = YES;
    
    poiSearch = [[BMKPoiSearch alloc]init];
    
    [self configLocationService];
    [self configNavigationBar];
    [self configRightBtns];
    
    [_mapView addObserver:self forKeyPath:@"userTrackingMode" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)dealloc
{
    [_mapView removeObserver:self forKeyPath:@"userTrackingMode" context:nil];
    
    searchTF.delegate = nil;
    locationService.delegate = nil;
    
    _mapView = nil;
    poiSearch = nil;
    locationService = nil;
}

//监测罗盘是否开启
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
    _mapView.userTrackingMode = BMKUserTrackingModeHeading;
    _mapView.showsUserLocation = YES;
    
    BMKLocationViewDisplayParam *locationVDisplayParam = [[BMKLocationViewDisplayParam alloc] init];
    locationVDisplayParam.isRotateAngleValid = YES;
    locationVDisplayParam.isAccuracyCircleShow = YES;
    locationVDisplayParam.locationViewImgName = @"icon_cellphone.png";
    [_mapView updateLocationViewWithParam:locationVDisplayParam];
    //定位服务
    locationService = [[BMKLocationService alloc] init];
    locationService.headingFilter = 1.;
    locationService.delegate = self;
    [locationService startUserLocationService];
    
    //定位按钮
    UIButton *locationBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    locationBtn.frame = CGRectMake(10, size.height-100, 30, 30);
    [locationBtn setImage:[UIImage imageNamed:@"default_main_gpsnormalbutton_image_normal"] forState:UIControlStateNormal];
    [locationBtn addTarget:self action:@selector(locationBtnAction) forControlEvents:UIControlEventTouchUpInside];
    
    [_mapView addSubview:locationBtn];
}

- (void)locationBtnAction
{
    [self updateMapViewCenterWithCoordinate:locationService.userLocation.location.coordinate];
}

#pragma mark - 导航栏
- (void)configNavigationBar
{
    UIView *navigationV = [[UIView alloc] initWithFrame:CGRectMake(0, MYAPPConfig.statusBarHeight, size.width, 44)];
    
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
    poiSearch.delegate = self;
    
    //设置指南针位置
    _mapView.overlooking = -30;
    _mapView.compassPosition = CGPointMake(10, MYAPPConfig.navigationHeight + 10);
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [locationService stopUserLocationService];
    [_mapView viewWillDisappear];
    _mapView.delegate = nil; // 不用时，置nil
    poiSearch.delegate = nil;
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
    if (textField.text.length < 1) {
        return NO;
    }
    
    BMKNearbySearchOption *searchOption = [[BMKNearbySearchOption alloc] init];
    searchOption.location = locationService.userLocation.location.coordinate;
    searchOption.radius = 3000;
    searchOption.pageCapacity = 20;
    
    searchOption.keyword = textField.text;
    [poiSearch poiSearchNearBy:searchOption];
    
    return YES;
}

#pragma mark implement - BMKMapViewDelegate
/**
 *根据anntation生成对应的View
 *@param mapView 地图View
 *@param annotation 指定的标注
 *@return 生成的标注View
 */
- (BMKAnnotationView *)mapView:(BMKMapView *)view viewForAnnotation:(id <BMKAnnotation>)annotation
{
    // 生成重用标示identifier
    NSString *AnnotationViewID = @"xidanMark";
    
    // 检查是否有重用的缓存
    BMKAnnotationView* annotationView = [view dequeueReusableAnnotationViewWithIdentifier:AnnotationViewID];
    
    // 缓存没有命中，自己构造一个，一般首次添加annotation代码会运行到此处
    if (annotationView == nil) {
        annotationView = [[BMKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:AnnotationViewID];
        ((BMKPinAnnotationView*)annotationView).pinColor = BMKPinAnnotationColorRed;
        // 设置重天上掉下的效果(annotation)
        ((BMKPinAnnotationView*)annotationView).animatesDrop = YES;
    }
    
    // 设置位置
    annotationView.centerOffset = CGPointMake(0, -(annotationView.frame.size.height * 0.5));
    annotationView.annotation = annotation;
    // 单击弹出泡泡，弹出泡泡前提annotation必须实现title属性
    annotationView.canShowCallout = YES;
    // 设置是否可以拖拽
    annotationView.draggable = NO;
    
    return annotationView;
}

- (void)mapView:(BMKMapView *)mapView didSelectAnnotationView:(BMKAnnotationView *)view
{
    [mapView bringSubviewToFront:view];
    [mapView setNeedsDisplay];
}

#pragma mark implement - BMKSearchDelegate
- (void)onGetPoiResult:(BMKPoiSearch *)searcher result:(BMKPoiResult*)result errorCode:(BMKSearchErrorCode)error
{
    // 清楚屏幕中所有的annotation
    NSArray* array = [NSArray arrayWithArray:_mapView.annotations];
    [_mapView removeAnnotations:array];
    
    if (error == BMK_SEARCH_NO_ERROR) {
        NSMutableArray *annotations = [NSMutableArray array];
        for (int i = 0; i < result.poiInfoList.count; i++) {
            BMKPoiInfo* poi = [result.poiInfoList objectAtIndex:i];
            BMKPointAnnotation* item = [[BMKPointAnnotation alloc]init];
            item.coordinate = poi.pt;
            item.title = poi.name;
            [annotations addObject:item];
        }
        [_mapView addAnnotations:annotations];
        [_mapView showAnnotations:annotations animated:YES];
    } else if (error == BMK_SEARCH_AMBIGUOUS_ROURE_ADDR){
        DLog(@"起始点有歧义");
    } else {
        // 各种情况的判断。。。
    }
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
        
        btn.frame = CGRectMake(size.width-50, MYAPPConfig.navigationHeight+20+37*i, 35, 27);
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
        _mapView.userTrackingMode = BMKUserTrackingModeHeading;
    }
    _mapView.showsUserLocation = YES;
}

#pragma mark - 定位服务
//位置更新
- (void)didUpdateBMKUserLocation:(BMKUserLocation *)userLocation
{
    [_mapView updateLocationData:userLocation];
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self updateMapViewCenterWithCoordinate:userLocation.location.coordinate];
    });
}

- (void)updateMapViewCenterWithCoordinate:(CLLocationCoordinate2D)coordinate
{
    _mapView.zoomLevel = 18;
    _mapView.overlooking = 0;
    [_mapView setCenterCoordinate:coordinate animated:YES];
}

//方向更新
- (void)didUpdateUserHeading:(BMKUserLocation *)userLocation
{
    [_mapView updateLocationData:userLocation];
}

//定位失败
- (void)didFailToLocateUserWithError:(NSError *)error
{
    Def_MBProgressStringDelay(@"定位失败", 1);
}

@end
