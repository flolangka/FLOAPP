//
//  FLONotificationTimeTableViewController.m
//  FLOAPP
//
//  Created by 360doc on 2017/12/29.
//  Copyright © 2017年 Flolangka. All rights reserved.
//

#import "FLONotificationTimeTableViewController.h"
#import "NotificationTime+CoreDataClass.h"
#import "APLCoreDataStackManager.h"
#import "FLONotificationTimeAddViewController.h"

#import <UserNotifications/UserNotifications.h>

@interface FLONotificationTimeTableViewController ()

@property (nonatomic, strong) NSMutableArray *dataArr;

@end

@implementation FLONotificationTimeTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //导航栏
    [self configNav];
}

- (void)viewWillAppear:(BOOL)animated {
    [self initData];
}

- (void)configNav {
    self.title = @"定时通知";
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addTimeNoti)];
}

- (void)addTimeNoti {
    FLONotificationTimeAddViewController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"SBIDFLONotificationTimeAddViewController"];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)initData {
    //查询数据库
    //建立请求
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"NotificationTime"];
    //读取数据
    NSArray *array = [[APLCoreDataStackManager sharedManager].managedObjectContext executeFetchRequest:request error:nil];
    
    _dataArr = [NSMutableArray arrayWithArray:array];
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _dataArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellid = @"reuseIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellid];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellid];
    }
    
    NotificationTime *obj = _dataArr[indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"%@（%lld时%lld分%lld秒）", obj.title, (obj.time/(60*60)), (obj.time%(60*60))/60, (obj.time%(60*60))%60];
    cell.detailTextLabel.text = obj.body;
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;
}

- (nullable NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    return @"删除";
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [[APLCoreDataStackManager sharedManager].managedObjectContext deleteObject:_dataArr[indexPath.row]];
        [[APLCoreDataStackManager sharedManager].managedObjectContext save:nil];
        
        [_dataArr removeObjectAtIndex:indexPath.row];
        
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NotificationTime *obj = _dataArr[indexPath.row];
    
    //延时推送通知
    UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
    content.sound = [UNNotificationSound soundNamed:@"Monody.caf"];
    content.title = obj.title;
    content.body = obj.body;
    
    UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:obj.title content:content trigger:[UNTimeIntervalNotificationTrigger triggerWithTimeInterval:obj.time repeats:NO]];
    [[UNUserNotificationCenter currentNotificationCenter] addNotificationRequest:request withCompletionHandler:nil];    
}

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
