//
//  NotificationTime+CoreDataProperties.h
//  FLOAPP
//
//  Created by 360doc on 2017/12/29.
//  Copyright © 2017年 Flolangka. All rights reserved.
//
//

#import "NotificationTime+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface NotificationTime (CoreDataProperties)

+ (NSFetchRequest<NotificationTime *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *title;
@property (nonatomic) int64_t time;
@property (nullable, nonatomic, copy) NSString *body;

@end

NS_ASSUME_NONNULL_END
