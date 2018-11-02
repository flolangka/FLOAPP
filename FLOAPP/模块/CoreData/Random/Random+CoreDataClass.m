//
//  Random+CoreDataClass.m
//  FLOAPP
//
//  Created by 360doc on 2018/11/2.
//  Copyright © 2018 Flolangka. All rights reserved.
//
//

#import "Random+CoreDataClass.h"
#import "APLCoreDataStackManager.h"

@implementation Random

#pragma mark - 查询
/**
 查询所有随机项目
 */
+ (NSArray <Random *>*)allItems {
    NSFetchRequest *request = [Random fetchRequest];
    
    return [[APLCoreDataStackManager sharedManager].managedObjectContext executeFetchRequest:request error:nil];
}

#pragma mark - 新增
/**
 新增随机项目
 
 @param name 名称
 @param options 可选项
 @return model
 */
+ (instancetype)insertEntityName:(NSString *)name
                         options:(NSArray <NSString *>*)options {
    Random *entity = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass(self) inManagedObjectContext:[APLCoreDataStackManager sharedManager].managedObjectContext];
    
    entity.name = name;
    entity.options = [options flo_JSONData];
    entity.lastResult = @"";
    
    [[APLCoreDataStackManager sharedManager].managedObjectContext save:nil];
    return entity;
    
}

#pragma mark - 删除
/**
 删除项目
 */
+ (void)deleteEntity:(Random *)entity {
    [[APLCoreDataStackManager sharedManager].managedObjectContext deleteObject:entity];
    [[APLCoreDataStackManager sharedManager].managedObjectContext save:nil];
}

#pragma mark - 修改
- (void)saveModify {
    [[APLCoreDataStackManager sharedManager].managedObjectContext save:nil];
}

/**
 修改最后一次随机结果
 */
- (void)updateLastResult:(NSString *)lastResult {
    self.lastResult = lastResult;
    
    [self saveModify];
}

/**
 修改名称/可选项
 
 @param name 名称
 @param options 可选项
 */
- (void)updateName:(NSString *)name
           options:(NSArray<NSString *> *)options {
    self.name = name;
    self.options = [options flo_JSONData];
    
    [self saveModify];
}

@end
