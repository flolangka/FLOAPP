//
//  FLORandomListViewController.m
//  FLOAPP
//
//  Created by 360doc on 2018/10/31.
//  Copyright © 2018 Flolangka. All rights reserved.
//

#import "FLORandomListViewController.h"
#import "FLORandomListViewModel.h"

#import "FLORandomViewController.h"
#import "FLORandomEditViewController.h"

@interface FLORandomListViewController ()

@property (nonatomic, strong, readwrite) FLORandomListViewModel *viewModel;

@end

@implementation FLORandomListViewController
@dynamic viewModel;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addAction:)];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.viewModel reloadData];
    [self.tableView reloadData];   
}

#pragma mark - action
/**
 点击添加事件
 */
- (void)addAction:(id)sender {
    FLORandomEditViewController *editVC = [[FLORandomEditViewController alloc] init];    
    [self.navigationController pushViewController:editVC animated:YES];
}

#pragma mark - tableView
//子类提供cell
- (UITableViewCell *)tableView:(UITableView *)tableView dequeueReusableCellForIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellid = @"FLORandomCellID";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellid];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellid];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    return cell;
}

//子类配置cell内容
- (void)configCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath withObject:(id)object {
    Random *model = [self.viewModel randomForIndexPath:indexPath];
    
    cell.textLabel.text = model.name;
    cell.detailTextLabel.text = Def_CheckStringClassAndLength(model.lastResult) ? [NSString stringWithFormat:@"上次结果: %@", model.lastResult] : nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    Random *model = [self.viewModel randomForIndexPath:indexPath];
    FLORandomViewController *randomViewController = [[FLORandomViewController alloc] init];
    randomViewController.randomModel = model;
    
    [self.navigationController pushViewController:randomViewController animated:YES];
}

#pragma mark - 删除数据
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        Random *model = [self.viewModel randomForIndexPath:indexPath];
        [Random deleteEntity:model];
        
        [self.viewModel reloadData];
        [self.tableView reloadData];
    }
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
