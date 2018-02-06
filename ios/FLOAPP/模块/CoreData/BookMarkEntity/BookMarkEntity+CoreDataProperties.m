//
//  BookMarkEntity+CoreDataProperties.m
//  FLOAPP
//
//  Created by 360doc on 2018/2/6.
//  Copyright © 2018年 Flolangka. All rights reserved.
//
//

#import "BookMarkEntity+CoreDataProperties.h"

@implementation BookMarkEntity (CoreDataProperties)

+ (NSFetchRequest<BookMarkEntity *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"BookMarkEntity"];
}

@dynamic name;
@dynamic url;

@end
