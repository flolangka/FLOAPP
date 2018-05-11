//
//  WorkList+CoreDataClass.h
//  FLOAPP
//
//  Created by 360doc on 2018/5/10.
//  Copyright © 2018年 Flolangka. All rights reserved.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

NS_ASSUME_NONNULL_BEGIN

@interface WorkList : NSManagedObject

//查
+ (NSArray <WorkList *>*)workListAtStatus:(NSInteger)status;

//增
+ (instancetype)insertEntityTitle:(NSString *)title
                             desc:(NSString *)desc
                            items:(NSArray <NSString *>*)items;

//删
+ (void)deleteEntity:(WorkList *)entity;

//改
- (void)saveModify;
- (void)updateItemStatus:(BOOL)status atIndex:(NSInteger)index;

@end

NS_ASSUME_NONNULL_END

#import "WorkList+CoreDataProperties.h"
