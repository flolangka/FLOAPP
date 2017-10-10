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
    NSMutableArray *dataArr_gifImageData;
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
    dataArr_gifImageData = [NSMutableArray arrayWithCapacity:42];
    
    //初始化collectionV
    collectionV = [[UICollectionView alloc] initWithFrame:CGRectMake(5, 0, DEVICE_SCREEN_WIDTH-10, DEVICE_SCREEN_HEIGHT-64) collectionViewLayout:[UICollectionViewFlowLayout new]];
    collectionV.backgroundColor = [UIColor whiteColor];
    collectionV.dataSource = self;
    collectionV.delegate = self;
    [collectionV registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"cellId"];
    [self.view addSubview:collectionV];
    
    //获取数据
    [self getOriginalImages];
}

- (void)getOriginalImages
{
    /*  与相机胶卷重复
    // 获得所有的自定义相簿
    PHFetchResult<PHAssetCollection *> *assetCollections = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
    // 遍历所有的自定义相簿
    for (PHAssetCollection *assetCollection in assetCollections) {
        [self enumerateAssetsInAssetCollection:assetCollection original:YES];
    }
     */
    
    // 获得相机胶卷
    PHAssetCollection *cameraRoll = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeSmartAlbumUserLibrary options:nil].lastObject;
    // 遍历相机胶卷,获取大图
    [self enumerateAssetsInAssetCollection:cameraRoll original:YES];
}

- (void)enumerateAssetsInAssetCollection:(PHAssetCollection *)assetCollection original:(BOOL)original
{
    DLog(@"相簿名:%@", assetCollection.localizedTitle);
    
    PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
    
    // 获得某个相簿中的所有PHAsset对象
    PHFetchResult<PHAsset *> *assets = [PHAsset fetchAssetsInAssetCollection:assetCollection options:nil];
    for (PHAsset *asset in assets) {
        // 是否要原图
//        CGSize size = original ? CGSizeMake(asset.pixelWidth, asset.pixelHeight) : CGSizeZero;
        
        // 从asset中获得图片
//        [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:size contentMode:PHImageContentModeDefault options:options resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
//            DLog(@"result>>>>%@", result);
//        }];
        
        [[PHImageManager defaultManager] requestImageDataForAsset:asset options:options resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
            if (dataUTI && [dataUTI isEqualToString:@"com.compuserve.gif"]) {
                [dataArr_gifImageData addObject:imageData];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [collectionV reloadData];
                });
            }
        }];
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
    return dataArr_gifImageData.count;
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
    
    UIImage *gifImage = [UIImage sd_animatedGIFWithData:dataArr_gifImageData[indexPath.item]];
    imageV.image = gifImage;
    
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
        bgControl = [[UIControl alloc] initWithFrame:CGRectMake(0, 0, DEVICE_SCREEN_WIDTH, DEVICE_SCREEN_HEIGHT)];
        bgControl.backgroundColor = [UIColor blackColor];
        
        UITapGestureRecognizer *tapGes1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
        UIPinchGestureRecognizer *pinchGes1 = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchAction:)];
        pinchGes1.delegate = self;        
        [bgControl addGestureRecognizer:tapGes1];
        [bgControl addGestureRecognizer:pinchGes1];
        
        UIImageView *imageV = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, DEVICE_SCREEN_WIDTH, DEVICE_SCREEN_HEIGHT)];
        imageV.tag = 1000;
        imageV.userInteractionEnabled = YES;
        [bgControl addSubview:imageV];
        
        UITapGestureRecognizer *tapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
        UIPinchGestureRecognizer *pinchGes = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchAction:)];
        pinchGes.delegate = self;
        [imageV addGestureRecognizer:tapGes];
        [imageV addGestureRecognizer:pinchGes];
    }
    
    UIImageView *imageV = [bgControl viewWithTag:1000];
    UIImage *gifImage = [UIImage sd_animatedGIFWithData:dataArr_gifImageData[indexPath.item]];
    
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
    return CGSizeMake((DEVICE_SCREEN_WIDTH-20)/3., (DEVICE_SCREEN_WIDTH-20)/3.+5);
}

@end
