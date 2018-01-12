//
//  FLOMusicViewController.m
//  FLOAPP
//
//  Created by 360doc on 2017/11/15.
//  Copyright © 2017年 Flolangka. All rights reserved.
//

#import "FLOMusicViewController.h"
#import "FLOMusicModel.h"

#import <UIImageView+WebCache.h>

@interface FLOMusicViewController () <UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UITableView *resultTableView;

@property (nonatomic, strong) NSArray <FLOMusicModel *>*resultArr;

@end

@implementation FLOMusicViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _searchBar.delegate = self;
    _resultTableView.delegate = self;
    _resultTableView.dataSource = self;
    self.resultArr = @[];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - tableView delegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if (scrollView == _resultTableView) {
        [_searchBar resignFirstResponder];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    FLOMusicModel *music = [_resultArr objectAtIndex:indexPath.row];
    DLog(@"%ld", music.songID);
}

#pragma mark - tableView dataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _resultArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellid = @"MusicCellID";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellid];
    if (cell) {
        UIImageView *imageV = [cell.contentView viewWithTag:400];
        UILabel *titleLabel = [cell.contentView viewWithTag:401];
        UILabel *detailLabel = [cell.contentView viewWithTag:402];
        UILabel *timeLabel = [cell.contentView viewWithTag:403];
        FLOMusicModel *music = [_resultArr objectAtIndex:indexPath.row];
        
        [imageV sd_setImageWithURL:[NSURL URLWithString:music.logo]];
        titleLabel.text = music.name;
        if (Def_CheckStringClassAndLength(music.albumName)) {
            detailLabel.text = [NSString stringWithFormat:@"%@-[%@]", music.singer, music.albumName];
        } else {
            detailLabel.text = music.singer;
        }
        timeLabel.text = [NSString stringWithFormat:@"%ld:%ld", music.time/60, music.time%60];
    }
    return cell;
}

#pragma mark - searchBar delegate
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    NSString *text = searchBar.text;
    text = [text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    if (text.length == 0) {
        
    } else {
        Def_MBProgressShow;
        
        [FLOMusicModel XMMusicSearch:text page:1 completion:^(NSArray<FLOMusicModel *> *arr) {
            if (Def_CheckArrayClassAndCount(arr)) {
                self.resultArr = [NSArray arrayWithArray:arr];
                [self.resultTableView reloadData];
                
                [self.searchBar resignFirstResponder];
            } else {
                self.resultArr = @[];
                [self.resultTableView reloadData];
            }
            
            Def_MBProgressHide;
        }];
    }
}

@end
