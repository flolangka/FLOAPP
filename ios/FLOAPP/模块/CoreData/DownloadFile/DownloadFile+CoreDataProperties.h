//
//  DownloadFile+CoreDataProperties.h
//  
//
//  Created by 360doc on 2017/4/14.
//
//

#import "DownloadFile+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface DownloadFile (CoreDataProperties)

+ (NSFetchRequest<DownloadFile *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *downloadURL;
//下载状态, -1:下载失败、0:未下载、1:正在下载、2:暂停下载、3:下载完成
@property (nonatomic) int16_t downloadStatus;
@property (nonatomic) float downloadProgress;
@property (nullable, nonatomic, copy) NSString *fileName;
@property (nullable, nonatomic, copy) NSString *taskID;
@property (nullable, nonatomic, copy) NSString *savePath;
@property (nullable, nonatomic, retain) NSObject *downloadDate;

@end

NS_ASSUME_NONNULL_END
