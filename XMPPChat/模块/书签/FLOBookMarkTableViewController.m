//
//  FLOBookMarkTableViewController.m
//  XMPPChat
//
//  Created by admin on 15/12/14.
//  Copyright © 2015年 Flolangka. All rights reserved.
//

#import "FLOBookMarkTableViewController.h"
#import "FLODataBaseEngin.h"
#import "FLOBookMarkModel.h"
#import "FLOWebViewController.h"
#import "FLOAddBookMarkMaskView.h"

@interface FLOBookMarkTableViewController ()

{
    UIBarButtonItem *rightBarButtonItem;
}

@property (nonatomic, strong) NSMutableArray *dataArr;

@end

@implementation FLOBookMarkTableViewController

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.tableView.tableFooterView = [[UIView alloc] init];
    rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"加入书签" style:UIBarButtonItemStyleDone target:self action:@selector(addBookMark)];
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    NSArray *recordBookMarks = [[FLODataBaseEngin shareInstance] selectAllBookMark];
    self.dataArr = [NSMutableArray arrayWithArray:recordBookMarks];
    [self.tableView reloadData];
    
    self.navigationItem.rightBarButtonItem = rightBarButtonItem;
    for (FLOBookMarkModel *bookModel in recordBookMarks) {
        if (!_currentRequestURlStr || !_currentDocumentTitle || [bookModel.bookMarkURLStr isEqualToString:_currentRequestURlStr]) {
            //右上角 加入书签
            self.navigationItem.rightBarButtonItem = nil;
            break;
        }
    }
}

#pragma mark - 添加书签
- (void)addBookMark
{
    FLOAddBookMarkMaskView *maskView = [[[NSBundle mainBundle] loadNibNamed:@"FLOAddBookMarkMaskView" owner:nil options:nil] objectAtIndex:0];
    maskView.bookMarkNameTF.text = _currentDocumentTitle;
    maskView.bookMarkURLTF.text = _currentRequestURlStr;
    maskView.submit = ^void(NSString *name, NSString *urlStr){
        [[FLODataBaseEngin shareInstance] insertBookMark:[[FLOBookMarkModel alloc] initWithBookMarkName:name urlString:urlStr]];
        
        //刷新页面
        [self viewWillAppear:YES];
    };
    
    CGSize size = [UIScreen mainScreen].bounds.size;
    maskView.frame = CGRectMake(size.width, 20, size.width, size.height-20);
    [[UIApplication sharedApplication].keyWindow addSubview:maskView];
    
    [UIView animateWithDuration:0.25 animations:^{
        maskView.frame = CGRectMake(0, 20, size.width, size.height-20);
    }];
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _dataArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"bookMarkCellID" forIndexPath:indexPath];
    
    FLOBookMarkModel *bookMark = _dataArr[indexPath.row];
    cell.textLabel.text = bookMark.bookMarkName;
    cell.detailTextLabel.text = bookMark.bookMarkURLStr;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    FLOBookMarkModel *bookMark = _dataArr[indexPath.row];
    
    NSArray *viewControllers = self.navigationController.viewControllers;
    UIViewController *backVC = [viewControllers objectAtIndex:viewControllers.count-2];
    if ([backVC isKindOfClass:[FLOWebViewController class]]) {
        [(FLOWebViewController *)backVC setWebViewAddress:bookMark.bookMarkURLStr];
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        FLOWebViewController *webViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"SBIDWebViewController"];
        webViewController.webViewAddress = bookMark.bookMarkURLStr;
        [self.navigationController pushViewController:webViewController animated:YES];
    }
}

//删除数据
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [[FLODataBaseEngin shareInstance] deleteBookMark:self.dataArr[indexPath.row]];
        
        [self.dataArr removeObjectAtIndex:indexPath.row];
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

@end
