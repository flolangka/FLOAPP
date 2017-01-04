//
//  MediaAddress+CoreDataProperties.m
//  FLOAPP
//
//  Created by 沈敏 on 2017/1/4.
//  Copyright © 2017年 Flolangka. All rights reserved.
//

#import "MediaAddress+CoreDataProperties.h"

@implementation MediaAddress (CoreDataProperties)

+ (NSFetchRequest<MediaAddress *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"MediaAddress"];
}

@dynamic name;
@dynamic url;

@end
