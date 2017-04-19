//
//  TodayViewController.m
//  Flolangka
//
//  Created by 360doc on 2017/4/19.
//  Copyright © 2017年 Flolangka. All rights reserved.
//

#import "TodayViewController.h"
#import <NotificationCenter/NotificationCenter.h>

@interface TodayViewController () <NCWidgetProviding>

@property (weak, nonatomic) IBOutlet UILabel *URLLabel;
@property (weak, nonatomic) IBOutlet UILabel *TitleLabel;
@property (weak, nonatomic) IBOutlet UIView *BottomView;

@property (weak, nonatomic) IBOutlet UIButton *btnBrowser;
@property (weak, nonatomic) IBOutlet UIButton *btnRequest;
@property (weak, nonatomic) IBOutlet UIButton *btnDownload;

@end

@implementation TodayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _btnBrowser.enabled = NO;
    _btnRequest.enabled = NO;
    _btnDownload.enabled = NO;
    
    // btn样式
    [self configBtnStyle];
    
    // 收起
    self.extensionContext.widgetLargestAvailableDisplayMode = NCWidgetDisplayModeExpanded;
    
    // URL
    NSString *pasteboardString = [UIPasteboard generalPasteboard].string;
    self.URLLabel.text = pasteboardString;
    [self configBtnEnable:pasteboardString];
    
    // 请求URl，提取<title>标签
    if ([pasteboardString hasPrefix:@"http://"] || [pasteboardString hasPrefix:@"https://"]) {
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:pasteboardString] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:10];
            NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:urlRequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                
                NSString *title = @"";
                
                NSString *result = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                if (result && result.length) {
                    // <title>。。</title>
                    NSArray *regexResult = [[self regexTitle] matchesInString:result options:0 range:NSMakeRange(0, result.length)];
                    if (regexResult && regexResult.count) {
                        NSTextCheckingResult *rs = regexResult.firstObject;
                        title = [result substringWithRange:NSMakeRange(rs.range.location + 7, rs.range.length-15)];
                    }
                }
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.TitleLabel.textColor = [UIColor blackColor];
                    self.TitleLabel.text = title;
                });
            }];
            [task resume];
        });
    } else {
        self.TitleLabel.textColor = [UIColor darkGrayColor];
        self.TitleLabel.text = @"不是一个有效的网址";
    }
}

- (void)configBtnStyle {
    _btnBrowser.layer.cornerRadius = 5;
    _btnBrowser.layer.borderWidth = 1;
    _btnBrowser.layer.borderColor = [UIColor darkGrayColor].CGColor;
    
    _btnRequest.layer.cornerRadius = 5;
    _btnRequest.layer.borderWidth = 1;
    _btnRequest.layer.borderColor = [UIColor darkGrayColor].CGColor;
    
    _btnDownload.layer.cornerRadius = 5;
    _btnDownload.layer.borderWidth = 1;
    _btnDownload.layer.borderColor = [UIColor darkGrayColor].CGColor;
}

- (void)configBtnEnable:(NSString *)str {
    if ([str hasPrefix:@"http://"] || [str hasPrefix:@"https://"]) {
        _btnBrowser.enabled = YES;
        _btnRequest.enabled = YES;
        _btnDownload.enabled = YES;
    } else if ([str hasPrefix:@"thunder://"]) {
        _btnDownload.enabled = YES;
    }
}

- (IBAction)browserAction:(UIButton *)sender {
    [self.extensionContext openURL:[NSURL URLWithString:[@"FloAPPBrowser://" stringByAppendingString:_URLLabel.text]] completionHandler:nil];
}
- (IBAction)requestAction:(UIButton *)sender {
    [self.extensionContext openURL:[NSURL URLWithString:[@"FloAPPRequest://" stringByAppendingString:_URLLabel.text]] completionHandler:nil];
}
- (IBAction)downloadAction:(UIButton *)sender {
    [self.extensionContext openURL:[NSURL URLWithString:[@"FloAPPDownload://" stringByAppendingString:_URLLabel.text]] completionHandler:nil];
}

//匹配<title>。。</title>
- (NSRegularExpression *)regexTitle {
    static NSRegularExpression *regex;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        regex = [NSRegularExpression regularExpressionWithPattern:@"<title>[\\s\\S]*?</title>" options:kNilOptions error:NULL];
    });
    return regex;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - NCWidgetProviding代理
- (void)widgetPerformUpdateWithCompletionHandler:(void (^)(NCUpdateResult))completionHandler {
    // Perform any setup necessary in order to update the view.
    
    // If an error is encountered, use NCUpdateResultFailed
    // If there's no update required, use NCUpdateResultNoData
    // If there's an update, use NCUpdateResultNewData
    
    NSString *pasteboardString = [UIPasteboard generalPasteboard].string;
    if ([self.URLLabel.text isEqualToString:pasteboardString]) {
        completionHandler(NCUpdateResultNoData);
    } else {
        self.URLLabel.text = pasteboardString;
        [self configBtnEnable:pasteboardString];
        
        if ([pasteboardString hasPrefix:@"http://"] || [pasteboardString hasPrefix:@"https://"]) {
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:pasteboardString] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:10];
                NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:urlRequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                    
                    NSString *title = @"";
                    
                    NSString *result = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                    if (result && result.length) {
                        // <title>。。</title>
                        NSArray *regexResult = [[self regexTitle] matchesInString:result options:0 range:NSMakeRange(0, result.length)];
                        if (regexResult && regexResult.count) {
                            NSTextCheckingResult *rs = regexResult.firstObject;
                            title = [result substringWithRange:NSMakeRange(rs.range.location + 7, rs.range.length-15)];
                        }
                    }
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        self.TitleLabel.textColor = [UIColor blackColor];
                        self.TitleLabel.text = title;
                        completionHandler(NCUpdateResultNewData);
                    });
                }];
                [task resume];
            });
        } else {
            self.TitleLabel.textColor = [UIColor darkGrayColor];
            self.TitleLabel.text = @"不是一个有效的网址";
        }
    }
}

- (void)widgetActiveDisplayModeDidChange:(NCWidgetDisplayMode)activeDisplayMode withMaximumSize:(CGSize)maxSize {
    if (activeDisplayMode == NCWidgetDisplayModeCompact) {
        self.preferredContentSize = CGSizeMake([UIScreen mainScreen].bounds.size.width, 110);
    } else {
        self.preferredContentSize = CGSizeMake([UIScreen mainScreen].bounds.size.width, 160);
    }
}

@end
