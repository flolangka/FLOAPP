//
//  UIViewController+Alert.h
//  UITest
//
//  Created by 360doc on 2016/10/11.
//  Copyright © 2016年 Flolangka. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AlertAction : NSObject

/**
 弹框按钮的标题与action

 @param title  标题
 @param action action

 @return struct
 */
+ (instancetype)actionWithTitle:(NSString *)title action:(void(^)())action;

+ (instancetype)cancelAction;

@end

//警告⚠️：使用此方法弹框后，在viewController中不能再写类别中已实现的代理方法了
@interface UIViewController (Alert) <UIAlertViewDelegate, UIActionSheetDelegate>

- (void)alertWithTitle:(NSString *)title
               message:(NSString *)message
    cancelButtonStruct:(AlertAction *)cancelButtonStruct
    otherButtonStructs:(AlertAction *)otherButtonStructs, ... NS_REQUIRES_NIL_TERMINATION;


- (void)actionSheetWithTitle:(NSString *)title
                     message:(NSString *)message
          cancelButtonStruct:(AlertAction *)cancelButtonStruct
     destructiveButtonStruct:(AlertAction *)destructiveButtonStruct
          otherButtonStructs:(AlertAction *)otherButtonStructs, ... NS_REQUIRES_NIL_TERMINATION;


//提示消息，按钮为“知道了”
- (void)alertWarringMsg:(NSString *)msg;
- (void)alertWarringMsg:(NSString *)msg title:(NSString *)title;

@end


