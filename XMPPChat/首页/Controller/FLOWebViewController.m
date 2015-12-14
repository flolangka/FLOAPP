//
//  FLOWebViewController.m
//  XMPPChat
//
//  Created by admin on 15/12/4.
//  Copyright © 2015年 Flolangka. All rights reserved.
//

#import "FLOWebViewController.h"
#import "FLOBookMarkTableViewController.h"

@interface FLOWebViewController()<UIWebViewDelegate>

@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *stopOrRefreshItem;

@property (nonatomic, strong) UIBarButtonItem *stopItem;
@property (nonatomic, strong) UIBarButtonItem *refreshItem;

@end

@implementation FLOWebViewController

- (void)awakeFromNib
{
    self.stopItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:@selector(stopWebViewAction)];
    self.refreshItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemReply target:self action:@selector(refreshWebViewAction)];
    self.stopOrRefreshItem = _stopItem;
    
    [self configRightBarButtonItem];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:_webViewAddress]]];
    self.title = [_webView stringByEvaluatingJavaScriptFromString:@"document.title"];
}

#pragma mark - rightBarButtomItem
- (void)configRightBarButtonItem
{
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"screenCapture"] style:UIBarButtonItemStyleDone target:self action:@selector(curtWebView)];
}

//对webView截图
- (void)curtWebView
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *curtImageAction = [UIAlertAction actionWithTitle:@"截取可见区域" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        UIImage *image = [self imageWithView:_webView];
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);

        [self showCurtImage:image];
    }];
    UIAlertAction *curtFullImageAction = [UIAlertAction actionWithTitle:@"截取全部区域" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        UIImage *image = [self fullImageWithScrollView:_webView.scrollView];
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
        
        [self showCurtImage:image];
    }];
    [alertController addAction:curtImageAction];
    [alertController addAction:curtFullImageAction];
    [alertController addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

//截取可见区域
- (UIImage *)imageWithView:(UIView *)view
{
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, view.opaque, 0.0f);
    [view drawViewHierarchyInRect:view.bounds afterScreenUpdates:NO];
    UIImage *snapshotImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return snapshotImage;
}

//截取长图
- (UIImage *)fullImageWithScrollView:(UIScrollView *)scrollView
{
    UIGraphicsBeginImageContextWithOptions(scrollView.contentSize, scrollView.opaque, 0.0f);
    [scrollView drawViewHierarchyInRect:scrollView.bounds afterScreenUpdates:NO];
    UIImage *snapshotImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return snapshotImage;
}

//将截取得到的图片显示1秒
- (void)showCurtImage:(UIImage *)image
{
    CGSize size = [UIScreen mainScreen].bounds.size;
    
    //背景透明
    CALayer *backgroundLayer = [[CALayer alloc] init];
    backgroundLayer.frame = CGRectMake(0, 0, size.width, size.height);
    backgroundLayer.backgroundColor = [UIColor groupTableViewBackgroundColor].CGColor;
    backgroundLayer.opacity = 0.4;
    backgroundLayer.cornerRadius = 7.0;
    
    //加载截图
    CGSize imageSize = [self sizeWithWidth:image.size.width height:image.size.height];
    CALayer *imageLayer = [[CALayer alloc] init];
    imageLayer.frame = CGRectMake(size.width/2-imageSize.width/2, size.height*0.15, imageSize.width, imageSize.height);
    imageLayer.contents = (id)image.CGImage;
    
    [backgroundLayer addSublayer:imageLayer];
    [self.view.layer addSublayer:backgroundLayer];
    
    [self performSelector:@selector(hideMaskLayer) withObject:nil afterDelay:1.0];
}

//等比缩放
- (CGSize)sizeWithWidth:(CGFloat)width height:(CGFloat)height
{
    CGSize size = [UIScreen mainScreen].bounds.size;
    
    CGFloat toHeight = size.height*0.7;
    CGFloat scal = height/toHeight;
    CGFloat toWidth = width/scal;
    
    return CGSizeMake(toWidth, toHeight);
}

- (void)hideMaskLayer
{
    CALayer *layer = [self.view.layer.sublayers lastObject];
    [layer removeFromSuperlayer];
}

#pragma mark - ToolBar 操作
- (IBAction)goBackAction:(UIBarButtonItem *)sender {
    if([_webView canGoBack]){
        [_webView goBack];
    }
}

- (IBAction)goFowardAction:(UIBarButtonItem *)sender {
    if ([_webView canGoForward]) {
        [_webView goForward];
    }
}

- (void)stopWebViewAction
{
    [_webView stopLoading];
}

- (void)refreshWebViewAction
{
    [_webView reload];
}

- (IBAction)bookMarkAction:(UIBarButtonItem *)sender {
    FLOBookMarkTableViewController *bookMarkTVC = [self.storyboard instantiateViewControllerWithIdentifier:@"SBIDBookMarkTableViewController"];
    bookMarkTVC.currentRequestURlStr = _webView.request.URL.absoluteString;
    bookMarkTVC.currentDocumentTitle = [_webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    
    [self.navigationController pushViewController:bookMarkTVC animated:YES];
}

#pragma mark - webView Delegate
- (void)webViewDidStartLoad:(UIWebView *)webView
{
    self.stopOrRefreshItem = _stopItem;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    self.stopOrRefreshItem = _refreshItem;
    self.title = [_webView stringByEvaluatingJavaScriptFromString:@"document.title"];
}

@end
