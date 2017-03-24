//
//  NetWork+CoreDataProperties.h
//  FLOAPP
//
//  Created by 沈敏 on 2017/1/4.
//  Copyright © 2017年 Flolangka. All rights reserved.
//

#import "NetWork+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface NetWork (CoreDataProperties)

+ (NSFetchRequest<NetWork *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *parameterStr;
@property (nullable, nonatomic, copy) NSString *urlPath;

@end

NS_ASSUME_NONNULL_END
