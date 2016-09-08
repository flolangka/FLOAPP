//
//  NetWork+CoreDataProperties.h
//  XMPPChat
//
//  Created by 沈敏 on 16/9/5.
//  Copyright © 2016年 Flolangka. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "NetWork.h"

NS_ASSUME_NONNULL_BEGIN

@interface NetWork (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *urlPath;
@property (nullable, nonatomic, retain) NSString *parameterStr;

@end

NS_ASSUME_NONNULL_END
