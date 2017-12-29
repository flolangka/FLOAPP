//
//  FLONotificationTimeAddViewController.m
//  FLOAPP
//
//  Created by 360doc on 2017/12/29.
//  Copyright © 2017年 Flolangka. All rights reserved.
//

#import "FLONotificationTimeAddViewController.h"
#import "NotificationTime+CoreDataClass.h"
#import "APLCoreDataStackManager.h"

@interface FLONotificationTimeAddViewController ()

@property (weak, nonatomic) IBOutlet UITextField *TFTitle;
@property (weak, nonatomic) IBOutlet UITextField *TFBody;
@property (weak, nonatomic) IBOutlet UITextField *TFHour;
@property (weak, nonatomic) IBOutlet UITextField *TFMinute;
@property (weak, nonatomic) IBOutlet UITextField *TFSecond;

@end

@implementation FLONotificationTimeAddViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)addAction:(UIButton *)sender {
    if (_TFTitle.text.length < 1 || _TFBody.text.length < 1) {
        return;
    }
    
    NotificationTime *obj = [NSEntityDescription insertNewObjectForEntityForName:@"NotificationTime" inManagedObjectContext:[APLCoreDataStackManager sharedManager].managedObjectContext];
    obj.title = _TFTitle.text;
    obj.body = _TFBody.text;
    obj.time = _TFHour.text.integerValue * 60 * 60 + _TFMinute.text.integerValue * 60 + _TFSecond.text.integerValue;
    [[APLCoreDataStackManager sharedManager].managedObjectContext save:nil];
    
    [self.navigationController popViewControllerAnimated:YES];
}

@end
