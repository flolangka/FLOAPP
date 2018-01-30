//
//  FLOQSBKTopicTableViewCell.h
//  FLOAPP
//
//  Created by 360doc on 2018/1/29.
//  Copyright © 2018年 Flolangka. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FLOQSBKTopicTableViewCell : UITableViewCell

- (void)configUserIcon:(NSString *)icon
              userName:(NSString *)name
            createTime:(NSString *)time
               content:(NSString *)content
              pictures:(NSArray *)pictures;

@end
