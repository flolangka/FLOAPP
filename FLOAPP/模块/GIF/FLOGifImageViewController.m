//
//  FLOGifImageViewController.m
//  XMPPChat
//
//  Created by 360doc on 16/8/26.
//  Copyright © 2016年 Flolangka. All rights reserved.
//

#import "FLOGifImageViewController.h"
#import <Photos/Photos.h>
#import <SDWebImage/UIImage+GIF.h>

@interface FLOGifImageViewController ()<UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIGestureRecognizerDelegate>

{
    NSMutableArray *dataArr_gifAsset;
    UICollectionView *collectionV;
    
    UIControl *bgControl;
}

@end

@implementation FLOGifImageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"Gif";
    
    //获取相册中的gif图片
    dataArr_gifAsset = [NSMutableArray arrayWithCapacity:42];
    
    //初始化collectionV
    collectionV = [[UICollectionView alloc] initWithFrame:CGRectMake(5, 0, MYAPPConfig.screenWidth-10, MYAPPConfig.screenHeight-64) collectionViewLayout:[UICollectionViewFlowLayout new]];
    collectionV.backgroundColor = [UIColor whiteColor];
    collectionV.dataSource = self;
    collectionV.delegate = self;
    [collectionV registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"cellId"];
    [self.view addSubview:collectionV];
    
    //获取数据
    [self getOriginalImages];
}

- (void)getOriginalImages {
    // 获得相机胶卷
    PHAssetCollection *cameraRoll = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeSmartAlbumUserLibrary options:nil].lastObject;
    
    // 遍历相机胶卷,获取大图
    PHFetchResult<PHAsset *> *assets = [PHAsset fetchAssetsInAssetCollection:cameraRoll options:nil];
    for (PHAsset *asset in assets) {
        
        //com.compuserve.gif
        NSString *uniformType = [asset valueForKey:@"uniformTypeIdentifier"] ? : @"";
        if ([uniformType hasSuffix:@"gif"]) {
            [dataArr_gifAsset addObject:asset];
        }
    }
}

#pragma mark - 手势
- (void)tapAction:(id)sender {
    UIImageView *imageV = [bgControl viewWithTag:1000];
    imageV.image = nil;
    
    [bgControl removeFromSuperview];
}

- (void)pinchAction:(UIPinchGestureRecognizer *)recognizer {
    if (recognizer.state==UIGestureRecognizerStateBegan || recognizer.state==UIGestureRecognizerStateChanged) {
        
        UIImageView *imageV = [bgControl viewWithTag:1000];
        imageV.transform=CGAffineTransformScale(imageV.transform, recognizer.scale, recognizer.scale);
        
        recognizer.scale=1;
    }
}

#pragma mark - CollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return dataArr_gifAsset.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cellId" forIndexPath:indexPath];
    
    UIImageView *imageV = [cell.contentView viewWithTag:1111];
    if (!imageV) {
        imageV = [[UIImageView alloc] initWithFrame:CGRectMake(0, 5, CGRectGetWidth(cell.bounds), CGRectGetHeight(cell.bounds)-5)];
        imageV.tag = 1111;
        [cell.contentView addSubview:imageV];
    }
    FLOWeakObj(imageV);
    
    PHAsset *asset = dataArr_gifAsset[indexPath.item];
    
    //通过PHAsset获取imageData
    [[PHImageManager defaultManager] requestImageDataForAsset:asset options:nil resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
        UIImage *gifImage = [UIImage sd_animatedGIFWithData:imageData];
        weakimageV.image = gifImage;
    }];
    
    return cell;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

#pragma mark --UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (!bgControl) {
        bgControl = [[UIControl alloc] initWithFrame:CGRectMake(0, 0, MYAPPConfig.screenWidth, MYAPPConfig.screenHeight)];
        bgControl.backgroundColor = [UIColor blackColor];
        
        UITapGestureRecognizer *tapGes1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
        UIPinchGestureRecognizer *pinchGes1 = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchAction:)];
        pinchGes1.delegate = self;        
        [bgControl addGestureRecognizer:tapGes1];
        [bgControl addGestureRecognizer:pinchGes1];
        
        UIImageView *imageV = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, MYAPPConfig.screenWidth, MYAPPConfig.screenHeight)];
        imageV.tag = 1000;
        imageV.userInteractionEnabled = YES;
        [bgControl addSubview:imageV];
        
        UITapGestureRecognizer *tapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
        UIPinchGestureRecognizer *pinchGes = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchAction:)];
        pinchGes.delegate = self;
        [imageV addGestureRecognizer:tapGes];
        [imageV addGestureRecognizer:pinchGes];
    }
    
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    UIImageView *cellImageV = [cell.contentView viewWithTag:1111];
    UIImage *gifImage = cellImageV.image;
    
    UIImageView *imageV = [bgControl viewWithTag:1000];
    CGRect imageVFrame = imageV.frame;
    imageVFrame.size.width = gifImage.size.width;
    imageVFrame.size.height = gifImage.size.height;
    imageV.frame = imageVFrame;
    imageV.center = bgControl.center;
    
    imageV.image = gifImage;
    
    [[UIApplication sharedApplication].keyWindow addSubview:bgControl];
}

#pragma mark - UICollectionViewLayout
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 5;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 5;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake((MYAPPConfig.screenWidth-20)/3., (MYAPPConfig.screenWidth-20)/3.+5);
}

@end
