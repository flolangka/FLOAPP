//
//  FLOShareEmotionViewModel.m
//  FLOAPP
//
//  Created by 360doc on 2018/3/12.
//  Copyright © 2018年 Flolangka. All rights reserved.
//

#import "FLOShareEmotionViewModel.h"
#import "FLOShareEmotionCollectionViewCell.h"

#import <Photos/Photos.h>

@interface FLOShareEmotionViewModel ()

@property (nonatomic, strong) PHImageRequestOptions *imageRequestOptions;

@end

@implementation FLOShareEmotionViewModel

- (void)configCell:(FLOShareEmotionCollectionViewCell *)cell model:(PHAsset *)asset {
    if (_imageRequestOptions == nil) {
        _imageRequestOptions = [[PHImageRequestOptions alloc] init];
        _imageRequestOptions.deliveryMode = PHImageRequestOptionsDeliveryModeFastFormat; //尽快地提供接近或稍微大于要求的尺寸
        _imageRequestOptions.resizeMode = PHImageRequestOptionsResizeModeFast;   //以最快速度提供好的质量
    }
    
    FLOWeakObj(cell);
    
    //显示缩略图
    if (asset.mediaType == PHAssetMediaTypeImage) {
        //图片
        [[PHImageManager defaultManager] requestImageForAsset:asset
                                                   targetSize:CGSizeMake(100, 100)
                                                  contentMode:PHImageContentModeAspectFill
                                                      options:_imageRequestOptions
                                                resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
                                                    [weakcell image:result];
                                                }];
        
        //com.compuserve.gif
        NSString *uniformType = [asset valueForKey:@"uniformTypeIdentifier"] ? : @"";
        if ([uniformType hasSuffix:@"gif"]) {
            [weakcell gif:YES];
        }
        
        //livePhoto
        [weakcell livePhoto:asset.mediaSubtypes == PHAssetMediaSubtypePhotoLive];
        
        //获取原图大小
        [[PHImageManager defaultManager] requestImageDataForAsset:asset options:nil resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
            NSUInteger length = imageData.length;
            [weakcell sizeStr:[FLOShareEmotionViewModel sizeStr:length]];
        }];
    } else if (asset.mediaType == PHAssetMediaTypeVideo) {
        //视频
        [[PHImageManager defaultManager] requestImageForAsset:asset
                                                   targetSize:CGSizeMake(100, 100)
                                                  contentMode:PHImageContentModeAspectFill
                                                      options:_imageRequestOptions
                                                resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
                                                    [weakcell image:result];
                                                    [weakcell video:YES];
                                                }];
    } else {
        //PHAssetMediaTypeUnknown、PHAssetMediaTypeAudio
        [weakcell image:[UIImage imageNamed:@"image_fail_placeholder"]];
    }
}

+ (NSString *)sizeStr:(NSUInteger)size {
    if (size > 1024 * 1024) {
        return [NSString stringWithFormat:@"%.1f M", size/1024./1024];
    } else if (size > 1024) {
        return [NSString stringWithFormat:@"%.1f K", size/1024.];
    } else {
        return [NSString stringWithFormat:@"%ld b", size];
    }
}

@end
