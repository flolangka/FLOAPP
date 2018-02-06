//
//  DownloadFile+CoreDataProperties.m
//  
//
//  Created by 360doc on 2017/4/14.
//
//

#import "DownloadFile+CoreDataProperties.h"

@implementation DownloadFile (CoreDataProperties)

+ (NSFetchRequest<DownloadFile *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"DownloadFile"];
}

@dynamic downloadURL;
@dynamic downloadStatus;
@dynamic downloadProgress;
@dynamic fileName;
@dynamic taskID;
@dynamic savePath;
@dynamic downloadDate;

@end
