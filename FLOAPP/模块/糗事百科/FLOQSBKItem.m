//
//  FLOQSBKItem.m
//  FLOAPP
//
//  Created by 360doc on 2018/1/30.
//  Copyright © 2018年 Flolangka. All rights reserved.
//

#import "FLOQSBKItem.h"

@implementation FLOQSBKItem

+ (instancetype)itemWithDictionary:(NSDictionary *)dict {
    NSString *format = dict[@"format"];
    
    FLOQSBKItem *item = nil;
    if ([format isEqualToString:@"word"]) {
        item = [FLOQSBKWordItem itemWithDictionary:dict];
    } else if ([format isEqualToString:@"image"]) {
        item = [FLOQSBKImageItem itemWithDictionary:dict];
    } else if ([format isEqualToString:@"video"]) {
        item = [FLOQSBKVideoItem itemWithDictionary:dict];
    }
    return item;
}

- (void)configProperty:(NSDictionary *)dict {
    NSDictionary *user = dict[@"user"];
    
    //用户信息可能为空
    if (Def_CheckDictionaryClassAndCount(user)) {
        NSString *userid = [NSString stringWithFormat:@"%@", user[@"id"]];
        _userIcon = [NSString stringWithFormat:@"http://pic.qiushibaike.com/system/avtnew/%@/%@/medium/%@", [userid substringWithRange:NSMakeRange(0, userid.length-4)], userid, user[@"icon"]];
        
        _userName = user[@"login"] ? : @"";
    } else {
        _userIcon = @"";
        _userName = @"匿名";
    }
    
    NSString *created_at = dict[@"created_at"] ? : @"";
    _createTime = [NSDate timeinterval2StringForDetail:created_at.doubleValue];
    _content    = dict[@"content"] ? : @"";
}

@end

@implementation FLOQSBKWordItem

+ (instancetype)itemWithDictionary:(NSDictionary *)dict {
    FLOQSBKWordItem *item = [[self alloc] init];
    [item configProperty:dict];
    return item;
}

- (void)configProperty:(NSDictionary *)dic {
    [super configProperty:dic];
    
    
}

@end

@implementation FLOQSBKImageItem

+ (instancetype)itemWithDictionary:(NSDictionary *)dict {
    FLOQSBKImageItem *item = [[self alloc] init];
    [item configProperty:dict];
    return item;
}

- (void)configProperty:(NSDictionary *)dic {
    [super configProperty:dic];
    
    _smallImgPath = [@"http:" stringByAppendingString:dic[@"low_loc"]];
    _mediumImgPath = [@"http:" stringByAppendingString:dic[@"high_loc"]];
    
    NSDictionary *image_size = dic[@"image_size"];
    NSArray *sizeArr = image_size[@"s"];
    if (!Def_CheckArrayClassAndCount(sizeArr)) {
        sizeArr = image_size[@"m"];
    }
    
    if (Def_CheckArrayClassAndCount(sizeArr) && sizeArr.count > 1) {
        _size = CGSizeMake([sizeArr[0] floatValue], [sizeArr[1] floatValue]);
    } else {
        //默认宽高比 3：2
        _size = CGSizeMake(320, 214);
    }
}

@end

@implementation FLOQSBKVideoItem

+ (instancetype)itemWithDictionary:(NSDictionary *)dict {
    FLOQSBKVideoItem *item = [[self alloc] init];
    [item configProperty:dict];
    return item;
}

- (void)configProperty:(NSDictionary *)dic {
    [super configProperty:dic];
    
    _imgPath = dic[@"pic_url"];
    _videoPath = dic[@"high_url"];
    
    NSArray *sizeArr = dic[@"pic_size"];
    if (Def_CheckArrayClassAndCount(sizeArr) && sizeArr.count > 1) {
        _size = CGSizeMake([sizeArr[0] floatValue], [sizeArr[1] floatValue]);
    } else {
        //默认宽高比 3：2
        _size = CGSizeMake(320, 214);
    }
}

@end
