//
//  UIViewController+Alert.m
//  UITest
//
//  Created by 360doc on 2016/10/11.
//  Copyright © 2016年 Flolangka. All rights reserved.
//

#import "UIViewController+Alert.h"

static NSMutableArray *Alert_Actions;

@interface AlertAction ()

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) void(^action)();

@end

@implementation AlertAction

+ (instancetype)actionWithTitle:(NSString *)title action:(void (^)())action {
    AlertAction *instance = [[self alloc] init];
    if (instance) {
        instance.title = title;
        instance.action = action?:^{};
        
        if (instance.title == nil || instance.title.length == 0) {
            instance = nil;
        }
    }
    return instance;
}

+ (instancetype)cancelAction {
    return [AlertAction actionWithTitle:@"取消" action:nil];
}

@end

@implementation UIViewController (Alert)

- (void)alertWithTitle:(NSString *)title
               message:(NSString *)message
    cancelButtonStruct:(AlertAction *)cancelButtonStruct
    otherButtonStructs:(AlertAction *)otherButtonStructs, ... {
    
    CGFloat iOSVersion = [[UIDevice currentDevice].systemVersion floatValue];
    if (iOSVersion < 8) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        UIAlertView *alertV = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:cancelButtonStruct?cancelButtonStruct.title:nil otherButtonTitles:nil];
#pragma clang diagnostic pop        
        
        //otherButton
        NSMutableArray *arrOtherStructs = [NSMutableArray arrayWithCapacity:2];
        if (otherButtonStructs) {
            [arrOtherStructs addObject:otherButtonStructs];
            
            va_list args;
            va_start(args, otherButtonStructs);
            AlertAction *otherStruct;
            while ((otherStruct = va_arg(args, AlertAction *))){
                [arrOtherStructs addObject:otherStruct];
            }
            va_end(args);
        }
        Alert_Actions = [NSMutableArray arrayWithCapacity:2];
        if (cancelButtonStruct) {
            [Alert_Actions addObject:cancelButtonStruct.action];
        }
        for (AlertAction *alertStruct in arrOtherStructs) {
            [Alert_Actions addObject:alertStruct.action];
            [alertV addButtonWithTitle:alertStruct.title];
        }
        
        NSInteger tag = (NSInteger)[[NSDate date] timeIntervalSince1970];
        alertV.tag = tag;
        [alertV show];
        
    } else {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
        
        //取消action
        if (cancelButtonStruct) {
            [alertController addAction:[UIAlertAction actionWithTitle:cancelButtonStruct.title style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                cancelButtonStruct.action();
            }]];
        }
        
        //otherActions
        if (otherButtonStructs) {
            NSMutableArray *arrOtherStructs = [NSMutableArray arrayWithCapacity:2];
            [arrOtherStructs addObject:otherButtonStructs];
            
            va_list args;
            va_start(args, otherButtonStructs);
            AlertAction *otherStruct;
            while ((otherStruct = va_arg(args, AlertAction *))){
                [arrOtherStructs addObject:otherStruct];
            }
            va_end(args);
            
            for (AlertAction *alertStruct in arrOtherStructs) {
                [alertController addAction:[UIAlertAction actionWithTitle:alertStruct.title style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    alertStruct.action();
                }]];
            }
        }
        
        [self presentViewController:alertController animated:YES completion:nil];
    }
}

- (void)actionSheetWithTitle:(NSString *)title
                     message:(NSString *)message
          cancelButtonStruct:(AlertAction *)cancelButtonStruct
     destructiveButtonStruct:(AlertAction *)destructiveButtonStruct
          otherButtonStructs:(AlertAction *)otherButtonStructs, ... {
    
    CGFloat iOSVersion = [[UIDevice currentDevice].systemVersion floatValue];
    if (iOSVersion < 8) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        UIActionSheet *actionsheet = [[UIActionSheet alloc] initWithTitle:title delegate:self cancelButtonTitle:cancelButtonStruct?cancelButtonStruct.title:nil destructiveButtonTitle:destructiveButtonStruct?destructiveButtonStruct.title:nil otherButtonTitles:nil];
#pragma clang diagnostic pop
        
        
        //otherButton
        NSMutableArray *arrOtherStructs = [NSMutableArray arrayWithCapacity:2];
        if (otherButtonStructs) {
            [arrOtherStructs addObject:otherButtonStructs];
            
            va_list args;
            va_start(args, otherButtonStructs);
            AlertAction *otherStruct;
            while ((otherStruct = va_arg(args, AlertAction *))){
                [arrOtherStructs addObject:otherStruct];
            }
            va_end(args);
        }
        Alert_Actions = [NSMutableArray arrayWithCapacity:2];
        if (destructiveButtonStruct) {
            [Alert_Actions addObject:destructiveButtonStruct.action];
        }
        if (cancelButtonStruct) {
            [Alert_Actions addObject:cancelButtonStruct.action];
        }
        for (AlertAction *alertStruct in arrOtherStructs) {
            [Alert_Actions addObject:alertStruct.action];
            [actionsheet addButtonWithTitle:alertStruct.title];
        }
        
        NSInteger tag = (NSInteger)[[NSDate date] timeIntervalSince1970];
        actionsheet.tag = tag;
        [actionsheet showInView:self.view];
        
    } else {
        // 需要传进来弹框的位置，so iPad actionsheet用alert
        BOOL iPad = [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad;
        if (iPad) {
            if (destructiveButtonStruct) {
                [self alertWithTitle:title message:message cancelButtonStruct:cancelButtonStruct otherButtonStructs:destructiveButtonStruct, otherButtonStructs, nil];
            } else {
                [self alertWithTitle:title message:message cancelButtonStruct:cancelButtonStruct otherButtonStructs:otherButtonStructs, nil];
            }
            return;
        }
        
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleActionSheet];
        
        if (destructiveButtonStruct) {
            [alertController addAction:[UIAlertAction actionWithTitle:destructiveButtonStruct.title style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
                destructiveButtonStruct.action();
            }]];
        }
        
        // iPad cancel样式不起作用
        if (cancelButtonStruct) {
            [alertController addAction:[UIAlertAction actionWithTitle:cancelButtonStruct.title style:iPad ? UIAlertActionStyleDefault : UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                cancelButtonStruct.action();
            }]];
        }
        
        //otherActions
        if (otherButtonStructs) {
            NSMutableArray *arrOtherStructs = [NSMutableArray arrayWithCapacity:2];
            [arrOtherStructs addObject:otherButtonStructs];
            
            va_list args;
            va_start(args, otherButtonStructs);
            AlertAction *otherStruct;
            while ((otherStruct = va_arg(args, AlertAction *))){
                [arrOtherStructs addObject:otherStruct];
            }
            va_end(args);
            
            for (AlertAction *alertStruct in arrOtherStructs) {
                [alertController addAction:[UIAlertAction actionWithTitle:alertStruct.title style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    alertStruct.action();
                }]];
            }
        }
        
        /*  需要传进来弹框的位置，so iPad actionsheet用alert
        if (iPad) {
            UIPopoverPresentationController *ppc = alertController.popoverPresentationController;
            ppc.sourceView = self.view;
            ppc.sourceRect = CGRectMake((CGRectGetWidth(ppc.sourceView.bounds)-2)*0.5f, (CGRectGetHeight(ppc.sourceView.bounds)), 2, 2);// 显示在中心位置
        }
         */
        
        [self presentViewController:alertController animated:YES completion:nil];
    }
}

//提示消息，按钮为“知道了”
- (void)alertWarringMsg:(NSString *)msg {
    [self alertWarringMsg:msg title:nil];
}
- (void)alertWarringMsg:(NSString *)msg title:(NSString *)title {
    [self alertWithTitle:title message:msg cancelButtonStruct:[AlertAction actionWithTitle:@"知道了" action:nil] otherButtonStructs:nil];
}


#pragma mark - 代理
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    [self alertControlClickedButtonAtIndex:buttonIndex alertControlTag:actionSheet.tag];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    [self alertControlClickedButtonAtIndex:buttonIndex alertControlTag:alertView.tag];
}
#pragma clang diagnostic pop



- (void)alertControlClickedButtonAtIndex:(NSInteger)buttonIndex alertControlTag:(NSInteger)tag{
    double timeDouble = [[NSDate date] timeIntervalSince1970];
    if (timeDouble - tag < 60*60*24) {
        if (Alert_Actions && Alert_Actions.count > buttonIndex) {
            void(^action)() = Alert_Actions[buttonIndex];
            action();
        }
    }
}

@end
