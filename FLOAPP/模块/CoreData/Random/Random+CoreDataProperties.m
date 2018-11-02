//
//  Random+CoreDataProperties.m
//  FLOAPP
//
//  Created by 360doc on 2018/11/2.
//  Copyright © 2018 Flolangka. All rights reserved.
//
//

#import "Random+CoreDataProperties.h"

@implementation Random (CoreDataProperties)

+ (NSFetchRequest<Random *> *)fetchRequest {
	return [NSFetchRequest fetchRequestWithEntityName:@"Random"];
}

@dynamic lastResult;
@dynamic name;
@dynamic options;

@end
