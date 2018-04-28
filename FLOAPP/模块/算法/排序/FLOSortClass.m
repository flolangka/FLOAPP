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
    
}

//快速
- (void)QuickSort:(NSMutableArray *)muArr {
    
}

//基数
- (void)RadixSort:(NSMutableArray *)muArr {
    
}
@end
