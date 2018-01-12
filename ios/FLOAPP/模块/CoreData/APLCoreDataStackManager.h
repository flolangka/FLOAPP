/*
 Copyright (C) 2016 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 Singleton controller to manage the main Core Data stack for the application.
 */

@import CoreData;
@import Foundation;

@interface APLCoreDataStackManager : NSObject

+ (instancetype)sharedManager;

@property (nonatomic, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, readonly) NSManagedObjectContext *managedObjectContext;

@end


/* CoreData 基本使用
 
 #import "MediaAddress+CoreDataClass.h"
 #import "APLCoreDataStackManager.h"
 
 // 查询
 - (void)fetchData {
 //建立请求
 NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"MediaAddress"];
 //读取数据
 NSArray *array = [[APLCoreDataStackManager sharedManager].managedObjectContext executeFetchRequest:request error:nil];
 
 dataArr = [NSMutableArray arrayWithArray:array];
 }
 
 
 // 插入
 MediaAddress *obj = [NSEntityDescription insertNewObjectForEntityForName:@"MediaAddress" inManagedObjectContext:[APLCoreDataStackManager sharedManager].managedObjectContext];
 obj.name = name;
 obj.url = urlStr;
 [[APLCoreDataStackManager sharedManager].managedObjectContext save:nil];
 
 
 // 删除
 [[APLCoreDataStackManager sharedManager].managedObjectContext deleteObject:dataArr[indexPath.row]];
 [[APLCoreDataStackManager sharedManager].managedObjectContext save:nil];
 */
