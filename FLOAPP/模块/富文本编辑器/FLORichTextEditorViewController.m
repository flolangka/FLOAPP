//
//  FLORichTextEditorViewController.m
//  FLOAPP
//
//  Created by 360doc on 2017/4/21.
//  Copyright © 2017年 Flolangka. All rights reserved.
//

#import "FLORichTextEditorViewController.h"
#import "FLORichTextEditorView.h"

@interface FLORichTextEditorViewController ()

@property (nonatomic, strong) FLORichTextEditorView *editView;

@end

@implementation FLORichTextEditorViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"富文本编辑器";
    
    self.editView = [[FLORichTextEditorView alloc] initWithFrame:CGRectMake(0, 0, DEVICE_SCREEN_WIDTH, DEVICE_SCREEN_HEIGHT-64)];
    self.editView.weakVC = self;
    [self.view addSubview:_editView];
    
    // Export HTML
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Export" style:UIBarButtonItemStylePlain target:self action:@selector(exportHTML)];
    
    // Set the HTML contents of the editor
    [self.editView setPlaceholder:@"This is a placeholder that will show when there is no content(html)"];
    
    // HTML Content to set in the editor
    NSString *path = [_editView imagePathWithName:@"20170621110200.jpg"];
    NSString *html = [NSString stringWithFormat:@"<!-- This is an HTML comment --><div style=\"text-align: center; \">啦啦啦</div><hr /><h1>啊那空间jksj是你看看</h1><div style=\"text-align: right; \">白色空间啊</div><h2>哈卡看你</h2><h5></h5><div></div><div>    <ul>    <li>白色卡么sah    <br />    </li>    <li>那我看看    <br />    </li>    </ul>    </div>    <div>    <ol>    <li>你是卡看    <br />    </li>    <li>是你那我看看看看看    <br />    </li>    </ol>    <div>    <hr />    </div>    </div>    <div></div>    <div style=\"text-align: center;\">设计款面膜 几十年就说你就能节省空间是哪家阿爸近几年南京周边J你你你在北京阿基诺三北京时间</div>    <div>那我看看</div>    <blockquote style=\"margin: 0px 0px 0px 40px;\">    <div>你是卡看</div>    </blockquote>    <div><strike>发哈哈哈哈哈哈</strike>    </div>    <div style=\"text-align: center; \"><u>法国哈哈哈哈</u>    </div>    <div style=\"text-align: center; \"><u>规划局缴<sup>亘古不变吧</sup></u>    </div>    <div style=\"text-align: left;\"><u>法国哈哈哈</u>规划好后<sub>的更哈哈哈哈哈健康的身体</sub>健康可口的饭菜都是我最爱的人也在看不是</div>    <div style=\"text-align: left;\">好纠结<b>很久经济和环境</b><i>国际经济</i>    </div>    <div style=\"text-align: left;\"><i>国际经济</i><a href=\"http://fgh.com\">超链接</a>啦啦啦啦</div>    <div style=\"text-align: left;\">    <img style=\"max-width:300px;\" src=\"%@\" alt=\"img\">    <br />    </div>    <div style=\"text-align: left;\">    <br />    </div>    <div style=\"text-align: left;\">    <hr />    <h3 style=\"text-align: center; \">end</h3>    <div>    <br />    </div>    </div>", path];
    [self.editView setHTML:html];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    //Add observers for keyboard showing or hiding notifications
    [[NSNotificationCenter defaultCenter] addObserver:_editView selector:@selector(keyboardWillShowOrHide:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:_editView selector:@selector(keyboardWillShowOrHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    //Remove observers for keyboard showing or hiding notifications
    [[NSNotificationCenter defaultCenter] removeObserver:_editView name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:_editView name:UIKeyboardWillHideNotification object:nil];
}

- (void)exportHTML {
    [self.editView getHTML:^(NSString *html) {
        DLog(@"%@", html);
    }];
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
