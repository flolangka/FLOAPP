//
//  FLOCollectionItem.h
//  XMPPChat
//
//  Created by admin on 15/12/4.
//  Copyright © 2015年 Flolangka. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FLOCollectionItem : NSObject

@property (nonatomic, copy) NSString *itemName;
@property (nonatomic, copy) NSString *itemIconURLStr;

/**
 *  VC的storyboard ID >>>> SBID...
 *  VC类名 >>>> FLO...  push
 *  VC类名 >>>> Present...  present
 *  网址 >>>> http...
 *  app >>>> URLScheme_...
 */
@property (nonatomic, copy) NSString *itemAddress;

- (instancetype)initWithDictionary:(NSDictionary *)infoDic;
- (NSDictionary *)infoDictionary;


@end
