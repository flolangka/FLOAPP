//
//  UIViewController+Alert.h
//  UITest
//
//  Created by 360doc on 2016/10/11.
//  Copyright © 2016年 Flolangka. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface StructAlertTitleAndAction : NSObject

/**
 弹框按钮的标题与action

 @param title  标题
 @param action action

 @return struct
 */
+ (instancetype)structWithTitle:(NSString *)title action:(void(^)())action;

@end

//⚠️：切记不可再实现类别中已实现的代理方法
@interface UIViewController (Alert) <UIAlertViewDelegate, UIActionSheetDelegate>

- (void)alertWithTitle:(NSString *)title
               message:(NSString *)message
    cancelButtonStruct:(StructAlertTitleAndAction *)cancelButtonStruct
    otherButtonStructs:(StructAlertTitleAndAction *)otherButtonStructs, ... NS_REQUIRES_NIL_TERMINATION;


- (void)actionSheetWithTitle:(NSString *)title
                     message:(NSString *)message
          cancelButtonStruct:(StructAlertTitleAndAction *)cancelButtonStruct
     destructiveButtonStruct:(StructAlertTitleAndAction *)destructiveButtonStruct
          otherButtonStructs:(StructAlertTitleAndAction *)otherButtonStructs, ... NS_REQUIRES_NIL_TERMINATION;

@end


