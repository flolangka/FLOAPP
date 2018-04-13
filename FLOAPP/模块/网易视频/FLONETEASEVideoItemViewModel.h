//
//  FLONETEASEVideoItemViewModel.h
//  FLOAPP
//
//  Created by 360doc on 2018/4/12.
//  Copyright © 2018年 Flolangka. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FLONETEASEVideoItem.h"

@interface FLONETEASEVideoItemViewModel : NSObject

@property (nonatomic, strong, readonly) FLONETEASEVideoItem *item;

@property (nonatomic, strong) NSURL *coverImageUrl;
@property (nonatomic, copy  ) NSString *title;
@property (nonatomic, strong) NSURL *userIconUrl;
@property (nonatomic, copy  ) NSString *userName;
@property (nonatomic, copy  ) NSAttributedString *replyAttStr;
@property (nonatomic, copy  ) NSString *playCountStr;
@property (nonatomic, copy  ) NSString *lengthStr;

@property (nonatomic, assign) float cellHeight;

- (instancetype)initWithItem:(FLONETEASEVideoItem *)item;

@end
