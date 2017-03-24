//
//  FLOLoginViewController.m
//  XMPPChat
//
//  Created by admin on 15/11/25.
//  Copyright © 2015年 Flolangka. All rights reserved.
//

#import "FLOLoginViewController.h"
#import "FLOAccountManager.h"
#import <MBProgressHUD.h>
#import "FLOLeftMenuVC.h"

@interface FLOLoginViewController ()

@property (weak, nonatomic) IBOutlet UITextField *userNameTF;
@property (weak, nonatomic) IBOutlet UITextField *passwordTF;

@end

@implementation FLOLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (IBAction)loginAction:(UIButton *)sender {
    [_userNameTF resignFirstResponder];
    [_passwordTF resignFirstResponder];    
    
    if (_userNameTF.text.length < 1) {
        [self showPromptTitle:@"请输入用户名..."];
    } else if (_passwordTF.text.length < 1) {
        [self showPromptTitle:@"请输入密码..."];
    } else {
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
            BOOL loginSuccess = [[FLOAccountManager shareManager] logInWithName:_userNameTF.text password:_passwordTF.text];
            sleep(2);
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [MBProgressHUD hideHUDForView:self.view animated:NO];
                
                if (loginSuccess) {
                    self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
                    [self dismissViewControllerAnimated:YES completion:^{
                        FLOLeftMenuVC *leftMenuVC = [[UIApplication sharedApplication].windows[0].rootViewController valueForKey:@"leftMenuViewController"];
                        [leftMenuVC refreshView];
                    }];
                } else {
                    [self showPromptTitle:@"登录失败..."];
                }
            });
        });
    }
}


- (void)showPromptTitle:(NSString *)title
{
    Def_MBProgressStringDelay(title, 1);
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
