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
        _itemIconURL = [NSURL URLWithString:infoDic[@"ItemIconURL"]];
        _itemAddress = infoDic[@"ItemAddress"];
    }
    return self;
}

- (NSDictionary *)infoDictionary
{
    return @{@"ItemName": self.itemName,
             @"ItemIconURL": self.itemIconURL.absoluteString,
             @"ItemAddress": self.itemAddress};
}


//- (instancetype)initWithName:(NSString *)itemName iconURL:(NSURL *)itemIconURL address:(NSString *)itemAddress

@end
