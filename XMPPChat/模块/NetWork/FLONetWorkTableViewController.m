//
//  FLONetWorkTableViewController.m
//  XMPPChat
//
//  Created by 沈敏 on 16/9/1.
//  Copyright © 2016年 Flolangka. All rights reserved.
//

#import "FLONetWorkTableViewController.h"
#import "FLOUtil.h"
#import "UIView+FLOUtil.h"
#import <Masonry.h>
#import <YYTextView.h>
#import "FLOTextViewViewController.h"
#import <MBProgressHUD.h>

@interface FLONetWorkTableViewController ()<YYTextViewDelegate>

{
    YYTextView *textView_url;
    YYTextView *textView_para;
    
    NSMutableDictionary *dataDic;
}

@end

@implementation FLONetWorkTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    dataDic = [NSMutableDictionary dictionaryWithCapacity:8];
    
    [self configTableHeaderView];
    self.tableView.tableFooterView = [[UIView alloc] init];
}

- (void)configTableHeaderView {
    UIView *headerV = [[UIView alloc] initWithFrame:CGRectMake(0, 0, DEVICE_SCREEN_WIDTH, 184)];
    
    textView_url = [[YYTextView alloc] init];
    textView_para = [[YYTextView alloc] init];
    [headerV addSubview:textView_url];
    [headerV addSubview:textView_para];
    
    [textView_url mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(headerV).with.offset(8);
        make.left.equalTo(headerV).with.offset(8);
        make.right.equalTo(headerV).with.offset(-8);
    }];
    [textView_para mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(textView_url.mas_bottom).with.offset(8);
        make.left.equalTo(headerV).with.offset(8);
        make.right.equalTo(headerV).with.offset(-8);
        make.bottom.equalTo(headerV).with.offset(-8);
        make.height.equalTo(textView_url.mas_height);
    }];
    
    textView_url.layer.cornerRadius = 5;
    textView_url.layer.masksToBounds = YES;
    textView_para.layer.cornerRadius = 5;
    textView_para.layer.masksToBounds = YES;
    
    textView_url.layer.borderWidth = 1;
    textView_url.layer.borderColor = [UIColor lightGrayColor].CGColor;
    textView_para.layer.borderWidth = 1;
    textView_para.layer.borderColor = [UIColor lightGrayColor].CGColor;
    
    textView_url.delegate = self;
    textView_para.delegate = self;
    textView_url.font = [UIFont systemFontOfSize:16];
    textView_para.font = [UIFont systemFontOfSize:16];
    textView_url.keyboardType = UIKeyboardTypeURL;
    
    textView_url.text = @"http://";
    textView_url.placeholderText = @"http://";
    textView_para.placeholderText = @"Parameters (End Editing Start Request)";
    textView_para.placeholderTextColor = COLOR_HEX(0xc7c7cd);
    textView_url.placeholderTextColor = COLOR_HEX(0xc7c7cd);
    
    UIView *bottomLine = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(headerV.frame)-0.5, DEVICE_SCREEN_WIDTH, 0.5)];
    bottomLine.backgroundColor = [UIColor lightGrayColor];
    [headerV addSubview:bottomLine];
    self.tableView.tableHeaderView = headerV;
}

#pragma mark - textView Delegate
- (void)textViewDidEndEditing:(YYTextView *)textView {
    if ([textView_url.text hasPrefix:@"http"]) {
        
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
            NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:textView_url.text] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:10];
            
            if ([textView_para.text containsString:@"="]) {
                NSData *postData = [textView_para.text dataUsingEncoding:NSUTF8StringEncoding];
                NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)postData.length];
                [urlRequest addValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
                [urlRequest addValue:postLength forHTTPHeaderField:@"Content-Length"];
                [urlRequest setHTTPMethod:@"POST"];
                [urlRequest setHTTPBody:postData];
            }
            
            NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:urlRequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                
                NSDictionary *allHeaderFields = [(NSHTTPURLResponse *)response allHeaderFields];
                
                [dataDic setObject:[NSString stringWithFormat:@"%ld",[(NSHTTPURLResponse *)response statusCode]] forKey:@"statusCode"];
                [dataDic setObject:allHeaderFields?:@{} forKey:@"allHeaderFields"];
                [dataDic setObject:response.MIMEType?:@"" forKey:@"MIMEType"];
                [dataDic setObject:[NSString stringWithFormat:@"%lld", response.expectedContentLength] forKey:@"expectedContentLength"];
                [dataDic setObject:response.suggestedFilename?:@"" forKey:@"suggestedFilename"];
                [dataDic setObject:response.textEncodingName?:@"" forKey:@"textEncodingName"];
                [dataDic setObject:error?:@"" forKey:@"error"];
                [dataDic setObject:[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] forKey:@"result"];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [MBProgressHUD hideHUDForView:self.view animated:YES];
                    [self.tableView reloadData];
                });
                
            }];
            [task resume];
            
        });
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView == self.tableView) {
        [textView_url resignFirstResponder];
        [textView_para resignFirstResponder];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return dataDic.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RightDetailCellID" forIndexPath:indexPath];
    
    switch (indexPath.row) {
        case 0:
        {
            cell.textLabel.text = @"statusCode";
            cell.detailTextLabel.text = dataDic[@"statusCode"]?:@"";
        }
            break;
        case 1:
        {
            cell.textLabel.text = @"MIMEType";
            cell.detailTextLabel.text = dataDic[@"MIMEType"]?:@"";
        }
            break;
        case 2:
        {
            cell.textLabel.text = @"expectedContentLength";
            cell.detailTextLabel.text = dataDic[@"expectedContentLength"]?:@"";
        }
            break;
        case 3:
        {
            cell.textLabel.text = @"suggestedFilename";
            cell.detailTextLabel.text = dataDic[@"suggestedFilename"]?:@"";
        }
            break;
        case 4:
        {
            cell.textLabel.text = @"textEncodingName";
            cell.detailTextLabel.text = dataDic[@"textEncodingName"]?:@"";
        }
            break;
        case 5:
        {
            cell.textLabel.text = @"allHeaderFields";
            cell.detailTextLabel.text = dataDic[@"allHeaderFields"] ? @"{...}" : @"";
        }
            break;
        case 6:
        {
            cell.textLabel.text = @"result";
            cell.detailTextLabel.text = dataDic[@"result"]?:@"";
        }
            break;
        case 7:
        {
            cell.textLabel.text = @"error";
            
             id error = dataDic[@"error"];
            cell.detailTextLabel.text = [error isKindOfClass:[NSError class]] ? [(NSError *)error localizedDescription] : @"";
        }
            break;
        default:
            break;
    }
    
    if (indexPath.row % 2 == 0) {
        cell.backgroundColor = [UIColor groupTableViewBackgroundColor];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    if (indexPath.row == 5) {
        NSDictionary *header = dataDic[@"allHeaderFields"];
        FLOTextViewViewController *tvVC = [[FLOTextViewViewController alloc] init];
        tvVC.contentText = [header flo_JSONString];
        
        [self.navigationController pushViewController:tvVC animated:YES];
    } else if (indexPath.row == 6) {
        NSString *result = dataDic[@"result"];
        if (result && result.length > 0) {
            FLOTextViewViewController *tvVC = [[FLOTextViewViewController alloc] init];
            tvVC.contentText = result;
            
            [self.navigationController pushViewController:tvVC animated:YES];
        }
    } else if (indexPath.row == 7) {
        id obj = dataDic[@"error"];
        if ([obj isKindOfClass:[NSError class]]) {
            NSError *error = (NSError *)obj;
            FLOTextViewViewController *tvVC = [[FLOTextViewViewController alloc] init];
            tvVC.contentText = [NSString stringWithFormat:@"Description: %@\nFailureReason: %@\nFailureReason: %@\nRecoverySuggestion: %@", error.localizedDescription, error.localizedFailureReason, error.localizedRecoveryOptions, error.localizedRecoverySuggestion];
            
            [self.navigationController pushViewController:tvVC animated:YES];
        }
    }
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

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
