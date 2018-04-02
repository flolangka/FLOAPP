//
//  FLOShareEmotionCollectionViewCell.h
//  FLOAPP
//
//  Created by 360doc on 2018/3/12.
//  Copyright © 2018年 Flolangka. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FLOShareEmotionCollectionViewCell : UICollectionViewCell

- (void)image:(UIImage *)image;
- (void)sizeStr:(NSString *)str;
- (void)gif:(BOOL)b;
- (void)livePhoto:(BOOL)b;
- (void)video:(BOOL)b;

@end
