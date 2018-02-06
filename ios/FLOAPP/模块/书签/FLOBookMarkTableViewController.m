//
//  FLOBookMarkTableViewController.m
//  XMPPChat
//
//  Created by admin on 15/12/14.
//  Copyright © 2015年 Flolangka. All rights reserved.
//

#import "FLOBookMarkTableViewController.h"
#import "BookMarkEntity+CoreDataClass.h"
#import "APLCoreDataStackManager.h"
#import "FLOWebViewController.h"
#import "FLOAddBookMarkMaskView.h"
#import <MBProgressHUD.h>

@interface FLOBookMarkTableViewController ()

{
    UIBarButtonItem *rightBarButtonItem;
    
    UIButton *googleBtn;
    UIView *googleMaskView;
    UITextView *textView;
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
    
    //google
    googleBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    googleBtn.frame = CGRectMake(CGRectGetWidth(self.view.frame)-90, CGRectGetHeight(self.view.frame)-90, 60, 60);
    [googleBtn setImage:[UIImage imageNamed:@"Google_G_Logo"] forState:UIControlStateNormal];
    [googleBtn addTarget:self action:@selector(googleBtnAction:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    BOOL firstLoad = self.dataArr == nil;
    
    self.dataArr = [NSMutableArray arrayWithArray:[self localData]];
    [self.tableView reloadData];
    
    // 剪切板网址检测
    if (firstLoad) {
        [self checkPasteboard];
    }
    
    self.navigationItem.rightBarButtonItem = rightBarButtonItem;
    for (BookMarkEntity *bookModel in _dataArr) {
        if (!_currentRequestURlStr || !_currentDocumentTitle || [bookModel.url isEqualToString:_currentRequestURlStr]) {
            //右上角 加入书签
            self.navigationItem.rightBarButtonItem = nil;
            break;
        }
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [[UIApplication sharedApplication].keyWindow addSubview:googleBtn];
}

- (void)viewWillDisappear:(BOOL)animated {
    [googleBtn removeFromSuperview];
}

// 检测剪切板网址
- (void)checkPasteboard {
    NSString *pasteboardString = [UIPasteboard generalPasteboard].string;
    [[UIPasteboard generalPasteboard] setString:@""];
    
    if (pasteboardString && ([pasteboardString hasPrefix:@"http://"] || [pasteboardString hasPrefix:@"https://"])) {
        __block BOOL selected = NO;
        
        [_dataArr enumerateObjectsUsingBlock:^(BookMarkEntity *bookMark, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([bookMark.url isEqualToString:pasteboardString]) {
                selected = YES;
                *stop = YES;
            }
        }];
        
        if (!selected) {
            [self addBookMarkName:@"" url:pasteboardString];
            
            Def_MBProgressString(@"检测到剪切板网址");
        }
    }
}

- (NSArray *)localData {
    //建立请求
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"BookMarkEntity"];
    //读取数据
    NSArray *recordBookMarks = [[APLCoreDataStackManager sharedManager].managedObjectContext executeFetchRequest:request error:nil];
    
    //默认数据
    if (recordBookMarks.count == 0) {
        DLog(@"数据库中没有书签，添加默认书签");
        BookMarkEntity *entity1 = [self newBookMarkEntityName:@"Apple中国" url:@"http://www.apple.com/cn/"];
        BookMarkEntity *entity2 = [self newBookMarkEntityName:@"GitHub" url:@"https://github.com/"];
        BookMarkEntity *entity3 = [self newBookMarkEntityName:@"Sqlite" url:@"https://www.sqlite.org/"];
        BookMarkEntity *entity4 = [self newBookMarkEntityName:@"W3School" url:@"http://www.w3school.com.cn/"];
        BookMarkEntity *entity5 = [self newBookMarkEntityName:@"Flolangka" url:@"http://flolangka.com/"];
        
        [[APLCoreDataStackManager sharedManager].managedObjectContext save:nil];
        recordBookMarks = @[entity1, entity2, entity3, entity4, entity5];
    }
    
    return recordBookMarks;
}

- (BookMarkEntity *)newBookMarkEntityName:(NSString *)name url:(NSString *)url {
    BookMarkEntity *obj = [NSEntityDescription insertNewObjectForEntityForName:@"BookMarkEntity" inManagedObjectContext:[APLCoreDataStackManager sharedManager].managedObjectContext];
    obj.name = name;
    obj.url = url;
    
    return obj;
}

#pragma mark - 输入网址
- (void)googleBtnAction:(UIButton *)sender {
    if (!googleMaskView) {
        googleMaskView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame))];
        googleMaskView.backgroundColor = [[UIColor alloc] initWithWhite:0.5 alpha:0.4];
        
        //textView
        textView = [[UITextView alloc] initWithFrame:CGRectMake(16, 16, CGRectGetWidth(googleMaskView.bounds)-32, 80)];
        textView.keyboardType = UIKeyboardTypeURL;
        textView.font = [UIFont systemFontOfSize:17];
        
        //取消
        UIButton *cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        cancelBtn.frame = CGRectMake(16, 112, (CGRectGetWidth(googleMaskView.bounds)-32-8)/2., 44);
        cancelBtn.backgroundColor = [UIColor colorWithRed:15/255.0 green:191/255.0 blue:235/255.0 alpha:1.0];
        [cancelBtn setTitle:@"Cancel" forState:UIControlStateNormal];
        [cancelBtn addTarget:self action:@selector(cancelBtnAction:) forControlEvents:UIControlEventTouchUpInside];
        
        //确定
        UIButton *submitBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        submitBtn.frame = CGRectMake(16+8+(CGRectGetWidth(googleMaskView.bounds)-32-8)/2., 112, (CGRectGetWidth(googleMaskView.bounds)-32-8)/2., 44);
        submitBtn.backgroundColor = [UIColor colorWithRed:15/255.0 green:191/255.0 blue:235/255.0 alpha:1.0];
        [submitBtn setTitle:@"GO" forState:UIControlStateNormal];
        [submitBtn addTarget:self action:@selector(goBtnAction:) forControlEvents:UIControlEventTouchUpInside];
        
        [googleMaskView addSubview:textView];
        [googleMaskView addSubview:cancelBtn];
        [googleMaskView addSubview:submitBtn];
    }
    
    [self.view addSubview:googleMaskView];
    
    textView.text = @"http://";
    [textView becomeFirstResponder];
}

- (void)cancelBtnAction:(id)sender {
    [textView resignFirstResponder];
    [googleMaskView removeFromSuperview];
}

- (void)goBtnAction:(id)sender {
    if ([textView.text hasPrefix:@"http://"]) {
        FLOWebViewController *webViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"SBIDWebViewController"];
        webViewController.webViewAddress = [textView.text isEqualToString:@"http://"] ? @"http://flolangka.com" : textView.text;
        [self.navigationController pushViewController:webViewController animated:YES];
        
        [self cancelBtnAction:nil];
    } else {
        Def_MBProgressStringDelay(@"地址无效：http://xxxx", 1);
    }  
}

#pragma mark - 添加书签
- (void)addBookMark {
    [self addBookMarkName:_currentDocumentTitle url:_currentRequestURlStr];
}

- (void)addBookMarkName:(NSString *)name url:(NSString *)url {
    FLOAddBookMarkMaskView *maskView = [[[NSBundle mainBundle] loadNibNamed:@"FLOAddBookMarkMaskView" owner:nil options:nil] objectAtIndex:0];
    maskView.bookMarkNameTF.text = name;
    maskView.bookMarkURLTF.text = url;
    
    FLOWeakObj(self);
    maskView.submit = ^void(NSString *name, NSString *urlStr){
        // 插入数据库
        [weakself newBookMarkEntityName:name url:urlStr];
        [[APLCoreDataStackManager sharedManager].managedObjectContext save:nil];
        
        //刷新页面
        [weakself viewWillAppear:YES];
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
    
    BookMarkEntity *bookMark = _dataArr[indexPath.row];
    cell.textLabel.text = bookMark.name;
    cell.detailTextLabel.text = bookMark.url;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    BookMarkEntity *bookMark = _dataArr[indexPath.row];
    
    NSArray *viewControllers = self.navigationController.viewControllers;
    UIViewController *backVC = [viewControllers objectAtIndex:viewControllers.count-2];
    if ([backVC isKindOfClass:[FLOWebViewController class]]) {
        [(FLOWebViewController *)backVC setWebViewAddress:bookMark.url];
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        FLOWebViewController *webViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"SBIDWebViewController"];
        webViewController.webViewAddress = bookMark.url;
        [self.navigationController pushViewController:webViewController animated:YES];
    }
}

//删除数据
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [[APLCoreDataStackManager sharedManager].managedObjectContext deleteObject:_dataArr[indexPath.row]];
        [[APLCoreDataStackManager sharedManager].managedObjectContext save:nil];
        
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
