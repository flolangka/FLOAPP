//
//  FLOShareEmotionViewController.m
//  FLOAPP
//
//  Created by 360doc on 2018/3/8.
//  Copyright © 2018年 Flolangka. All rights reserved.
//

#import "FLOShareEmotionViewController.h"
#import "FLOCollectionViewLayout.h"
#import "FLOShareEmotionViewModel.h"
#import "FLOShareEmotionCollectionViewCell.h"

#import <Photos/Photos.h>
#import <WXApi.h>

static NSString *FLOShareEmotionCollectionViewCellID = @"FLOShareEmotionCollectionViewCellID";

@interface FLOShareEmotionViewController ()<UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

{
    PHFetchResult<PHAsset *> *assets;
    
    FLOShareEmotionViewModel *viewModel;
    
    UICollectionView *collectionV;
    float itemWidth;
    BOOL sortAscending;
}

@end

@implementation FLOShareEmotionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"分享到微信";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon_sort"] style:UIBarButtonItemStyleDone target:self action:@selector(sortAction:)];
    
    //默认时间降序
    sortAscending = NO;
    
    //获取数据
    [self getImages];
    
    //初始化collectionV
    [self initCollectionView];
}

- (void)sortAction:(id)sender {
    sortAscending = !sortAscending;
    [collectionV reloadData];
}

- (void)initCollectionView {
    viewModel = [[FLOShareEmotionViewModel alloc] init];
    
    // CollectionView布局样式
    CGFloat maxWidth = 100;
    CGFloat space = 5;
    int num = 3;
    do {
        itemWidth = (MYAPPConfig.screenWidth - (num+1)*space)/(float)num;
        num += 1;
    } while (itemWidth > maxWidth);
    
    FLOCollectionViewLayout *layout = [[FLOCollectionViewLayout alloc] init];
    layout.numberOfColum = num - 1;
    layout.horizontalSpace = space;
    layout.verticalSpace = space;
    
    float itemHeight = itemWidth;
    layout.itemHeight = ^CGFloat(NSIndexPath *indexPath){
        return itemHeight;
    };
    
    collectionV = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, MYAPPConfig.screenWidth, MYAPPConfig.screenHeight-64) collectionViewLayout:layout];
    collectionV.backgroundColor = [UIColor clearColor];
    collectionV.dataSource = self;
    collectionV.delegate = self;
    [collectionV registerClass:[FLOShareEmotionCollectionViewCell class] forCellWithReuseIdentifier:FLOShareEmotionCollectionViewCellID];
    [self.view addSubview:collectionV];
}

- (void)getImages {
    // 获得相机胶卷
    PHAssetCollection *cameraRoll = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeSmartAlbumUserLibrary options:nil].lastObject;
    assets = [PHAsset fetchAssetsInAssetCollection:cameraRoll options:nil];
}

#pragma mark - CollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return assets.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    FLOShareEmotionCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:FLOShareEmotionCollectionViewCellID forIndexPath:indexPath];
    
    PHAsset *asset = [self assetAtIndexPath:indexPath];
    [viewModel configCell:cell model:asset];
    
    return cell;
}

- (PHAsset *)assetAtIndexPath:(NSIndexPath *)indexPath {
    if (sortAscending) {
        return [assets objectAtIndex:indexPath.item];
    } else {
        return [assets objectAtIndex:assets.count-indexPath.item-1];
    }
}

#pragma mark --UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    PHAsset *asset = [self assetAtIndexPath:indexPath];
    
    if (asset.mediaType == PHAssetMediaTypeVideo) {
        Def_MBProgressString(@"暂不支持视频");
    } else if (asset.mediaType == PHAssetMediaTypeAudio) {
        Def_MBProgressString(@"暂不支持音频");
    } else if (asset.mediaType == PHAssetMediaTypeUnknown) {
        Def_MBProgressString(@"暂不支持该格式");
    } else {
        if (![WXApi isWXAppInstalled]) {
            FLOWeakObj(asset);
            [[PHImageManager defaultManager] requestImageDataForAsset:asset options:nil resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
                DLog(@"%@\n%@\n%ld, (%lu, %lu)", dataUTI, info, (long)imageData.length, weakasset.pixelWidth, weakasset.pixelHeight);
                return ;
                
                /*
                //微信表情数据
                WXEmoticonObject *emoji = [WXEmoticonObject object];
                emoji.emoticonData = imageData;     //大小不能超过10M
                
                //微信消息数据
                WXMediaMessage *message = [WXMediaMessage message];
                message.title = @"表情";
                message.mediaObject = emoji;
                
                //发送微信消息
                SendMessageToWXReq *req = [[SendMessageToWXReq alloc] init];
                req.message = message;
                req.bText = NO;
                req.scene = WXSceneSession;
                [WXApi sendReq:req];
                 */
            }];
        }
    }
}

@end
