//
//  FLOMainCollectionViewLayout.m
//  FLOAPP
//
//  Created by 360doc on 2018/5/22.
//  Copyright © 2018年 Flolangka. All rights reserved.
//

#import "FLOMainCollectionViewLayout.h"

@implementation FLOMainCollectionViewLayout
{
    NSMutableDictionary<NSIndexPath *,UICollectionViewLayoutAttributes *> *_layoutAttributes;
    CGSize _contentSize;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self commonInit];
    }
    return self;
}

#pragma mark - public methods
- (NSInteger)numberOfPages {
    NSUInteger numberOfLinesPerPage = [self numberOfLinesPerPage];
    NSUInteger numberOfItemsPerPage = _numberOfColumnsPerPage * numberOfLinesPerPage;
    
    NSUInteger number = [self.collectionView numberOfItemsInSection:0];
    
    return ceilf(number / (float)numberOfItemsPerPage);
}

#pragma mark - private methods
- (void)commonInit {
    _itemSize = CGSizeMake(40, 40);
    _contentInsets = UIEdgeInsetsZero;
    _numberOfColumnsPerPage = 2;
    _fixedLineSpacing = 20;
    _layoutAttributes = [NSMutableDictionary dictionary];
}

- (NSUInteger)numberOfLinesPerPage {
    CGFloat collectionViewHeight = CGRectGetHeight(self.collectionView.bounds);
    CGFloat itemHeight = _itemSize.height;
    
    NSInteger numberOfLinesPerPage = 2;
    float height = (itemHeight + _fixedLineSpacing) * numberOfLinesPerPage;
    while (height < collectionViewHeight - _contentInsets.top - _contentInsets.bottom) {
        numberOfLinesPerPage += 1;
        height = (itemHeight + _fixedLineSpacing) * numberOfLinesPerPage;
    }
    numberOfLinesPerPage -= 1;
    
    return numberOfLinesPerPage;
}

#pragma mark - custom UICollectionViewLayout methods
- (void)prepareLayout {
    [super prepareLayout];
    //clean up
    [_layoutAttributes removeAllObjects];
    _contentSize = CGSizeZero;
    //caculate attibutes
    CGFloat collectionViewWidth = CGRectGetWidth(self.collectionView.bounds);
    CGFloat collectionViewHeight = CGRectGetHeight(self.collectionView.bounds);
    
    CGFloat itemWidth = _itemSize.width;
    CGFloat itemHeight = _itemSize.height;    
    
    NSAssert([self.collectionView numberOfSections] == 1, @"number of sections should equal to 1.");
    
    CGFloat columnSpacing = _numberOfColumnsPerPage == 1 ? 0.0 : (collectionViewWidth - _contentInsets.left - _contentInsets.right - _numberOfColumnsPerPage * itemWidth) / (_numberOfColumnsPerPage + 1);
    
    NSUInteger numberOfLinesPerPage = [self numberOfLinesPerPage];
    NSUInteger numberOfItemsPerPage = _numberOfColumnsPerPage * numberOfLinesPerPage;
    
    NSUInteger numberOfRows = [self.collectionView numberOfItemsInSection:0];
    for (NSUInteger row = 0; row < numberOfRows; row++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
        NSUInteger currentPage = floor(row / numberOfItemsPerPage);
        NSUInteger currentItemOnPageIndex = (row % numberOfItemsPerPage);
        //
        CGFloat originX = _contentInsets.left + columnSpacing + (row % _numberOfColumnsPerPage) * (columnSpacing + itemWidth) + currentPage * collectionViewWidth;
        CGFloat originY = _contentInsets.top + (currentItemOnPageIndex / _numberOfColumnsPerPage) * (_fixedLineSpacing + itemHeight);
        
        // all attributes
        UICollectionViewLayoutAttributes *attributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
        attributes.size = CGSizeMake(itemWidth, itemHeight);
        attributes.frame = CGRectMake(originX, originY, itemWidth, itemHeight);
        _layoutAttributes[indexPath] = attributes;
    }
    
    // content size
    NSUInteger pages = ceil(numberOfRows / (1.0 * numberOfItemsPerPage));
    _contentSize = CGSizeMake(collectionViewWidth * pages, collectionViewHeight);
}
- (CGSize)collectionViewContentSize {
    return _contentSize;
}
- (NSArray<UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect {
    NSArray *attributes = [_layoutAttributes.allValues filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(UICollectionViewLayoutAttributes *  _Nullable evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
        if (CGRectIntersectsRect(rect, evaluatedObject.frame)) {
            return YES;
        }
        return NO;
    }]];
    return attributes;
}
- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
    return _layoutAttributes[indexPath];
}

@end
