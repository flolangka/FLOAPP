//
//  FLOWebViewController.m
//  XMPPChat
//
//  Created by admin on 15/12/4.
//  Copyright © 2015年 Flolangka. All rights reserved.
//

#import "FLOWebViewController.h"
#import "FLOBookMarkTableViewController.h"
#import <AudioToolbox/AudioToolbox.h>

@interface FLOWebViewController()<UIWebViewDelegate>

{
    UIBarButtonItem *stopItem;
    UIBarButtonItem *refreshItem;
    
    UIBarButtonItem *goBackItem;
    UIBarButtonItem *goFowardItem;
    UIBarButtonItem *bookMarkItem;
    UIBarButtonItem *spaceItem;
}

@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet UIToolbar *toolBar;

@end

@implementation FLOWebViewController

- (void)awakeFromNib
{
    stopItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:@selector(stopWebViewAction)];
    refreshItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refreshWebViewAction)];
    goBackItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"goback"] style:UIBarButtonItemStyleDone target:self action:@selector(goBackAction:)];
    goFowardItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"gofoward"] style:UIBarButtonItemStyleDone target:self action:@selector(goFowardAction:)];
    bookMarkItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemBookmarks target:self action:@selector(bookMarkAction:)];
    spaceItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    [self configStopToolBar];
    [self configRightBarButtonItem];
}

#pragma mark - 配置toolBar
- (void)configStopToolBar
{
    [self.toolBar setItems:@[spaceItem, goBackItem, spaceItem, goFowardItem, spaceItem, stopItem, spaceItem, bookMarkItem, spaceItem]];
}

- (void)configRefreshToolBar
{
    [self.toolBar setItems:@[spaceItem, goBackItem, spaceItem, goFowardItem, spaceItem, refreshItem, spaceItem, bookMarkItem, spaceItem]];
}

#pragma mark - rightBarButtomItem
- (void)configRightBarButtonItem
{
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"screenCapture"] style:UIBarButtonItemStyleDone target:self action:@selector(curtWebView)];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.webView.scrollView.bounces = NO;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:_webViewAddress]]];
    self.title = [_webView stringByEvaluatingJavaScriptFromString:@"document.title"];
}

#pragma mark - 对webView截图
- (void)curtWebView
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *curtImageAction = [UIAlertAction actionWithTitle:@"截取可见区域" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        //播放系统photoShutter声音
        AudioServicesPlaySystemSound(1108);
        
        UIImage *image = [self imageWithView:_webView];
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);

        [self showCurtImage:image];
    }];
    UIAlertAction *curtFullImageAction = [UIAlertAction actionWithTitle:@"截取全部区域" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        //播放系统photoShutter声音
        AudioServicesPlaySystemSound(1108);
        
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
    UIImage *image = nil;
    UIGraphicsBeginImageContext(scrollView.contentSize);
    {
        //保存状态
        CGPoint savedContentOffset = scrollView.contentOffset;
        CGRect savedFrame = scrollView.frame;
        
        //获取图片
        scrollView.contentOffset = CGPointZero;
        scrollView.frame = CGRectMake(0, 0, scrollView.contentSize.width, scrollView.contentSize.height);
        [scrollView.layer renderInContext: UIGraphicsGetCurrentContext()];
        image = UIGraphicsGetImageFromCurrentImageContext();
        
        //复原
        scrollView.contentOffset = savedContentOffset;
        scrollView.frame = savedFrame;
    }
    UIGraphicsEndImageContext();
    
    return image;
}

//将截取得到的图片显示1秒
- (void)showCurtImage:(UIImage *)image
{
    CGSize size = [UIScreen mainScreen].bounds.size;
    
    //背景透明
    UIView *backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
    backgroundView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.6];
    
    //加载截图
    CGSize imageSize = [self sizeWithWidth:image.size.width height:image.size.height];
    CALayer *imageLayer = [[CALayer alloc] init];
    imageLayer.frame = CGRectMake(size.width/2-imageSize.width/2, size.height*0.15, imageSize.width, imageSize.height);
    imageLayer.contents = (id)image.CGImage;
    
    [backgroundView.layer addSublayer:imageLayer];
    [[UIApplication sharedApplication].keyWindow addSubview:backgroundView];
    
    [self performSelector:@selector(hideMaskView) withObject:nil afterDelay:1.0];
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

- (void)hideMaskView
{
    UIView *maskView = [[UIApplication sharedApplication].keyWindow.subviews lastObject];
    [UIView animateWithDuration:0.25 animations:^{
        maskView.transform = CGAffineTransformMakeScale(0.01, 0.01);
    } completion:^(BOOL finished) {
        [maskView removeFromSuperview];
    }];
}

#pragma mark - ToolBar 操作
- (void)goBackAction:(UIBarButtonItem *)sender {
    if([_webView canGoBack]){
        [_webView goBack];
    }
}

- (void)goFowardAction:(UIBarButtonItem *)sender {
    if ([_webView canGoForward]) {
        [_webView goForward];
    }
}

- (void)stopWebViewAction
{
    [_webView stopLoading];
    [self configRefreshToolBar];
}

- (void)refreshWebViewAction
{
    [_webView reload];
}

- (void)bookMarkAction:(UIBarButtonItem *)sender {
    FLOBookMarkTableViewController *bookMarkTVC = [self.storyboard instantiateViewControllerWithIdentifier:@"SBIDBookMarkTableViewController"];
    bookMarkTVC.currentRequestURlStr = [_webView stringByEvaluatingJavaScriptFromString:@"document.location.href"];
    bookMarkTVC.currentDocumentTitle = [_webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    
    [self.navigationController pushViewController:bookMarkTVC animated:YES];
}

#pragma mark - webView Delegate
- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [self configStopToolBar];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self configRefreshToolBar];
    self.title = [_webView stringByEvaluatingJavaScriptFromString:@"document.title"];
}

@end
