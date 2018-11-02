//
//  Random+CoreDataClass.h
//  FLOAPP
//
//  Created by 360doc on 2018/11/2.
//  Copyright © 2018 Flolangka. All rights reserved.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

NS_ASSUME_NONNULL_BEGIN

@interface Random : NSManagedObject

#pragma mark - 查询
/**
 查询所有随机项目
 */
+ (NSArray <Random *>*)allItems;

#pragma mark - 新增
/**
 新增随机项目

 @param name 名称
 @param options 可选项
 @return model
 */
+ (instancetype)insertEntityName:(NSString *)name
                         options:(NSArray <NSString *>*)options;

#pragma mark - 删除
/**
 删除项目
 */
+ (void)deleteEntity:(Random *)entity;

#pragma mark - 修改
/**
 修改最后一次随机结果
 */
- (void)updateLastResult:(NSString *)lastResult;

/**
 修改名称/可选项

 @param name 名称
 @param options 可选项
 */
- (void)updateName:(NSString *)name
           options:(NSArray <NSString *>*)options;

@end

NS_ASSUME_NONNULL_END

#import "Random+CoreDataProperties.h"
