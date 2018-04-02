//
//  FLOCodeResultViewController.m
//  XMPPChat
//
//  Created by admin on 15/12/18.
//  Copyright © 2015年 Flolangka. All rights reserved.
//

#import "FLOCodeResultViewController.h"
#import "FLOWebViewController.h"

@interface FLOCodeResultViewController ()

@end

@implementation FLOCodeResultViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"扫码结果";
    
    UITextView *tv = [[UITextView alloc] initWithFrame:CGRectMake(20, 20, [UIScreen mainScreen].bounds.size.width-40, 100)];
    tv.text = _codeResultStr;
    
    [self.view addSubview:tv];
    
    
    if ([_codeResultStr hasPrefix:@"http"]) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(20, 130, [UIScreen mainScreen].bounds.size.width-40, 35);
        btn.backgroundColor = [[UIColor greenColor] colorWithAlphaComponent:0.8];
        btn.layer.cornerRadius = 5.;
        btn.clipsToBounds = YES;
        [btn setTitle:@"在浏览器中打开链接" forState:UIControlStateNormal];
        [btn setTintColor:[UIColor whiteColor]];
        [btn addTarget:self action:@selector(openInWebView) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:btn];
    }
}

- (void)openInWebView
{
    FLOWebViewController *webViewController = [[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"SBIDWebViewController"];
    webViewController.webViewAddress = _codeResultStr;
    
    [self.navigationController pushViewController:webViewController animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
