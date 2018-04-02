//
//  FLOShareEmotionViewModel.h
//  FLOAPP
//
//  Created by 360doc on 2018/3/12.
//  Copyright © 2018年 Flolangka. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PHAsset;
@class FLOShareEmotionCollectionViewCell;

@interface FLOShareEmotionViewModel : NSObject

- (void)configCell:(FLOShareEmotionCollectionViewCell *)cell model:(PHAsset *)asset;

@end
