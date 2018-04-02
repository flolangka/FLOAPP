//
//  FLOCollectionItem.m
//  XMPPChat
//
//  Created by admin on 15/12/4.
//  Copyright © 2015年 Flolangka. All rights reserved.
//

#import "FLOCollectionItem.h"

@implementation FLOCollectionItem

- (instancetype)initWithDictionary:(NSDictionary *)infoDic
{
    self = [super init];
    if (self) {
        _itemName = infoDic[@"ItemName"];
        _itemIconURLStr = infoDic[@"ItemIconURL"];
        _itemAddress = infoDic[@"ItemAddress"];
    }
    return self;
}

- (NSDictionary *)infoDictionary
{
    return @{@"ItemName": self.itemName,
             @"ItemIconURL": self.itemIconURLStr,
             @"ItemAddress": self.itemAddress};
}


@end
