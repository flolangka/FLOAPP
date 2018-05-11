//
//  FLOCollectionViewLayout.m
//  FLOAPP
//
//  Created by 360doc on 2017/1/5.
//  Copyright © 2017年 Flolangka. All rights reserved.
//

#import "FLOCollectionViewLayout.h"

@interface FLOCollectionViewLayout ()

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
    
    CGFloat itemWidth = (DEVICE_SCREEN_WIDTH-(_numberOfColum+1)*_horizontalSpace)/(float)_numberOfColum;
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
        
        x = _horizontalSpace + currentColum * (itemWidth+_horizontalSpace);
        y = _verticalSpace + [maxYOfColums[currentColum] floatValue];
        
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
