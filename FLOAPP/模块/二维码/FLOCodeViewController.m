//
//  FLOCodeViewController.m
//  XMPPChat
//
//  Created by admin on 15/12/18.
//  Copyright © 2015年 Flolangka. All rights reserved.
//

#import "FLOCodeViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "FLOCodeResultViewController.h"

@interface FLOCodeViewController ()<AVCaptureMetadataOutputObjectsDelegate>

@property (nonatomic, strong)UIImageView *animationView;
@property (nonatomic, strong)NSTimer *timer;
@property (nonatomic, strong)UIImageView *moveAnimationView;

@property (nonatomic, strong) AVCaptureDevice *captureDevice;
@property (nonatomic, strong) AVCaptureSession *captureSession;

@property (nonatomic, strong) UIButton *lightBtn;

@end

@implementation FLOCodeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    self.title = @"扫一扫";
    
    //添加一个图片qrcode_border
    UIImage *image = [UIImage imageNamed:@"qrcode_border"];
    //用图片的中心拉伸
    image = [image resizableImageWithCapInsets:UIEdgeInsetsMake(25, 25, 26, 26)];
    CGSize size = [UIScreen mainScreen].bounds.size;
    self.animationView = [[UIImageView alloc] initWithFrame:CGRectMake(size.width/2-120, ((size.height-64)/2-120)*0.8, 240, 240)];
    [self.animationView setImage:image];
    [self.view addSubview:_animationView];
    
    [self configReadingSession];
    
    //扫描线
    self.moveAnimationView = [[UIImageView alloc] initWithFrame:CGRectMake(0, -5, 240, 5)];
    [_moveAnimationView setImage:[UIImage imageNamed:@"qrcode_scan_light_green"]];
    _animationView.clipsToBounds = YES;
    [_animationView addSubview:self.moveAnimationView];
    
    //灯光开关
    self.lightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _lightBtn.frame = CGRectMake(size.width/2-25, size.height-80-64, 50, 50./130*174);
    _lightBtn.backgroundColor = [UIColor clearColor];
    [_lightBtn setImage:[UIImage imageNamed:@"qrcode_scan_btn_flash_nor"] forState:UIControlStateNormal];
    [_lightBtn setImage:[UIImage imageNamed:@"qrcode_scan_btn_scan_off"] forState:UIControlStateSelected];
    [_lightBtn addTarget:self action:@selector(lightBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    _lightBtn.selected = NO;
    [self.view addSubview:_lightBtn];
    
    //构造timer，移动视图，产生动画
    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.02f target:self selector:@selector(moveView) userInfo:nil repeats:YES];
    _timer.fireDate = [NSDate distantFuture];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    [_captureSession startRunning];
    _timer.fireDate = [NSDate date];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    _lightBtn.selected = NO;
    [_captureSession stopRunning];
    [_timer invalidate];
    _timer = nil;
}

#pragma mark - 闪光灯开关
- (void)lightBtnAction:(UIButton *)sender
{
    sender.selected = !sender.selected;
    
    if (sender.selected) {
        [self openTorch:YES];
    } else {
        [self openTorch:NO];
    }
}

- (void)openTorch:(BOOL)parameters
{
    AVCaptureTorchMode torchMode = parameters ? AVCaptureTorchModeOn : AVCaptureTorchModeOff;
    [self.captureSession beginConfiguration];
    [self.captureDevice lockForConfiguration:nil];
    [self.captureDevice setTorchMode:torchMode];
    [self.captureDevice unlockForConfiguration];
    [self.captureSession commitConfiguration];
}

#pragma mark - 扫描条滚动
-(void)moveView{
    self.moveAnimationView.frame = CGRectOffset(self.moveAnimationView.frame, 0, 1);
    if (self.moveAnimationView.frame.origin.y >= self.animationView.frame.size.height) {
        CGRect frame = self.moveAnimationView.frame;
        frame.origin.y = -5;
        self.moveAnimationView.frame = frame;
    }
}

- (BOOL)configReadingSession
{
    // 获取 AVCaptureDevice 实例
    NSError * error;
    self.captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    // 初始化输入流
    
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:_captureDevice error:&error];
    if (!input) {
        DLog(@"%@", [error localizedDescription]);
        return NO;
    }
    
    // 初始化输出流
    AVCaptureMetadataOutput *captureMetadataOutput = [[AVCaptureMetadataOutput alloc] init];
    [captureMetadataOutput setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    
    CGSize size = [UIScreen mainScreen].bounds.size;
    CGFloat screenWidth = size.width;
    CGFloat screenHeight = size.height;
    //设置outPut的采集区域
    [captureMetadataOutput setRectOfInterest:CGRectMake((size.height-64-240)*0.4/ screenHeight ,(( screenWidth - 240 )/ 2)/ screenWidth , 240 / screenHeight , 240 / screenWidth )];

    // 创建会话
    _captureSession = [[AVCaptureSession alloc] init];
    [_captureSession setSessionPreset:AVCaptureSessionPresetHigh];
    [_captureSession addInput:input];
    [_captureSession addOutput:captureMetadataOutput];
    //在session添加output后才能设置type
    captureMetadataOutput.metadataObjectTypes = @[AVMetadataObjectTypeQRCode];
    
    // 创建输出对象
    AVCaptureVideoPreviewLayer *layer = [self maskLayer];
    [self.view.layer insertSublayer:layer atIndex:0];
    
    return YES;
}

#pragma mark - masklayer
- (AVCaptureVideoPreviewLayer *)maskLayer
{
    //初始化一个预览layer
    AVCaptureVideoPreviewLayer *layer = [AVCaptureVideoPreviewLayer layerWithSession:_captureSession];
    [layer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    CGSize size = [UIScreen mainScreen].bounds.size;
    [layer setFrame:CGRectMake(0, 0, size.width, size.height)];
    
    //构造图片
    UIGraphicsBeginImageContextWithOptions(self.view.frame.size, NO, [UIScreen mainScreen].scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    //整体是半透明
    CGContextSetRGBFillColor(context, 0, 0, 0, .3f);
    CGContextAddRect(context, self.view.bounds);
    CGContextFillPath(context);
    //中间不透明区域
    CGContextSetRGBFillColor(context, 1, 1, 1, 1);
    CGContextAddRect(context, CGRectMake(size.width/2-120, ((size.height-64)/2-120)*0.8, 240, 240));
    CGContextFillPath(context);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    CGContextRelease(context);
    
    CALayer *maskLayer = [[CALayer alloc] init];
    maskLayer.bounds = self.view.bounds;
    maskLayer.position = self.view.center;
    maskLayer.contents = (__bridge id)(image.CGImage);
    layer.mask = maskLayer;
    
    return layer;
}

#pragma mark - delegate
-(void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection{
    if (metadataObjects != nil && [metadataObjects count] > 0) {
        [_captureSession stopRunning];
        _timer.fireDate = [NSDate distantFuture];
        
        AVMetadataMachineReadableCodeObject *metadataObj = [metadataObjects objectAtIndex:0];
        NSString *result;
        if ([[metadataObj type] isEqualToString:AVMetadataObjectTypeQRCode]) {
            result = metadataObj.stringValue;
            
            FLOCodeResultViewController *codeResultVC = [[FLOCodeResultViewController alloc] init];
            codeResultVC.codeResultStr = result;
            [self.navigationController pushViewController:codeResultVC animated:YES];
        } else {
            DLog(@"不是二维码");
        }
    }
}

- (void)dealloc
{
    _captureSession = nil;
    [_timer invalidate];
}

@end
