//
//  FLOBookMarkModel.h
//  XMPPChat
//
//  Created by admin on 15/12/14.
//  Copyright © 2015年 Flolangka. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FLOBookMarkModel : NSObject

@property (nonatomic, copy) NSString *bookMarkName;
@property (nonatomic, copy) NSString *bookMarkURLStr;

- (instancetype)initWithBookMarkName:(NSString *)name urlString:(NSString *)urlStr;

@end
