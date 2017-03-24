//
//  FLOBookMarkModel.m
//  XMPPChat
//
//  Created by admin on 15/12/14.
//  Copyright © 2015年 Flolangka. All rights reserved.
//

#import "FLOBookMarkModel.h"

@implementation FLOBookMarkModel

- (instancetype)initWithBookMarkName:(NSString *)name urlString:(NSString *)urlStr
{
    self = [super init];
    if (self) {
        _bookMarkName = name;
        _bookMarkURLStr = urlStr;
    }
    return self;
}

@end
