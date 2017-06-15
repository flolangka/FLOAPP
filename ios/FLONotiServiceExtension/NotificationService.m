//
//  NotificationService.m
//  FLONotiServiceExtension
//
//  Created by 沈敏 on 2017/2/12.
//  Copyright © 2017年 Flolangka. All rights reserved.
//

#import "NotificationService.h"

@interface NotificationService ()

@property (nonatomic, strong) void (^contentHandler)(UNNotificationContent *contentToDeliver);
@property (nonatomic, strong) UNMutableNotificationContent *bestAttemptContent;

@end

@implementation NotificationService

/*
 {
     "aps": {
         "alert": "This is some fancy message.",
         "badge": 1,
         "sound": "default",
         "mutable-content": "1", // 重要字段，需要该字段，UNNotificationServiceExtension才会干活
         "imageAbsoluteString": "http://upload.univs.cn/2012/0104/1325645511371.jpg"
     }
 }
 */
- (void)didReceiveNotificationRequest:(UNNotificationRequest *)request withContentHandler:(void (^)(UNNotificationContent * _Nonnull))contentHandler {
    self.contentHandler = contentHandler;
    self.bestAttemptContent = [request.content mutableCopy];
    
    // Modify the notification content here...
    NSString *getURL = @"";
    
    NSDictionary *userInfo = self.bestAttemptContent.userInfo;
    getURL = userInfo[@"PicUrl"];
    if (getURL == nil || getURL.length < 1) {
        getURL = userInfo[@"AudioUrl"];
    }
    if (getURL == nil || getURL.length < 1) {
        NSDictionary *aps = userInfo[@"aps"];
        if (aps && [aps isKindOfClass:[NSDictionary class]] && aps.count) {
            getURL = aps[@"picurl"];
            if (getURL == nil || getURL.length < 1) {
                getURL = aps[@"AudioUrl"];
            }
        }
    }
    
    if (getURL == nil || getURL.length < 1) {
        self.contentHandler(self.bestAttemptContent);
    } else {
        NSURLRequest * urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:getURL] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:15];
        //注意使用DownloadTask
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
        NSURLSession *session = [NSURLSession sessionWithConfiguration:config];
        NSURLSessionDownloadTask *task = [session downloadTaskWithRequest:urlRequest completionHandler:^(NSURL * _Nullable location, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            if (!error) {
                NSString *path = [location.path stringByAppendingString:response.suggestedFilename];
                NSError *err = nil;
                NSURL * pathUrl = [NSURL fileURLWithPath:path];
                [[NSFileManager defaultManager] moveItemAtURL:location toURL:pathUrl error:nil];
                //下载完毕生成附件，添加到内容中
                UNNotificationAttachment *resource_attachment = [UNNotificationAttachment attachmentWithIdentifier:@"attachment" URL:pathUrl options:nil error:&err];
                if (resource_attachment) {
                    self.bestAttemptContent.attachments = @[resource_attachment];
                }
                if (error) {
                    NSLog(@"%@", error);
                }
                //设置为@""以后，进入app将没有启动页
                self.bestAttemptContent.launchImageName = @"";
                //回调给系统
                self.contentHandler(self.bestAttemptContent);
            } else  {
                self.contentHandler(self.bestAttemptContent);
            }
        }];
        [task resume];
    }
}

- (void)serviceExtensionTimeWillExpire {
    // Called just before the extension will be terminated by the system.
    // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
    self.contentHandler(self.bestAttemptContent);
}

@end
