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

@interface FLORandomListViewController ()

@property (nonatomic, strong, readwrite) FLORandomListViewModel *viewModel;

@end

@implementation FLORandomListViewController
@dynamic viewModel;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

//子类提供cell
- (UITableViewCell *)tableView:(UITableView *)tableView dequeueReusableCellForIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellid = @"FLORandomCellID";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellid];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellid];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    return cell;
}

//子类配置cell内容
- (void)configCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath withObject:(id)object {
    cell.textLabel.text = [self.viewModel cellTitleForIndexPath:indexPath];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSArray <NSString *>*list = [self.viewModel randomListForIndexPath:indexPath];
    if (Def_CheckArrayClassAndCount(list)) {
        FLORandomViewController *randomViewController = [[FLORandomViewController alloc] init];
        randomViewController.title = [self.viewModel cellTitleForIndexPath:indexPath];
        randomViewController.randomList = list;
        
        [self.navigationController pushViewController:randomViewController animated:YES];
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
