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
#import <WebKit/WebKit.h>

@interface FLOWebViewController()<WKNavigationDelegate>

{
    UIBarButtonItem *stopItem;
    UIBarButtonItem *refreshItem;
    
    UIBarButtonItem *goBackItem;
    UIBarButtonItem *goFowardItem;
    UIBarButtonItem *bookMarkItem;
    UIBarButtonItem *spaceItem;
    
    WKWebView *wkWebView;
    UIProgressView *progressV;
}

@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UIToolbar *toolBar;

@end

@implementation FLOWebViewController

- (void)awakeFromNib {
    [super awakeFromNib];
    
    stopItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:@selector(stopWebViewAction)];
    refreshItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refreshWebViewAction)];
    goBackItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"goback"] style:UIBarButtonItemStyleDone target:self action:@selector(goBackAction:)];
    goFowardItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"gofoward"] style:UIBarButtonItemStyleDone target:self action:@selector(goFowardAction:)];
    bookMarkItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemBookmarks target:self action:@selector(bookMarkAction:)];
    spaceItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
}

- (void)dealloc
{
    wkWebView.navigationDelegate = nil;
    [wkWebView removeObserver:self forKeyPath:@"estimatedProgress"];
    
    NSURLCache * cache = [NSURLCache sharedURLCache];
    [cache removeAllCachedResponses];
    [cache setDiskCapacity:0];
    [cache setMemoryCapacity:0];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    CGSize size = [UIScreen mainScreen].bounds.size;
    wkWebView = [[WKWebView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height-108)];
    [_contentView addSubview:wkWebView];
    wkWebView.navigationDelegate = self;
    wkWebView.scrollView.bounces = NO;
    
    [self configStopToolBar];
    [self configRightBarButtonItem];
    
    //进度条
    [wkWebView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:nil];
    progressV = [[UIProgressView alloc] initWithFrame:CGRectMake(0, 0, size.width, 2)];
    progressV.progressTintColor = [UIColor orangeColor];
    progressV.trackTintColor = [UIColor whiteColor];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [wkWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:_webViewAddress]]];
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

#pragma mark - 截屏按钮
- (void)configRightBarButtonItem
{
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"screenCapture"] style:UIBarButtonItemStyleDone target:self action:@selector(curtWebView)];
}

#pragma mark - 对webView截图
- (void)curtWebView
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *curtImageAction = [UIAlertAction actionWithTitle:@"截取可见区域" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        //播放系统photoShutter声音
        AudioServicesPlaySystemSound(1108);
        
        UIImage *image = [self imageWithView:wkWebView];
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);

        [self showCurtImage:image];
    }];
    UIAlertAction *curtFullImageAction = [UIAlertAction actionWithTitle:@"截取全部区域" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        //播放系统photoShutter声音
        AudioServicesPlaySystemSound(1108);
        
        UIImage *image = [self fullImageWithScrollView:wkWebView.scrollView];
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
    UIImageView *imageV = [[UIImageView alloc] initWithFrame:CGRectMake(size.width/2-imageSize.width/2, size.height*0.15, imageSize.width, imageSize.height)];
    imageV.image = image;
    
    [backgroundView addSubview:imageV];
    [[UIApplication sharedApplication].keyWindow addSubview:backgroundView];
    
    [self performSelector:@selector(hideMaskView:) withObject:imageV afterDelay:1.0];
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

- (void)hideMaskView:(UIView *)view
{
    UIView *maskView = [[UIApplication sharedApplication].keyWindow.subviews lastObject];
    [UIView animateWithDuration:0.25 animations:^{
        view.transform = CGAffineTransformMakeScale(0.01, 0.01);
    } completion:^(BOOL finished) {
        [maskView removeFromSuperview];
    }];
}

#pragma mark - ToolBar 操作
- (void)goBackAction:(UIBarButtonItem *)sender {
    if([wkWebView canGoBack]){
        [wkWebView goBack];
    }
}

- (void)goFowardAction:(UIBarButtonItem *)sender {
    if ([wkWebView canGoForward]) {
        [wkWebView goForward];
    }
}

- (void)stopWebViewAction
{
    [progressV removeFromSuperview];
    
    [wkWebView stopLoading];
    [self configRefreshToolBar];
}

- (void)refreshWebViewAction
{
    [wkWebView reload];
}

- (void)bookMarkAction:(UIBarButtonItem *)sender {
    FLOBookMarkTableViewController *bookMarkTVC = [self.storyboard instantiateViewControllerWithIdentifier:@"SBIDBookMarkTableViewController"];
    bookMarkTVC.currentRequestURlStr = wkWebView.URL.absoluteString;
    bookMarkTVC.currentDocumentTitle = wkWebView.title;
    
    [self.navigationController pushViewController:bookMarkTVC animated:YES];
}

#pragma mark - webView Delegate
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation
{
    progressV.progress = 0.f;
    if (![self.view.subviews containsObject:progressV]) {
        [self.view addSubview:progressV];
    }
    
    [self configStopToolBar];
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation
{
    [progressV removeFromSuperview];
    
    [self configRefreshToolBar];
    self.title = webView.title;
}

- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation
{
    [progressV removeFromSuperview];
    
    [self configRefreshToolBar];
}

#pragma mark - KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"estimatedProgress"]) {
        CGFloat progress = [change[@"new"] floatValue];
        [progressV setProgress:progress animated:YES];
    }
}


@end
