//
//  FLOAlgorithmViewController.m
//  FLOAPP
//
//  Created by 360doc on 2018/4/27.
//  Copyright © 2018年 Flolangka. All rights reserved.
//

#import "FLOAlgorithmViewController.h"
#import "FLOAlgorithmViewModel.h"

@interface FLOAlgorithmViewController ()

@property (nonatomic, strong, readwrite) FLOAlgorithmViewModel *viewModel;

@end

@implementation FLOAlgorithmViewController
@dynamic viewModel;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (UITableViewCell *)tableView:(UITableView *)tableView dequeueReusableCellForIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellid = @"FLOAlgorithmCellID";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellid];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellid];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    return cell;
}

- (void)configCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath withObject:(id)object {
    cell.textLabel.text = [self.viewModel cellTitleForIndexPath:indexPath];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    UIViewController *vc = [self.viewModel pushViewControllerForIndexPath:indexPath];
    if (vc) {
        [self.navigationController pushViewController:vc animated:YES];
    }
}

@end
