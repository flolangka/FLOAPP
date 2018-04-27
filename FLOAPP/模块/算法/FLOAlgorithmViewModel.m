//
//  FLOAlgorithmViewModel.m
//  FLOAPP
//
//  Created by 360doc on 2018/4/27.
//  Copyright © 2018年 Flolangka. All rights reserved.
//

#import "FLOAlgorithmViewModel.h"
#import "MVVMRouter.h"

@implementation FLOAlgorithmViewModel

- (instancetype)init {
    self = [super init];
    if (self) {
        self.title = @"算法";
        
        self.tableViewStyle = UITableViewStylePlain;
        self.dataArr = [NSMutableArray arrayWithObject:[NSMutableArray arrayWithCapacity:1]];
        
        [self.dataArr.firstObject addObject:@{@"title": @"排序",
                                              @"viewModel": @""
                                              }];
    }
    return self;
}

- (NSString *)cellTitleForIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *dic = [self.dataArr.firstObject objectAtIndex:indexPath.row];
    if (Def_CheckDictionaryClassAndCount(dic)) {
        return dic[@"title"];
    }
    return nil;
}

- (FLOBaseViewController *)pushViewControllerForIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *dic = [self.dataArr.firstObject objectAtIndex:indexPath.row];
    if (Def_CheckDictionaryClassAndCount(dic)) {
        
        NSString *str = dic[@"viewModel"];
        if (Def_CheckStringClassAndLength(str)) {
            
            return [MVVMRouter viewControllerForViewModelClassString:str];
        }
    }
    return nil;
}

@end
