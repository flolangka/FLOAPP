//
//  FLOTouchIDViewController.m
//  XMPPChat
//
//  Created by admin on 15/12/21.
//  Copyright © 2015年 Flolangka. All rights reserved.
//

#import "FLOTouchIDViewController.h"
#import <LocalAuthentication/LAContext.h>
#import <AudioToolbox/AudioToolbox.h>

@interface FLOTouchIDViewController ()<UIAlertViewDelegate>

@end

@implementation FLOTouchIDViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    if ([self canEvaluatePolicy]) {
        [self evaluatePolicy];
    } else {
        [[[UIAlertView alloc] initWithTitle:@"Touch ID 不可用" message:nil delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (BOOL)canEvaluatePolicy
{
    LAContext *context = [[LAContext alloc] init];
    NSError *error;
    BOOL success;
    
    // test if we can evaluate the policy, this test will tell us if Touch ID is available and enrolled
    success = [context canEvaluatePolicy: LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&error];
    
    return success;
}

- (void)evaluatePolicy
{
    LAContext *context = [[LAContext alloc] init];
    
    [context evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics localizedReason:NSLocalizedString(@"摸一下又不会怀孕", nil) reply:
     ^(BOOL success, NSError *authenticationError) {
         if (success) {
             [self.navigationController popViewControllerAnimated:YES];
         } else {
             AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
         }
     }];
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
