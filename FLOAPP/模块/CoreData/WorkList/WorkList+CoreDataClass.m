//
//  WorkList+CoreDataClass.m
//  FLOAPP
//
//  Created by 360doc on 2018/5/10.
//  Copyright © 2018年 Flolangka. All rights reserved.
//
//

#import "WorkList+CoreDataClass.h"
#import "APLCoreDataStackManager.h"

@implementation WorkList

//查
+ (NSArray <WorkList *>*)workListAtStatus:(NSInteger)status {
    NSFetchRequest *request = [WorkList fetchRequest];
    
    //设置排序
    NSSortDescriptor *time = [NSSortDescriptor sortDescriptorWithKey:@"time" ascending:status == 0];
    request.sortDescriptors = @[time];
    
    //设置过滤条件
    NSPredicate *pre = [NSPredicate predicateWithFormat:@"status = %ld", status];
    request.predicate = pre;
    
    return [[APLCoreDataStackManager sharedManager].managedObjectContext executeFetchRequest:request error:nil];
}

//增
+ (void)insertEntityTitle:(NSString *)title
                     desc:(NSString *)desc
                    items:(NSArray <NSString *>*)items {
    WorkList *entity = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass(self) inManagedObjectContext:[APLCoreDataStackManager sharedManager].managedObjectContext];
    
    entity.title = title;
    entity.desc = desc;
    entity.time = [NSDate date];
    entity.status = 0;
    entity.items = [items flo_JSONData];
    
    NSMutableArray *muArrItemStatus = [NSMutableArray arrayWithCapacity:items.count];
    int i = 0;
    while (i < items.count) {
        [muArrItemStatus addObject:@(NO)];
    }
    entity.itemsStatus = [muArrItemStatus flo_JSONData];
    
    [[APLCoreDataStackManager sharedManager].managedObjectContext save:nil];
}

//删
+ (void)deleteEntity:(WorkList *)entity {
    [[APLCoreDataStackManager sharedManager].managedObjectContext deleteObject:entity];
    [[APLCoreDataStackManager sharedManager].managedObjectContext save:nil];
}

//改
- (void)saveModify {
    [[APLCoreDataStackManager sharedManager].managedObjectContext save:nil];
}

- (void)updateItemStatus:(BOOL)status atIndex:(NSInteger)index {
    NSMutableArray *muArrItemStatus = [NSMutableArray arrayWithArray:[self.itemsStatus flo_objectFromJSONData]];
    if (index < muArrItemStatus.count) {
        muArrItemStatus[index] = @(status);
    }
    
    self.itemsStatus = [muArrItemStatus flo_JSONData];
    [self saveModify];
}

@end
