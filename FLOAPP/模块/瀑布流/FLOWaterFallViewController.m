//
//  FLOWaterFallViewController.m
//  FLOAPP
//
//  Created by 沈敏 on 2016/12/28.
//  Copyright © 2016年 Flolangka. All rights reserved.
//

#import "FLOWaterFallViewController.h"
#import <MJRefresh.h>
#import <Photos/Photos.h>
#import "UIImage+FLOUtil.h"
#import "FLOCollectionViewLayout.h"

@interface FLOWaterFallViewController ()
<UICollectionViewDataSource>

{
    NSMutableArray *dataArray;
    UICollectionView *collectionV;
    
    CGFloat width;
}

@end

@implementation FLOWaterFallViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"相册";

    width = (DEVICE_SCREEN_WIDTH-30) / 2.;
    dataArray = [NSMutableArray arrayWithCapacity:42];
    
    [self initCollectionView];
    [self bottomRefreshing];
}

- (void)initCollectionView {
    // 瀑布流样式
    FLOCollectionViewLayout *layout = [[FLOCollectionViewLayout alloc] init];
    layout.numberOfColum = 2;
    layout.itemSpace = 10;
    FLOWeakObj(self);
    layout.itemHeight = ^CGFloat(NSIndexPath *indexPath){
        return [weakself itemHeight:indexPath];
    };
    
    collectionV = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, DEVICE_SCREEN_WIDTH, DEVICE_SCREEN_HEIGHT-64) collectionViewLayout:layout];
    collectionV.backgroundColor = [UIColor whiteColor];
    collectionV.dataSource = self;
    [collectionV registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"cellId"];
    [self.view addSubview:collectionV];
    
    collectionV.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(bottomRefreshing)];
}

- (CGFloat)itemHeight:(NSIndexPath *)indexPath {
    UIImage *image = [dataArray objectAtIndex:indexPath.item];
    return image.size.height * width / image.size.width;
}

- (void)bottomRefreshing {
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        PHAssetCollection *cameraRoll = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeSmartAlbumUserLibrary options:nil].lastObject;
        
        PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
        
        // 获得某个相簿中的所有PHAsset对象
        PHFetchResult<PHAsset *> *assets = [PHAsset fetchAssetsInAssetCollection:cameraRoll options:nil];
        
        NSUInteger loc = dataArray.count;
        NSUInteger len = MIN(assets.count-loc, 20);
        
        if (len == 0) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [collectionV.mj_footer endRefreshingWithNoMoreData];
            });
        } else {
            NSArray *getArray = [assets objectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(loc, len)]];
            
            NSMutableArray *muArr = [NSMutableArray arrayWithCapacity:len];
            for (PHAsset *asset in getArray) {
                [[PHImageManager defaultManager] requestImageDataForAsset:asset options:options resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
                    UIImage *image = [UIImage imageWithData:imageData];
                    [muArr addObject:[image flo_scaleToSize:CGSizeMake(width, image.size.height * width / image.size.width)]];
                    
                    if ([getArray indexOfObject:asset] == getArray.count-1) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [collectionV.mj_footer endRefreshing];
                            
                            [dataArray addObjectsFromArray:muArr];
                            [collectionV reloadData];
                        });
                    }
                }];
            }
        }
    });
}

#pragma mark - CollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return dataArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cellId" forIndexPath:indexPath];
    
    UIImage *image = [dataArray objectAtIndex:indexPath.item];
    
    UIImageView *imageV = [cell.contentView viewWithTag:4444];
    if (!imageV) {
        imageV = [[UIImageView alloc] init];
        imageV.tag = 4444;
        [cell.contentView addSubview:imageV];
    }
    imageV.frame = CGRectMake(0, 0, width, image.size.height * width / image.size.width);
    imageV.image = image;
    
    return cell;
}

@end

