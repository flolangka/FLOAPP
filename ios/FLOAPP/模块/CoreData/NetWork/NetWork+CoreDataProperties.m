//
//  NetWork+CoreDataProperties.m
//  FLOAPP
//
//  Created by 沈敏 on 2017/1/4.
//  Copyright © 2017年 Flolangka. All rights reserved.
//

#import "NetWork+CoreDataProperties.h"

@implementation NetWork (CoreDataProperties)

+ (NSFetchRequest<NetWork *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"NetWork"];
}

@dynamic parameterStr;
@dynamic urlPath;

@end
