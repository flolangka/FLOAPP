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
    NSSortDescriptor *time = [NSSortDescriptor sortDescriptorWithKey:@"startTime" ascending:status == 0];
    if (status == 2) {
        time = [NSSortDescriptor sortDescriptorWithKey:@"endTime" ascending:NO];
    }
    request.sortDescriptors = @[time];
    
    //设置过滤条件
    NSPredicate *pre = [NSPredicate predicateWithFormat:@"status = %ld", status];
    request.predicate = pre;
    
    return [[APLCoreDataStackManager sharedManager].managedObjectContext executeFetchRequest:request error:nil];
}

//增
+ (instancetype)insertEntityTitle:(NSString *)title
                             desc:(NSString *)desc
                            items:(NSArray <NSString *>*)items {
    WorkList *entity = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass(self) inManagedObjectContext:[APLCoreDataStackManager sharedManager].managedObjectContext];
    
    entity.title = title;
    entity.desc = desc;
    entity.startTime = [NSDate date];
    entity.endTime = nil;
    entity.status = 0;
    entity.items = [items flo_JSONData];
    
    NSMutableArray *muArrItemStatus = [NSMutableArray arrayWithCapacity:items.count];
    int i = 0;
    while (i < items.count) {
        [muArrItemStatus addObject:@(NO)];
        i++;
    }
    entity.itemsStatus = [muArrItemStatus flo_JSONData];
    
    [[APLCoreDataStackManager sharedManager].managedObjectContext save:nil];
    return entity;
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

- (void)updateWorkStatus:(NSInteger)status {
    if (status >= 0 && status <= 2) {
        self.status = status;
        
        if (status != 0) {
            self.endTime = [NSDate date];
        }
        
        [self saveModify];
    }
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
