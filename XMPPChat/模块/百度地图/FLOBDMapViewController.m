//
//  FLOBDMapViewController.m
//  XMPPChat
//
//  Created by admin on 15/12/22.
//  Copyright © 2015年 Flolangka. All rights reserved.
//

#import "FLOBDMapViewController.h"
#import <BaiduMapAPI_Map/BMKMapView.h>

@interface FLOBDMapViewController ()<BMKMapViewDelegate>

{
    CGSize size;
}

@property (nonatomic, strong) BMKMapView *mapView;

@end

@implementation FLOBDMapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    size = [UIScreen mainScreen].bounds.size;
    self.mapView = [[BMKMapView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
    self.view = _mapView;
    
    [self configNavigationBar];
}

- (void)configNavigationBar
{
    
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
