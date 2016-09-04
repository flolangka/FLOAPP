//
//  FLOTextViewViewController.m
//  XMPPChat
//
//  Created by 沈敏 on 16/9/4.
//  Copyright © 2016年 Flolangka. All rights reserved.
//

#import "FLOTextViewViewController.h"
//#import <YYKit.h>
#import "FLOUtil.h"

@interface FLOTextViewViewController ()

{
    UITextView *textView;
    
    NSString *resetString;
}

@end

@implementation FLOTextViewViewController

- (instancetype)init {
    self = [super init];
    if (self) {
        textView = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, DEVICE_SCREEN_WIDTH, DEVICE_SCREEN_HEIGHT-64)];
        textView.editable = NO;
        textView.font = [UIFont systemFontOfSize:16];
        textView.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    textView.text = _contentText;
    resetString = [NSString stringWithFormat:@"%@", _contentText];
    [self.view addSubview:textView];
    
    
    UIBarButtonItem *arrJson = [[UIBarButtonItem alloc] initWithTitle:@"[...]" style:UIBarButtonItemStyleDone target:self action:@selector(arrJsonAction:)];
    UIBarButtonItem *dicJson = [[UIBarButtonItem alloc] initWithTitle:@"{...}" style:UIBarButtonItemStyleDone target:self action:@selector(dicJsonAction:)];
    UIBarButtonItem *decode = [[UIBarButtonItem alloc] initWithTitle:@"utf-8" style:UIBarButtonItemStyleDone target:self action:@selector(decodeAction:)];
    UIBarButtonItem *reset = [[UIBarButtonItem alloc] initWithTitle:@"复位" style:UIBarButtonItemStyleDone target:self action:@selector(resetAction:)];
    
    self.navigationItem.rightBarButtonItems = @[reset, decode, arrJson, dicJson];
}

- (void)arrJsonAction:(id)sender {
    id resultArr = [textView.text flo_objectFromJSONString];
    if ([resultArr isKindOfClass:[NSArray class]]) {
        textView.text = [resultArr flo_JSONString];
    }
}

- (void)dicJsonAction:(id)sender {
    id resultDic = [textView.text flo_objectFromJSONString];
    if ([resultDic isKindOfClass:[NSDictionary class]]) {
        textView.text = [resultDic flo_JSONString];
    }
}

- (void)decodeAction:(id)sender {
    textView.text = [textView.text stringByRemovingPercentEncoding];
}

- (void)resetAction:(id)sender {
    textView.text = resetString;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
