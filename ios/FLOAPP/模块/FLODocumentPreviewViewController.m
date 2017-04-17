//
//  FLODocumentPreviewViewController.m
//  FLOAPP
//
//  Created by 360doc on 2017/4/17.
//  Copyright © 2017年 Flolangka. All rights reserved.
//

#import "FLODocumentPreviewViewController.h"
#import <QuickLook/QuickLook.h>

@interface FLODocumentPreviewViewController () <QLPreviewControllerDataSource>

{
    /**  QuickLook预览页面  */
    QLPreviewController *previewController;
    
    NSURL *fileURL;
}

@end

@implementation FLODocumentPreviewViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    fileURL = [NSURL fileURLWithPath:_docPath];
    
    previewController = [[QLPreviewController alloc] init];
    previewController.dataSource = self;
    previewController.view.frame = CGRectMake(0, 0, DEVICE_SCREEN_WIDTH, DEVICE_SCREEN_HEIGHT-64);
    [self addChildViewController:previewController];
    [self.view addSubview:previewController.view];
    
    [self setNavigationView];
}

-(void)setNavigationView {
    self.title = _docName;
    
    // 出分享按钮
    if ([QLPreviewController canPreviewItem:fileURL]) {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(clickRightbtn)];
    } else {
        [self.navigationItem setRightBarButtonItem:nil];
    }
}


-(void)clickRightbtn {
    UIActivityViewController *vc = [[UIActivityViewController alloc] initWithActivityItems:@[fileURL] applicationActivities:nil];
    [self presentViewController:vc animated:YES completion:nil];
}

#pragma mark - dataSource
/* 设置多个数据时，可以左右滑动切换文档 */
-(NSInteger)numberOfPreviewItemsInPreviewController:(QLPreviewController*)previewController {
    return 1;
}

-(id)previewController:(QLPreviewController*)previewController previewItemAtIndex:(NSInteger)idx {
    return fileURL;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
