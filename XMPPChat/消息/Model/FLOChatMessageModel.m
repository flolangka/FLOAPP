//
//  FLOChatMessageModel.m
//  XMPPChat
//
//  Created by admin on 15/12/21.
//  Copyright © 2015年 Flolangka. All rights reserved.
//

#import "FLOChatMessageModel.h"

@implementation FLOChatMessageModel

- (instancetype)initWithDictionary:(NSDictionary *)infoDic
{
    self = [super init];
    if (self) {
        _messageFrom = infoDic[@"messageFrom"];
        _messageTo = infoDic[@"messageTo"];
        _messageContent = infoDic[@"messageContent"];
        _messageDate = [NSDate dateWithTimeIntervalSince1970:[infoDic[@"messageDate"] doubleValue]];
    }
    return self;
}

- (NSDictionary *)infoDictionary
{
    return @{@"messageFrom": _messageFrom,
             @"messageTo": _messageTo,
             @"messageContent": _messageContent,
             @"messageDate": [NSString stringWithFormat:@"%f", [_messageDate timeIntervalSince1970]]};
}

@end
