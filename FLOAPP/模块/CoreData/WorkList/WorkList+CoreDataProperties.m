//
//  WorkList+CoreDataProperties.m
//  FLOAPP
//
//  Created by 360doc on 2018/5/10.
//  Copyright © 2018年 Flolangka. All rights reserved.
//
//

#import "WorkList+CoreDataProperties.h"

@implementation WorkList (CoreDataProperties)

+ (NSFetchRequest<WorkList *> *)fetchRequest {
	return [NSFetchRequest fetchRequestWithEntityName:@"WorkList"];
}

@dynamic title;
@dynamic desc;
@dynamic startTime;
@dynamic endTime;
@dynamic status;
@dynamic items;
@dynamic itemsStatus;

@end
