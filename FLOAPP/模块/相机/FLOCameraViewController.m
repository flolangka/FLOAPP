//
//  FLOCameraViewController.m
//  FLOAPP
//
//  Created by 360doc on 2018/4/23.
//  Copyright © 2018年 Flolangka. All rights reserved.
//

#import "FLOCameraViewController.h"
#import "UIImage+FLOUtil.h"

#import <Masonry.h>
#import <AVFoundation/AVFoundation.h>

@interface FLOCameraViewController ()

@property (nonatomic, strong) UIButton *lightBtn;

@property (nonatomic, strong) AVCaptureDevice *captureDevice;
@property (nonatomic, strong) AVCaptureSession *captureSession;
@property (nonatomic, strong) AVCaptureDeviceInput *input;
@property (nonatomic ,strong) AVCaptureStillImageOutput *imageOutput;

@end

NSInteger FLOCameraViewControllerMaskViewTag = 4444;

@implementation FLOCameraViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self configToolBar];
    [self configCaptureBtn];
    [self configReadingSession];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [_captureSession startRunning];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [_captureSession stopRunning];
}

#pragma mark - 隐藏状态栏
- (BOOL)prefersStatusBarHidden {
    return YES;
}

#pragma mark - toolBar
- (void)configToolBar {
    UIView *toolBar = [[UIView alloc] init];
    
    //延时拍照
    UIButton *delayBtn = ({
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        NSAttributedString *str = [[NSAttributedString alloc] initWithString:@"3s" attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:18], NSForegroundColorAttributeName: COLOR_RGB3SAME(255)}];
        [btn setAttributedTitle:str forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(delayBtnAction:) forControlEvents:UIControlEventTouchUpInside];
        btn;
    });
        
    //闪光灯
    UIButton *lightBtn = ({
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.tintColor = COLOR_RGB3SAME(255);
        [btn setImage:[[UIImage imageNamed:@"camera_flashlight"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
        [btn setImage:[[UIImage imageNamed:@"camera_flashlight_open"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateSelected];
        [btn addTarget:self action:@selector(lightBtnAction:) forControlEvents:UIControlEventTouchUpInside];
        @weakify(self);
        [RACObserve(btn, selected) subscribeNext:^(NSNumber *selected) {
            @strongify(self);
            [self openTorch:selected.boolValue];
        }];
        btn;
    });
    
    //切换摄像头
    UIButton *changeBtn = ({
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.tintColor = COLOR_RGB3SAME(255);
        [btn setImage:[[UIImage imageNamed:@"camera_overturn"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(changeCamera:) forControlEvents:UIControlEventTouchUpInside];
        btn;
    });
    
    //退出
    UIButton *closeBtn = ({
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setImage:[UIImage imageNamed:@"icon_smallapp_close"] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(closeAction:) forControlEvents:UIControlEventTouchUpInside];
        btn;
    });
    
    NSArray *arr = @[delayBtn, lightBtn, changeBtn, closeBtn];
    for (int i = 0; i < arr.count; i++) {
        UIButton *btn = [arr objectAtIndex:i];
        btn.frame = CGRectMake(1 + 43*i + 5, 0, 32, 32);
        [toolBar addSubview:btn];
        
        //间隔
        if (i < arr.count-1) {
            UIView *space = [[UIView alloc] initWithFrame:CGRectMake(43*(i+1), 5, 1, 22)];
            space.backgroundColor = COLOR_HEXAlpha(0xffffff, 0.8);
            [toolBar addSubview:space];
        }
    }
    toolBar.frame = CGRectMake(MYAPPConfig.screenWidth-(1 + 43*arr.count)-10, MYAPPConfig.statusBarHeight, 1 + 43*arr.count, 32);
    toolBar.layer.cornerRadius = 32/2.;
    toolBar.layer.masksToBounds = YES;
    toolBar.layer.borderWidth = 1;
    toolBar.layer.borderColor = COLOR_HEXAlpha(0x000000, 0.3).CGColor;
    toolBar.backgroundColor = COLOR_HEXAlpha(0xffffff, 0.3);
    
    [self.view addSubview:toolBar];
}

- (void)delayBtnAction:(id)sender {
    //模拟锁屏
    UIView *maskView = [[UIView alloc] initWithFrame:self.view.bounds];
    maskView.backgroundColor = COLOR_RGB3SAME(0);
    maskView.tag = FLOCameraViewControllerMaskViewTag;
    [self.view addSubview:maskView];
    
    //3秒后自动拍照
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self captureAction:nil];
    });
    
    //4秒后可以点击恢复界面
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [maskView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(maskViewTapGesture:)]];
    });
}

- (void)maskViewTapGesture:(UITapGestureRecognizer *)sender {
    if (sender && sender.view) {
        [sender.view removeFromSuperview];
    }
}

- (void)lightBtnAction:(UIButton *)sender {
    sender.selected = !sender.selected;
}

- (void)closeAction:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

#pragma mark - 拍照按钮
- (void)configCaptureBtn {
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.view addSubview:btn];
    [btn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.bottom.equalTo(self.view).offset(-40);
        make.size.mas_equalTo(CGSizeMake(60, 60));
    }];
    [btn setImage:[UIImage imageNamed:@"compose_color_red_select"] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(captureAction:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)captureAction:(id)sender {
    AVCaptureConnection *conntion = [self.imageOutput connectionWithMediaType:AVMediaTypeVideo];
    if (conntion) {
        FLOWeakObj(self);
        [self.imageOutput captureStillImageAsynchronouslyFromConnection:conntion completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
            if (imageDataSampleBuffer == nil) {
                return ;
            }
            NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
            [weakself getImageData:imageData];
        }];
    } else {
        DLog(@"拍照失败!");
    }
}

- (void)getImageData:(NSData *)imgData {
    //3:4
    UIImage *image = [UIImage imageWithData:imgData];
    image = [image fixOrientation];
    
    //to 9:16
    CGFloat width = 9/16. * image.size.height;
    CGFloat height = image.size.height;
    CGRect rect = CGRectMake((image.size.width-width)/2., 0, width, height);
    
    //裁剪
    CGImageRef subImageRef = CGImageCreateWithImageInRect(image.CGImage, rect);
    UIImage *smallImage = [UIImage imageWithCGImage:subImageRef];
    CGImageRelease(subImageRef);
    
    //显示照片
    if (![self.view viewWithTag:FLOCameraViewControllerMaskViewTag]) {
        [self flo_showCurtImage:smallImage time:1.5 hideAnimated:YES];
    }
    
    //保存到相册
    UIImageWriteToSavedPhotosAlbum(smallImage, nil, nil, nil);
}

#pragma mark - 配置
- (BOOL)configReadingSession {
    // 获取 AVCaptureDevice 实例
    _captureDevice = [self cameraWithPosition:AVCaptureDevicePositionBack];
    
    // 初始化输入流
    _input = [AVCaptureDeviceInput deviceInputWithDevice:_captureDevice error:nil];
    if (!_input) {
        return NO;
    }
    
    // 初始化输出流
    self.imageOutput = [[AVCaptureStillImageOutput alloc] init];
    
    // 创建会话
    _captureSession = [[AVCaptureSession alloc] init];
    [_captureSession setSessionPreset:AVCaptureSessionPresetPhoto];
    [_captureSession addInput:_input];
    [_captureSession addOutput:_imageOutput];
    
    // 创建输出对象，输出照片宽高原比例3：4，需要9：16(屏幕宽高比)，只显示中间9:16的区域
    CGFloat layerWidth = 3/4. * MYAPPConfig.screenHeight;
    AVCaptureVideoPreviewLayer *layer = [AVCaptureVideoPreviewLayer layerWithSession:_captureSession];
    [layer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    [layer setFrame:CGRectMake(-(layerWidth-MYAPPConfig.screenWidth)/2., 0, layerWidth, MYAPPConfig.screenHeight)];
    
    [self.view.layer insertSublayer:layer atIndex:0];
    
    return YES;
}

//闪光灯
- (void)openTorch:(BOOL)parameters {
    if (_captureDevice && _captureDevice.position == AVCaptureDevicePositionBack) {
        AVCaptureTorchMode torchMode = parameters ? AVCaptureTorchModeOn : AVCaptureTorchModeOff;
        [self.captureSession beginConfiguration];
        
        [self.captureDevice lockForConfiguration:nil];
        [self.captureDevice setTorchMode:torchMode];
        [self.captureDevice unlockForConfiguration];
        
        [self.captureSession commitConfiguration];
    }
}

//切换摄像头
- (void)changeCamera:(id)sender {
    AVCaptureDevice *newCamera = nil;
    AVCaptureDeviceInput *newInput = nil;
    //拿到另外一个摄像头位置
    AVCaptureDevicePosition position = [_captureDevice position];
    if (position == AVCaptureDevicePositionFront){
        newCamera = [self cameraWithPosition:AVCaptureDevicePositionBack];
    } else {
        newCamera = [self cameraWithPosition:AVCaptureDevicePositionFront];
    }
    
    //生成新的输入
    newInput = [AVCaptureDeviceInput deviceInputWithDevice:newCamera error:nil];
    if (newInput != nil) {
        [self.captureSession beginConfiguration];
        
        [self.captureSession removeInput:_input];
        [self.captureSession addInput:newInput];
        
        [self.captureSession commitConfiguration];
        
        self.input = newInput;
        self.captureDevice = newCamera;
    }
}

- (AVCaptureDevice *)cameraWithPosition:(AVCaptureDevicePosition)position{
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for ( AVCaptureDevice *device in devices )
        if ( device.position == position ){
            return device;
        }
    return nil;
}

@end
