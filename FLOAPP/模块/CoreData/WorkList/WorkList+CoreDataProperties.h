//
//  WorkList+CoreDataProperties.h
//  FLOAPP
//
//  Created by 360doc on 2018/5/10.
//  Copyright © 2018年 Flolangka. All rights reserved.
//
//

#import "WorkList+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface WorkList (CoreDataProperties)

+ (NSFetchRequest<WorkList *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *title;
@property (nullable, nonatomic, copy) NSString *desc;
@property (nullable, nonatomic, copy) NSDate *time;
@property (nonatomic) int64_t status;
@property (nullable, nonatomic, retain) NSData *items;
@property (nullable, nonatomic, retain) NSData *itemsStatus;

@end

NS_ASSUME_NONNULL_END
