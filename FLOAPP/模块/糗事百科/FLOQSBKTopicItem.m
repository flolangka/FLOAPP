//
//  FLOQSBKTopicItem.m
//  FLOAPP
//
//  Created by 360doc on 2018/1/29.
//  Copyright © 2018年 Flolangka. All rights reserved.
//

#import "FLOQSBKTopicItem.h"

@implementation FLOQSBKTopicItem

+ (instancetype)itemWithDictionary:(NSDictionary *)dict {
    if (dict && dict[@"status"] && [dict[@"status"] integerValue] == 1) {
        NSArray *pic_urls = dict[@"pic_urls"];
        if (Def_CheckArrayClassAndCount(pic_urls)) {
            FLOQSBKTopicItem *item = [[self alloc] init];
            [item configProperty:dict];
            
            return item;
        }
    }
    
    return nil;
}

- (void)configProperty:(NSDictionary *)dict {
    NSDictionary *user   = dict[@"user"];
    NSString *userid = [NSString stringWithFormat:@"%@", user[@"id"]];
    NSString *created_at = dict[@"created_at"] ? : @"";
    
    _userIcon   = [NSString stringWithFormat:@"http://pic.qiushibaike.com/system/avtnew/%@/%@/medium/%@", [userid substringWithRange:NSMakeRange(0, userid.length-4)], userid, user[@"icon"]];
    _userName   = user[@"login"] ? : @"";
    _createTime = [NSDate timeinterval2StringForDetail:created_at.doubleValue];
    _content    = dict[@"content"] ? : @"";
    
    NSMutableArray *muArr = [NSMutableArray array];
    NSArray *pic_urls = dict[@"pic_urls"];
    for (NSDictionary *picInfo in pic_urls) {
        NSString *pic_url = picInfo[@"pic_url"];
        if (Def_CheckStringClassAndLength(pic_url)) {
            [muArr addObject:pic_url];
        }
    }
    _pictures   = [NSArray arrayWithArray:muArr];
}

@end
