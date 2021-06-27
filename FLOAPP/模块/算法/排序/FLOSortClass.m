//
//  FLOSortClass.m
//  FLOAPP
//
//  Created by 360doc on 2018/4/27.
//  Copyright © 2018年 Flolangka. All rights reserved.
//

#import "FLOSortClass.h"

@interface FLOSortClass ()

- (void)updateValue:(float)value atIndex:(NSInteger)index;

@end

@implementation FLOSortClass

+ (NSArray *)sortTypes {
    return @[@"冒泡", @"选择", @"插入", @"希尔", @"堆排", @"归并", @"快排", @"基数"];
}

- (void)sort:(NSArray *)arr type:(FLOSortType)type {
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSMutableArray *muArr = [NSMutableArray arrayWithArray:arr];
        
        switch (type) {
            case FLOSortTypeBubble:
                [self BubbleSort:muArr];
                break;
            case FLOSortTypeSelect:
                [self SelectSort:muArr];
                break;
            case FLOSortTypeInsert:
                [self InsertSort:muArr];
                break;
            case FLOSortTypeShell:
                [self ShellSort:muArr];
                break;
            case FLOSortTypeHeap:
                [self HeapSort:muArr];
                break;
            case FLOSortTypeMerge:
                [self MergeSort:muArr];
                break;
            case FLOSortTypeQuick:
                [self QuickSort:muArr];
                break;
            case FLOSortTypeRadix:
                [self RadixSort:muArr];
                break;
            default:
                break;
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.finished) {
                self.finished();
            }
        });
    });
}

- (void)updateValue:(float)value atIndex:(NSInteger)index {
    if (self.indexValueChanged) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.indexValueChanged(index, value);
        });
        [NSThread sleepForTimeInterval:0.001];
    }
}

//冒泡
- (void)BubbleSort:(NSMutableArray *)muArr {
    NSInteger count = muArr.count;
    
    //需要循环 count-1 次
    for (int i = 0; i < count-1; i++) {
        
        //从最后开始冒泡
        NSInteger j = count-1;
        
        while (j > i) {
            //相邻两个将小的换到前面
            if ([muArr[j] floatValue] < [muArr[j-1] floatValue]) {
                NSNumber *value = muArr[j-1];
                
                muArr[j-1] = muArr[j];
                muArr[j] = value;
                
                [self updateValue:[muArr[j] floatValue] atIndex:j];
                [self updateValue:[muArr[j-1] floatValue] atIndex:j-1];
            }
            
            j--;
        }
    }
}

//选择
- (void)SelectSort:(NSMutableArray *)muArr {
    NSInteger count = muArr.count;
    
    //需要循环 count-1 次
    for (int i = 0; i < count-1; i++) {
        
        //从第一位开始，找出最小的与该位互换
        float minValue = [muArr[i] floatValue];
        NSInteger minIndex = i;
        
        NSInteger j = i + 1;
        while (j < count) {
            //找出最小值并记录位置
            if ([muArr[j] floatValue] < minValue) {
                minValue = [muArr[j] floatValue];
                minIndex = j;
            }
            
            j++;
        }
        
        if (minIndex != i) {
            NSNumber *value = muArr[i];
            
            muArr[i] = muArr[minIndex];
            muArr[minIndex] = value;
            
            [self updateValue:[muArr[i] floatValue] atIndex:i];
            [self updateValue:[muArr[minIndex] floatValue] atIndex:minIndex];
        }
    }
}

//插入
- (void)InsertSort:(NSMutableArray *)muArr {
    NSInteger count = muArr.count;
    
    //需要循环 count-1 次
    for (int i = 0; i < count-1; i++) {
        
        //从第二个开始
        NSInteger j = i + 1;
        
        while (j > 0) {
            //如果比前一个小就往前移
            if ([muArr[j] floatValue] < [muArr[j-1] floatValue]) {
                NSNumber *value = muArr[j-1];
                
                muArr[j-1] = muArr[j];
                muArr[j] = value;
                
                [self updateValue:[muArr[j] floatValue] atIndex:j];
                [self updateValue:[muArr[j-1] floatValue] atIndex:j-1];
                
                j--;
            } else {
                break;
            }
        }
    }
}

//希尔
- (void)ShellSort:(NSMutableArray *)muArr {
    
}

//堆排序
- (void)HeapSort:(NSMutableArray *)muArr {
    
}

//归并
- (void)MergeSort:(NSMutableArray *)muArr {
    NSArray *result = [self MergeSortArr:muArr];
    for (NSInteger i = 0; i < result.count; i++) {
        [self updateValue:[result[i] floatValue] atIndex:i];
    }
}
- (NSMutableArray *)MergeSortArr:(NSMutableArray *)muArr {
    if (muArr.count < 2) {
        return muArr;
    }
    
    NSInteger mid = ceilf(muArr.count / 2.);
    return [self MergeSortLeft:[self MergeSortArr:[[muArr subarrayWithRange:NSMakeRange(0, mid)] mutableCopy]]
                         right:[self MergeSortArr:[[muArr subarrayWithRange:NSMakeRange(mid, muArr.count-mid)] mutableCopy]]];
}
- (NSMutableArray *)MergeSortLeft:(NSMutableArray *)arrLeft right:(NSMutableArray *)arrRight {
    NSMutableArray *result = [NSMutableArray array];
    
    while (arrLeft.count && arrRight.count) {
        if ([arrLeft.firstObject floatValue] <= [arrRight.firstObject floatValue]) {
            [result addObject:arrLeft.firstObject];
            
            [arrLeft removeObjectAtIndex:0];
        } else {
            [result addObject:arrRight.firstObject];
            
            [arrRight removeObjectAtIndex:0];
        }
    }
    
    [result addObjectsFromArray:arrLeft];
    [result addObjectsFromArray:arrRight];
    
    return result;
}

//快速
- (void)QuickSort:(NSMutableArray *)muArr {
    [self QuickSort:muArr startIndex:0 endIndex:muArr.count-1];
}
- (void)QuickSort:(NSMutableArray *)muArr startIndex:(NSInteger)start endIndex:(NSInteger)end {
    if (start < end) {
        //以start元素为基准
        NSInteger mid = start;
        
        for (NSInteger i = start+1; i <= end; i++) {
            if ([muArr[i] floatValue] < [muArr[mid] floatValue]) {
                NSNumber *value = muArr[i];
                
                //基数后一位换到i的位置
                //基数往后挪一位
                //将i元素插入到基数原位置
                muArr[i]     = muArr[mid+1];
                muArr[mid+1] = muArr[mid];
                muArr[mid]   = value;
                
                [self updateValue:[muArr[mid] floatValue] atIndex:mid];
                [self updateValue:[muArr[mid+1] floatValue] atIndex:mid+1];
                [self updateValue:[muArr[i] floatValue] atIndex:i];
                
                mid++;
            }
        }
        
        [self QuickSort:muArr startIndex:start endIndex:mid-1];
        [self QuickSort:muArr startIndex:mid+1 endIndex:end];
    }
}

//基数
- (void)RadixSort:(NSMutableArray *)muArr {
    
}
@end
