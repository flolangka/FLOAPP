//
//  FLONotificationViewController.m
//  FLOAPP
//
//  Created by 360doc on 2017/2/9.
//  Copyright © 2017年 Flolangka. All rights reserved.
//

#import "FLONotificationViewController.h"
#import "UIView+FLOUtil.h"
#import "FLONotificationTimeTableViewController.h"

#import <UserNotifications/UserNotifications.h>

@interface FLONotificationViewController ()

{
    NSArray *arrTitle;
    NSArray *arrUrl;
}

@property (weak, nonatomic) IBOutlet UITextField *TFTitle;
@property (weak, nonatomic) IBOutlet UITextField *TFBody;
@property (weak, nonatomic) IBOutlet UITextField *TFInfo;
@property (weak, nonatomic) IBOutlet UILabel *labelInfo;
@property (weak, nonatomic) IBOutlet UISegmentedControl *SCModel;
@property (weak, nonatomic) IBOutlet UIButton *btnPush;

@end

@implementation FLONotificationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    [[UIApplication sharedApplication].delegate performSelector:@selector(registerNotifer)];
#pragma clang diagnostic pop
    
    arrTitle = @[@"None", @"WebUrl", @"PicUrl", @"AudioUrl"];
    arrUrl = @[@"", @"http://flolangka.com", @"http://z.k1982.com/png/up/200712/20071208032104478.png", @"http://fs.web.kugou.com/57eae966379661e1e723476504323935/589d5c14/G002/M04/06/03/ooYBAFUHvO-ATN7OADvOP775Nwc554.mp3"];
    [self configView];
    
    //导航栏
    [self configNav];
}

- (void)configNav {
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"定时通知" style:UIBarButtonItemStyleDone target:self action:@selector(timeNoti)];
}

- (void)timeNoti {
    FLONotificationTimeTableViewController *tvc = [[FLONotificationTimeTableViewController alloc] init];
    [self.navigationController pushViewController:tvc animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)LocalPushTitle:(NSString *)title desc:(NSString *)desc model:(NSInteger)model attachment:(NSString *)attachment {
    UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
    content.sound = [UNNotificationSound defaultSound];
    content.title = title;
    content.body = desc;
    
    if (model > 0) {
        content.userInfo = @{arrTitle[model]: attachment};
        content.categoryIdentifier = arrTitle[model];
    }
    
    // 延时不能为0，会崩溃
    UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:@"123" content:content trigger:[UNTimeIntervalNotificationTrigger triggerWithTimeInterval:2 repeats:NO]];
    [[UNUserNotificationCenter currentNotificationCenter] addNotificationRequest:request withCompletionHandler:nil];
}

- (IBAction)segmentedValueChanged:(UISegmentedControl *)sender {
    _labelInfo.text = arrTitle[sender.selectedSegmentIndex];
    _TFInfo.text = arrUrl[sender.selectedSegmentIndex];
}

- (IBAction)pushAction:(UIButton *)sender {
    if (_TFTitle.text.length == 0) {
        Def_MBProgressString(@"请输入标题");
        return;
    }
    if (_SCModel.selectedSegmentIndex > 0 && _TFInfo.text.length == 0) {
        Def_MBProgressString(@"请输入URL");
        return;
    }
    
    [self LocalPushTitle:_TFTitle.text desc:_TFBody.text model:_SCModel.selectedSegmentIndex attachment:_TFInfo.text];
}

- (void)configView {
    _btnPush.layer.cornerRadius = 15;
    _btnPush.layer.borderWidth = 0.5;
    _btnPush.layer.borderColor = [UIColor grayColor].CGColor;
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
