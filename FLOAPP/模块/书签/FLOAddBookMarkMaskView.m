//
//  FLOAddBookMarkMaskView.m
//  XMPPChat
//
//  Created by admin on 15/12/14.
//  Copyright © 2015年 Flolangka. All rights reserved.
//

#import "FLOAddBookMarkMaskView.h"
#import <MBProgressHUD.h>

@implementation FLOAddBookMarkMaskView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [_bookMarkNameTF becomeFirstResponder];
}

- (IBAction)cancelAction:(UIBarButtonItem *)sender {
    [self hide];
}

- (IBAction)submitAction:(UIBarButtonItem *)sender {
    if (_bookMarkURLTF.text.length < 1) {
        [self showAlert:@"地址不能为空"];
        return;
    } else if (_bookMarkNameTF.text.length < 1) {
        [self showAlert:@"书签名不能为空"];
        return;
    }
    
    _submit(_bookMarkNameTF.text, _bookMarkURLTF.text);
    [self hide];
}

- (void)showAlert:(NSString *)alertStr
{
    MBProgressHUD *progress = [MBProgressHUD showHUDAddedTo:self animated:YES];
    progress.mode = MBProgressHUDModeText;
    progress.labelText = alertStr;
    [progress show:YES];
    
    [progress hide:YES afterDelay:2];
}

- (void)hide
{
    [_bookMarkNameTF resignFirstResponder];
    [_bookMarkURLTF resignFirstResponder];
    
    CGSize size = [UIScreen mainScreen].bounds.size;
    [UIView animateWithDuration:0.25 animations:^{
        self.frame = CGRectMake(size.width, 20, size.width, size.height-20);
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

@end
