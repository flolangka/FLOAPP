//
//  FLONETEASEVideoViewModel.m
//  FLOAPP
//
//  Created by 360doc on 2018/4/12.
//  Copyright © 2018年 Flolangka. All rights reserved.
//

#import "FLONETEASEVideoViewModel.h"
#import "FLONetworkUtil.h"
#import "FLONETEASEVideoItem.h"
#import "FLONETEASEVideoItemViewModel.h"
#import "FLONETEASEVideoTableViewCell.h"

@implementation FLONETEASEVideoViewModel

- (instancetype)init {
    self = [super init];
    if (self) {
        self.title = @"网易新闻-视频";
        
        self.tableViewStyle = UITableViewStyleGrouped;
        self.dataArr = [[NSMutableArray alloc] initWithCapacity:10];
    }
    return self;
}

- (void)requestNewDataCompletion:(void (^)(BOOL))completion {
    NSString *url = @"https://c.m.163.com/recommend/getChanListNews";
    NSDictionary *paras = @{@"channel": @"T1457068979049",
                            @"passport": @"DRGIi4b/h/dg0c7Z9v4%2B0GWlYJxG7i/ExMsC/IX1t2E%3D",
                            @"devId": @"Q%2BjkWas4IJMZMKgQjvSMP4AHtDeR70WeoBcW/eZ3QlU5P8a4skYUvZ4F0GRkDeH9",
                            @"version": @"34.0",
                            @"spever": @"false",
                            @"net": @"wifi",
                            @"lat": @"",
                            @"lon": @"",
                            @"ts": [NSString stringWithFormat:@"%.0f", [[NSDate date] timeIntervalSince1970]],
                            @"sign": @"n29iC9LL/pe2Vyus8Vlvy%2BsmnmW5%2BjCrUP9f/jjxKHl48ErR02zJ6/KXOnxX046I",
                            @"encryption": @"1",
                            @"canal": @"appstore",
                            @"offset": @"0",
                            @"size": @"10",
                            @"fn": (self.dataArr.count ? @"2" : @"1")
                            };
    
    [[FLONetworkUtil sharedHTTPSession] GET:url parameters:paras progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            //解析请求结果
            NSArray *itemArr = nil;
            NSDictionary *result = [FLONetworkUtil dictionaryResult:responseObject];
            
            if (Def_CheckDictionaryClassAndCount(result)) {
                NSArray *items = result[@"视频"];
                if (Def_CheckArrayClassAndCount(items)) {
                    itemArr = items;
                }
            }
            
            //转model
            NSMutableArray *muarr = [NSMutableArray arrayWithCapacity:itemArr.count];
            for (NSDictionary *dict in itemArr) {
                FLONETEASEVideoItem *item = [[FLONETEASEVideoItem alloc] initWithInfo:dict];
                if (item) {
                    FLONETEASEVideoItemViewModel *itemVM = [[FLONETEASEVideoItemViewModel alloc] initWithItem:item];
                    itemVM.cellHeight = [FLONETEASEVideoTableViewCell heightWithViewModel:itemVM];
                    [muarr addObject:@[itemVM]];
                }
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                //添加到数据源，刷新页面
                if (muarr.count > 0) {
                    [self.dataArr removeAllObjects];
                    [self.dataArr addObjectsFromArray:muarr];
                }
                
                completion(muarr.count > 0);
            });
        });
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (completion) {
            completion(NO);
        }
    }];
}

- (void)requestMoreDataEndRequest:(void (^)())endRequest completion:(void (^)(NSIndexSet *))completion {
    NSString *url = @"https://c.m.163.com/recommend/getChanListNews";
    NSDictionary *paras = @{@"channel": @"T1457068979049",
                            @"passport": @"DRGIi4b/h/dg0c7Z9v4%2B0GWlYJxG7i/ExMsC/IX1t2E%3D",
                            @"devId": @"Q%2BjkWas4IJMZMKgQjvSMP4AHtDeR70WeoBcW/eZ3QlU5P8a4skYUvZ4F0GRkDeH9",
                            @"version": @"34.0",
                            @"spever": @"false",
                            @"net": @"wifi",
                            @"lat": @"",
                            @"lon": @"",
                            @"ts": [NSString stringWithFormat:@"%.0f", [[NSDate date] timeIntervalSince1970]],
                            @"sign": @"BfO16fM4TOltyYkvhFeBW2vc3%2BKJc2AC/FPjcj0v6/d48ErR02zJ6/KXOnxX046I",
                            @"encryption": @"1",
                            @"canal": @"appstore",
                            @"offset": Def_NSStringFromInteger(self.dataArr.count),
                            @"size": @"10",
                            @"fn": @"1"
                            };
    
    [[FLONetworkUtil sharedHTTPSession] GET:url parameters:paras progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (endRequest) {
            endRequest();
        }
        
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            //解析请求结果
            NSArray *itemArr = nil;
            NSDictionary *result = [FLONetworkUtil dictionaryResult:responseObject];
            
            if (Def_CheckDictionaryClassAndCount(result)) {
                NSArray *items = result[@"视频"];
                if (Def_CheckArrayClassAndCount(items)) {
                    itemArr = items;
                }
            }
            
            //转model
            NSMutableArray *muarr = [NSMutableArray arrayWithCapacity:itemArr.count];
            for (NSDictionary *dict in itemArr) {
                FLONETEASEVideoItem *item = [[FLONETEASEVideoItem alloc] initWithInfo:dict];
                if (item) {
                    FLONETEASEVideoItemViewModel *itemVM = [[FLONETEASEVideoItemViewModel alloc] initWithItem:item];
                    itemVM.cellHeight = [FLONETEASEVideoTableViewCell heightWithViewModel:itemVM];
                    [muarr addObject:@[itemVM]];
                }
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                //添加到数据源，刷新页面
                NSIndexSet *indexSet = nil;
                
                if (muarr.count > 0) {
                    indexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(self.dataArr.count, muarr.count)];
                    [self.dataArr addObjectsFromArray:muarr];
                }
                
                completion(indexSet);
            });
        });
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (endRequest) {
            endRequest();
        }
        
        if (completion) {
            completion(nil);
        }
    }];
}

@end
