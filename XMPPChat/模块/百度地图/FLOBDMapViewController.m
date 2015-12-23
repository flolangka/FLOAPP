//
//  FLOBDMapViewController.m
//  XMPPChat
//
//  Created by admin on 15/12/22.
//  Copyright © 2015年 Flolangka. All rights reserved.
//

#import "FLOBDMapViewController.h"
#import <BaiduMapAPI_Map/BMKMapView.h>

@interface FLOBDMapViewController ()<BMKMapViewDelegate, UITextFieldDelegate>

{
    CGSize size;
    UITextField *searchTF;
    NSArray *rightBtns; //右侧功能按钮
    UIImage *normalBGImage;
    UIImage *selectedBGImage; //按钮选中背景图片，imageWithColor
}

@property (nonatomic, strong) BMKMapView *mapView;

@end

@implementation FLOBDMapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    size = [UIScreen mainScreen].bounds.size;
    self.mapView = [[BMKMapView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
    self.view = _mapView;
    
    _mapView.showMapScaleBar = YES; //比例尺
    
    //仰俯角及指南针定位有问题
    _mapView.overlookEnabled = YES;
    _mapView.compassPosition = CGPointMake(10, 65);
    
    [self configNavigationBar];
    [self configRightBtns];
}

#pragma mark - 导航栏
- (void)configNavigationBar
{
    UIView *navigationV = [[UIView alloc] initWithFrame:CGRectMake(0, 20, size.width, 44)];
    
    //返回按钮
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    backButton.frame = CGRectMake(12, 7, 30, 30);
    backButton.layer.cornerRadius = 15.;
    backButton.clipsToBounds = YES;
    backButton.layer.borderColor = [UIColor groupTableViewBackgroundColor].CGColor;
    backButton.layer.borderWidth = 1.;
    backButton.backgroundColor = [[UIColor groupTableViewBackgroundColor] colorWithAlphaComponent:0.9];
    [backButton setImage:[[UIImage imageNamed:@"goback"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forState:UIControlStateNormal];
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
    [_mapView viewWillAppear];
    _mapView.delegate = self; // 此处记得不用的时候需要置nil，否则影响内存的释放
}
- (void)viewWillDisappear:(BOOL)animated
{
    [_mapView viewWillDisappear];
    _mapView.delegate = nil; // 不用时，置nil
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
    
    //3D建筑
    UIButton *buildingBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [buildingBtn setAttributedTitle:[[NSAttributedString alloc] initWithString:@"3D图" attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:9], NSForegroundColorAttributeName: [UIColor grayColor]}] forState:UIControlStateNormal];
    [buildingBtn addTarget:self action:@selector(buildingBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    
    rightBtns = @[satelliteMapBtn, trafficBtn, heatMapBtn, buildingBtn];
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

//3D建筑图
- (void)buildingBtnAction:(UIButton *)sender
{
    sender.selected = !sender.selected;
    if (sender.selected) {
        [_mapView setBuildingsEnabled:YES];
    } else {
        [_mapView setBuildingsEnabled:NO];
    }
}

#pragma mark - 右下角放大/缩小按钮
//- (void)config


@end
