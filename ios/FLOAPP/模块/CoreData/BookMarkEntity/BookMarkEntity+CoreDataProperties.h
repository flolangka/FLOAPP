//
//  BookMarkEntity+CoreDataProperties.h
//  FLOAPP
//
//  Created by 360doc on 2018/2/6.
//  Copyright © 2018年 Flolangka. All rights reserved.
//
//

#import "BookMarkEntity+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface BookMarkEntity (CoreDataProperties)

+ (NSFetchRequest<BookMarkEntity *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *name;
@property (nullable, nonatomic, copy) NSString *url;

@end

NS_ASSUME_NONNULL_END
