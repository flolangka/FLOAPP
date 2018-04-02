//
//  FLOMusicModel.m
//  FLOAPP
//
//  Created by 360doc on 2017/11/15.
//  Copyright © 2017年 Flolangka. All rights reserved.
//

#import "FLOMusicModel.h"
#import "NSString+FLOUtil.h"
#import "FLONetworkUtil.h"
#import <YYKit/NSString+YYAdd.h>

NSInteger const MusicSearchPageNum = 10;

@implementation FLOMusicModel

+ (instancetype)modelWithDictionary:(NSDictionary *)dict {
    FLOMusicModel *model = [[self alloc] init];
    model.songID = [[dict objectForKey:@"song_id"] integerValue];
    model.name = [dict objectForKey:@"song_name"];
    model.albumName = [dict objectForKey:@"album_name"] ? : @"";
    model.singer = [dict objectForKey:@"artist_name"];
    model.time = [[dict objectForKey:@"length"] integerValue];
    model.logo = [dict objectForKey:@"album_logo"] ? : @"";
    
    return model;
}

/**
 虾米音乐搜索
 
 @param text 关键词
 @param page 页码
 @param completion 搜索结果
 */
+ (void)XMMusicSearch:(NSString *)text page:(NSInteger)page completion:(void(^)(NSArray <FLOMusicModel *>*))completion {
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSString *appKey = @"24696108";
        NSString *appSecret = @"862f7167c0c134496173049541fc5f46";
        NSString *url = @"http://gw.api.taobao.com/router/rest";
        NSString *method = @"alibaba.xiami.api.search.songs.get";
        
        NSString *format = @"json";
        NSString *sign_method = @"md5";
        NSString *v = @"2.0";
        
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSString *timestamp = [dateFormat stringFromDate:[NSDate date]];
        
        NSString *sortParameters = [NSString stringWithFormat:@"%@+app_key%@format%@key%@limit%@method%@page%@sign_method%@timestamp%@v%@+%@", appSecret, appKey, format, text, Def_NSStringFromInteger(MusicSearchPageNum), method, Def_NSStringFromInteger(page), sign_method, timestamp, v, appSecret];
        sortParameters = [sortParameters StringEncoded2UTF8String];
        NSString *sign = [[sortParameters md5String] uppercaseString];
        
        url = [url stringByAppendingFormat:@"?app_key=%@&format=%@&key=%@&limit=%@&method=%@&page=%@&sign_method=%@&timestamp=%@&v=%@&sign=%@", appKey, format, [text StringEncoded2UTF8String], Def_NSStringFromInteger(MusicSearchPageNum), method, Def_NSStringFromInteger(page), sign_method, [timestamp StringEncoded2UTF8String], v, sign];
        
        [[FLONetworkUtil sharedHTTPSession] GET:url parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            DLog(@"%@", responseObject);
            dispatch_async(dispatch_get_main_queue(), ^{
                if (completion) {
                    completion(@[]);
                }
            });
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (completion) {
                    completion(@[]);
                }
            });
        }];
        
        /*
        [[FLONetworkUtil sharedHTTPSession] POST:url
           parameters:@{@"app_key": appKey,
                        @"format": format,
                        @"key": [text StringEncoded2UTF8String],
                        @"limit": Def_NSStringFromInteger(MusicSearchPageNum),
                        @"method": method,
                        @"page": Def_NSStringFromInteger(page),
                        @"sign_method": sign_method,
                        @"timestamp": timestamp,
                        @"v": v,
                        @"sign": sign,
                        }
             progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                 DLog(@"%@", responseObject);
                 dispatch_async(dispatch_get_main_queue(), ^{
                     if (completion) {
                         completion(@[]);
                     }
                 });
             } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                 dispatch_async(dispatch_get_main_queue(), ^{
                     if (completion) {
                         completion(@[]);
                     }
                 });
             }];
         */
    });
}

@end
