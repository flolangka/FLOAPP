//
//  NotificationTime+CoreDataProperties.m
//  FLOAPP
//
//  Created by 360doc on 2017/12/29.
//  Copyright © 2017年 Flolangka. All rights reserved.
//
//

#import "NotificationTime+CoreDataProperties.h"

@implementation NotificationTime (CoreDataProperties)

+ (NSFetchRequest<NotificationTime *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"NotificationTime"];
}

@dynamic title;
@dynamic time;
@dynamic body;

@end
