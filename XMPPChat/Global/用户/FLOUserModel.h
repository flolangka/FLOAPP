//
//  FLOUserModel.h
//  XMPPChat
//
//  Created by admin on 15/11/27.
//  Copyright © 2015年 Flolangka. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FLOUserModel : NSObject

@property (nonatomic, copy  ) NSString *userName;
@property (nonatomic, strong) NSURL    *iconURL;

- (instancetype)initWithDictionary:(NSDictionary *)infoDic;

@end
