//
//  FLONetWorkHistoryTableViewController.m
//  XMPPChat
//
//  Created by 沈敏 on 16/9/5.
//  Copyright © 2016年 Flolangka. All rights reserved.
//

#import "FLONetWorkHistoryTableViewController.h"
#import "APLCoreDataStackManager.h"
#import <CoreData/CoreData.h>
#import "NetWork+CoreDataClass.h"

@interface FLONetWorkHistoryTableViewController ()

{
    NSMutableArray *dataArr;
}
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

@end

@implementation FLONetWorkHistoryTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    dataArr = [NSMutableArray arrayWithCapacity:42];
    
    //查询数据库
    //建立请求
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"NetWork"];
    //读取数据
    NSArray *array = [self.managedObjectContext executeFetchRequest:request error:nil];
    
    if (array) {
        [dataArr addObjectsFromArray:array];
    }
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return dataArr ? dataArr.count : 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CellID" forIndexPath:indexPath];
    
    NetWork *data = [dataArr objectAtIndex:indexPath.row];
    cell.textLabel.text = data.urlPath;
    cell.detailTextLabel.text = data.parameterStr;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    NetWork *data = [dataArr objectAtIndex:indexPath.row];
    if (_didSelectData) {
        _didSelectData(data.urlPath, data.parameterStr);
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        //更新数据库
        NetWork *data = [dataArr objectAtIndex:indexPath.row];
        [self.managedObjectContext deleteObject:data];
        [self.managedObjectContext save:nil];
        
        //更新数据源
        [dataArr removeObjectAtIndex:indexPath.row];
        
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
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

#pragma mark - Core Data support
- (NSManagedObjectContext *)managedObjectContext {
    if (_managedObjectContext) {
        return _managedObjectContext;
    }
    
    _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    _managedObjectContext.persistentStoreCoordinator = [[APLCoreDataStackManager sharedManager] persistentStoreCoordinator];
    
    return _managedObjectContext;
}

@end
