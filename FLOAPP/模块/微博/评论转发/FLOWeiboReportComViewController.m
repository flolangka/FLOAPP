//
//  FLOWeiboReportComViewController.m
//  XMPPChat
//
//  Created by admin on 15/12/20.
//  Copyright © 2015年 Flolangka. All rights reserved.
//

#import "FLOWeiboReportComViewController.h"
#import "FLOWeiboAuthorization.h"
#import "FLONetworkUtil.h"
#import <MBProgressHUD.h>

static NSString * const kRepostStatusURL  = @"https://api.weibo.com/2/statuses/repost.json";
static NSString * const kCommentStatusURl = @"https://api.weibo.com/2/comments/create.json";

@interface FLOWeiboReportComViewController ()<UITextViewDelegate>

@property (weak, nonatomic) IBOutlet UITextView *textView;

@property (nonatomic, strong) UIBarButtonItem *rightBarBtnItem;

@end

@implementation FLOWeiboReportComViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.rightBarBtnItem = [[UIBarButtonItem alloc] initWithTitle:@"发送" style:UIBarButtonItemStyleDone target:self action:@selector(submit)];
    self.navigationItem.rightBarButtonItem = _rightBarBtnItem;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [_textView resignFirstResponder];
}

#pragma mark - UITextViewDelegate
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    textView.text = @"";
    textView.textColor = [UIColor blackColor];
    
    return YES;
}

- (void)submit {
    [_textView resignFirstResponder];
    
    // 构造请求参数
    NSString *message = self.textView.text;
    if (message.length > 140) {
        [FLOUtil flo_alertWithMessage:@"输入内容请不要超过140个字符" fromVC:self];
        return;
    } else if ([self.title isEqualToString:@"评论微博"] && _textView.text.length < 1) {
        [FLOUtil flo_alertWithMessage:@"评论内容不能为空" fromVC:self];
        return;
    }
    
    //回调结果
    NSString *promptStr;
    NSString *requestURLStr;
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setObject:[FLOWeiboAuthorization sharedAuthorization].token forKey:kAccessToken];
    
    if ([self.title isEqualToString:@"转发微博"]){
        // 转发，内容可为空
        if (![self.textView.text isEqualToString:@""] && self.textView.text != nil) {
            [parameters setObject:message forKey:@"status"];
        }
        [parameters setObject:_statusID forKey:@"id"];
        promptStr = @"转发微博";
        requestURLStr = kRepostStatusURL;
    } else if ([self.title isEqualToString:@"评论微博"]){
        [parameters setObject:message forKey:@"comment"];
        [parameters setObject:_statusID forKey:@"id"];
        promptStr = @"评论微博";
        requestURLStr = kCommentStatusURl;
    } else {
        return;
    }
    
    [[FLONetworkUtil sharedHTTPSession] POST:requestURLStr parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSString *str = [NSString stringWithFormat:@"%@ 成功", promptStr];
        Def_MBProgressStringDelay(str, 1);
        [self.navigationController popViewControllerAnimated:YES];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSString *str = [NSString stringWithFormat:@"%@ 失败,%@", promptStr, error.localizedDescription];
        Def_MBProgressStringDelay(str, 1);
    }];
}

@end
