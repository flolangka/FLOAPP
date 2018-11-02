//
//  Random+CoreDataProperties.h
//  FLOAPP
//
//  Created by 360doc on 2018/11/2.
//  Copyright © 2018 Flolangka. All rights reserved.
//
//

#import "Random+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface Random (CoreDataProperties)

+ (NSFetchRequest<Random *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *lastResult;
@property (nullable, nonatomic, copy) NSString *name;
@property (nullable, nonatomic, retain) NSData *options;

@end

NS_ASSUME_NONNULL_END
