//
//  FLOAddBookMarkMaskView.h
//  XMPPChat
//
//  Created by admin on 15/12/14.
//  Copyright © 2015年 Flolangka. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FLOAddBookMarkMaskView : UIView

@property (weak, nonatomic) IBOutlet UINavigationBar *navBar;
@property (weak, nonatomic) IBOutlet UITextField *bookMarkNameTF;
@property (weak, nonatomic) IBOutlet UITextField *bookMarkURLTF;

@property (nonatomic, copy) void (^submit)(NSString *, NSString *);

@end
