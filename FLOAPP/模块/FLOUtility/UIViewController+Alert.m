//
//  UIViewController+Alert.m
//  UITest
//
//  Created by 360doc on 2016/10/11.
//  Copyright © 2016年 Flolangka. All rights reserved.
//

#import "UIViewController+Alert.h"

static NSMutableArray *Alert_Actions;

@interface StructAlertTitleAndAction ()

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) void(^action)();

@end

@implementation StructAlertTitleAndAction

+ (instancetype)structWithTitle:(NSString *)title action:(void (^)())action {
    StructAlertTitleAndAction *instance = [[self alloc] init];
    if (instance) {
        instance.title = title;
        instance.action = action?:^{};
        
        if (instance.title == nil || instance.title.length == 0) {
            instance = nil;
        }
    }
    return instance;
}

@end

@implementation UIViewController (Alert)

- (void)alertWithTitle:(NSString *)title
               message:(NSString *)message
    cancelButtonStruct:(StructAlertTitleAndAction *)cancelButtonStruct
    otherButtonStructs:(StructAlertTitleAndAction *)otherButtonStructs, ... {
    
    CGFloat iOSVersion = [[UIDevice currentDevice].systemVersion floatValue];
    if (iOSVersion < 8) {
        
        UIAlertView *alertV = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:cancelButtonStruct?cancelButtonStruct.title:nil otherButtonTitles:nil];
        
        //otherButton
        NSMutableArray *arrOtherStructs = [NSMutableArray arrayWithCapacity:2];
        if (otherButtonStructs) {
            [arrOtherStructs addObject:otherButtonStructs];
            
            va_list args;
            va_start(args, otherButtonStructs);
            StructAlertTitleAndAction *otherStruct;
            while ((otherStruct = va_arg(args, StructAlertTitleAndAction *))){
                [arrOtherStructs addObject:otherStruct];
            }
            va_end(args);
        }
        Alert_Actions = [NSMutableArray arrayWithCapacity:2];
        if (cancelButtonStruct) {
            [Alert_Actions addObject:cancelButtonStruct.action];
        }
        for (StructAlertTitleAndAction *alertStruct in arrOtherStructs) {
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
            StructAlertTitleAndAction *otherStruct;
            while ((otherStruct = va_arg(args, StructAlertTitleAndAction *))){
                [arrOtherStructs addObject:otherStruct];
            }
            va_end(args);
            
            for (StructAlertTitleAndAction *alertStruct in arrOtherStructs) {
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
          cancelButtonStruct:(StructAlertTitleAndAction *)cancelButtonStruct
     destructiveButtonStruct:(StructAlertTitleAndAction *)destructiveButtonStruct
          otherButtonStructs:(StructAlertTitleAndAction *)otherButtonStructs, ... {
    
    CGFloat iOSVersion = [[UIDevice currentDevice].systemVersion floatValue];
    if (iOSVersion < 8) {
        
        UIActionSheet *actionsheet = [[UIActionSheet alloc] initWithTitle:title delegate:self cancelButtonTitle:cancelButtonStruct?cancelButtonStruct.title:nil destructiveButtonTitle:destructiveButtonStruct?destructiveButtonStruct.title:nil otherButtonTitles:nil];
        
        //otherButton
        NSMutableArray *arrOtherStructs = [NSMutableArray arrayWithCapacity:2];
        if (otherButtonStructs) {
            [arrOtherStructs addObject:otherButtonStructs];
            
            va_list args;
            va_start(args, otherButtonStructs);
            StructAlertTitleAndAction *otherStruct;
            while ((otherStruct = va_arg(args, StructAlertTitleAndAction *))){
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
        for (StructAlertTitleAndAction *alertStruct in arrOtherStructs) {
            [Alert_Actions addObject:alertStruct.action];
            [actionsheet addButtonWithTitle:alertStruct.title];
        }
        
        NSInteger tag = (NSInteger)[[NSDate date] timeIntervalSince1970];
        actionsheet.tag = tag;
        [actionsheet showInView:self.view];
        
    } else {
        
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleActionSheet];
        
        if (destructiveButtonStruct) {
            [alertController addAction:[UIAlertAction actionWithTitle:destructiveButtonStruct.title style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
                destructiveButtonStruct.action();
            }]];
        }
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
            StructAlertTitleAndAction *otherStruct;
            while ((otherStruct = va_arg(args, StructAlertTitleAndAction *))){
                [arrOtherStructs addObject:otherStruct];
            }
            va_end(args);
            
            for (StructAlertTitleAndAction *alertStruct in arrOtherStructs) {
                [alertController addAction:[UIAlertAction actionWithTitle:alertStruct.title style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    alertStruct.action();
                }]];
            }
        }
        
        [self presentViewController:alertController animated:YES completion:nil];
    }
}


#pragma mark - 代理
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    [self alertControlClickedButtonAtIndex:buttonIndex alertControlTag:actionSheet.tag];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    [self alertControlClickedButtonAtIndex:buttonIndex alertControlTag:alertView.tag];
}

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
