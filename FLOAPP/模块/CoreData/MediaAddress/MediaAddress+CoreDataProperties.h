//
//  MediaAddress+CoreDataProperties.h
//  FLOAPP
//
//  Created by 沈敏 on 2017/1/4.
//  Copyright © 2017年 Flolangka. All rights reserved.
//

#import "MediaAddress+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface MediaAddress (CoreDataProperties)

+ (NSFetchRequest<MediaAddress *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *name;
@property (nullable, nonatomic, copy) NSString *url;

@end

NS_ASSUME_NONNULL_END
