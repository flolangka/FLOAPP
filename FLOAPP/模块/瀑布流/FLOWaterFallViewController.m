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

@interface FLOCollectionViewLayout : UICollectionViewLayout

// 几列
@property (nonatomic, assign) NSInteger numberOfColum;
// item直接间距
@property (nonatomic, assign) CGFloat itemSpace;
// item高度回调
@property (nonatomic, copy) CGFloat(^itemHeight)(NSIndexPath *);

@end

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
    layout.itemHeight = ^CGFloat(NSIndexPath *indexPath){
        UIImage *image = [dataArray objectAtIndex:indexPath.item];
        return image.size.height * width / image.size.width;
    };
    
    collectionV = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, DEVICE_SCREEN_WIDTH, DEVICE_SCREEN_HEIGHT-64) collectionViewLayout:layout];
    collectionV.backgroundColor = [UIColor whiteColor];
    collectionV.dataSource = self;
    [collectionV registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"cellId"];
    [self.view addSubview:collectionV];
    
    collectionV.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(bottomRefreshing)];
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


#pragma mark - 布局类
@interface FLOCollectionViewLayout()

{
    NSArray <UICollectionViewLayoutAttributes *>*layoutAttributes;
    NSMutableArray *maxYOfColums;
}

@end

@implementation FLOCollectionViewLayout

// 在这个方法里面计算好各个cell的LayoutAttributes 对于瀑布流布局, 只需要更改LayoutAttributes.frame即可
// 在每次collectionView的data(init delete insert reload)变化的时候都会调用这个方法准备布局
- (void)prepareLayout {
    [super prepareLayout];
    
    maxYOfColums = [NSMutableArray arrayWithCapacity:_numberOfColum];
    for (int i = 0; i < _numberOfColum; i++) {
        [maxYOfColums addObject:@(0)];
    }
    
    layoutAttributes = [self layoutAttributes];
}

// Apple建议要重写这个方法, 因为某些情况下(delete insert...)系统可能需要调用这个方法来布局
- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
    return layoutAttributes[indexPath.item];
}

// 必须重写这个方法来返回计算好的LayoutAttributes
- (NSArray<UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect {
    return layoutAttributes;
}

// 返回collectionView的ContentSize -> 滚动范围
- (CGSize)collectionViewContentSize {
    return CGSizeMake(DEVICE_SCREEN_WIDTH, [self max:maxYOfColums]);
}

// 计算所有的UICollectionViewLayoutAttributes
- (NSArray <UICollectionViewLayoutAttributes *>*)layoutAttributes {
    NSInteger totalNums = [[self collectionView] numberOfItemsInSection:0];
    
    CGFloat itemWidth = (DEVICE_SCREEN_WIDTH-(_numberOfColum+1)*_itemSpace)/(float)_numberOfColum;
    CGFloat x = 0;
    CGFloat y = 0;
    CGFloat height = 0;
    NSInteger currentColum = 0;
    NSIndexPath *indexPath;
    NSMutableArray *arr = [NSMutableArray arrayWithCapacity:totalNums];
    
    if (!_itemHeight) {
        return arr;
    }
    
    for (int i = 0; i < totalNums; i++) {
        indexPath = [NSIndexPath indexPathForItem:i inSection:0];
        height = _itemHeight(indexPath);
        
        if (i < _numberOfColum) {
            // 第一行直接添加到当前的列
            currentColum = i;
        } else {
            // 其他行添加到最短的那一列
            NSInteger index = 0;
            
            CGFloat minY = [maxYOfColums[index] floatValue];
            for (int i = 1; i < _numberOfColum; i++) {
                if ([maxYOfColums[i] floatValue] < minY) {
                    minY = [maxYOfColums[i] floatValue];
                    index = i;
                }
            }
            currentColum = index;
        }
        
        x = _itemSpace + currentColum * (itemWidth+_itemSpace);
        y = _itemSpace + [maxYOfColums[currentColum] floatValue];
        
        // 更新该列的height
        [maxYOfColums replaceObjectAtIndex:currentColum withObject:@(y+height)];
        
        // 设置用于瀑布流效果的attributes的frame
        UICollectionViewLayoutAttributes *attributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
        attributes.frame = CGRectMake(x, y, itemWidth, height);
        
        [arr addObject:attributes];
    }
    
    return arr;
}

- (CGFloat)min:(NSArray *)arr {
    CGFloat x = 0;
    for (id value in arr) {
        x = MIN([value floatValue], x);
    }
    return x;
}

- (CGFloat)max:(NSArray *)arr {
    CGFloat x = 0;
    for (id value in arr) {
        x = MAX([value floatValue], x);
    }
    return x;
}

@end
