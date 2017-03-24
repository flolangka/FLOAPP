//
//  FLOAdjustFontSizeViewController.m
//  XMPPChat
//
//  Created by 360doc on 16/8/25.
//  Copyright © 2016年 Flolangka. All rights reserved.
//

#import "FLOAdjustFontSizeViewController.h"
#import "FLOAdjustFontSizeLabel.h"
#import "FLOAdjustFontSizeView.h"
#import "UILabel+FLOUtil.h"
#import "UIView+FLOUtil.h"

@interface FLOAdjustFontSizeViewController () <UITableViewDelegate, UITableViewDataSource>

{
    UITableView *tableview;
    FLOAdjustFontSizeView *adjustFontSizeView;
    
    NSArray *arr_text;
    CGFloat fontSize;
}

@end

@implementation FLOAdjustFontSizeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"调整字号";
    
    arr_text = @[@"预览字体大小",
                 @"拖动下面的滑块，可设置字体大小",
                 @"设置后，会改变聊天、菜单和朋友圈中的字体大小。如果在使用过程中存在问题或意见，可反馈给微信团队。"];
    fontSize = 22;
    
    tableview = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), DEVICE_SCREEN_HEIGHT-64-120) style:UITableViewStylePlain];
    tableview.delegate = self;
    tableview.dataSource = self;
    tableview.backgroundColor = [UIColor groupTableViewBackgroundColor];
    tableview.tableFooterView = [[UIView alloc] init];
    [self.view addSubview:tableview];
    
    __weak UITableView *weakTableview = tableview;
    adjustFontSizeView = [[FLOAdjustFontSizeView alloc] init];
    adjustFontSizeView.frame = CGRectMake(0, DEVICE_SCREEN_HEIGHT-120-64, DEVICE_SCREEN_WIDTH, 120);
    adjustFontSizeView.fontSizeChanged = ^(CGFloat size){
        if (size > 0) {
            fontSize = size;
            [weakTableview reloadData];
        }
    };
    [self.view addSubview:adjustFontSizeView];
}


#pragma mark - tableView
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    FLOAdjustFontSizeLabel *label = [[FLOAdjustFontSizeLabel alloc] init];
    [label flo_adjustBoundsWithText:arr_text[indexPath.row] font:[UIFont systemFontOfSize:fontSize] maxWidth:CGRectGetWidth(tableView.bounds)-10-70 maxHeight:CGFLOAT_MAX];
    return CGRectGetHeight(label.bounds)+15+15;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellID"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cellID"];
        cell.backgroundColor = [UIColor clearColor];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        //初始化Label
        FLOAdjustFontSizeLabel *label = [[FLOAdjustFontSizeLabel alloc] init];
        label.tag = 1000;
        [cell.contentView addSubview:label];
    }
    
    CGFloat screenWidth = CGRectGetWidth(tableView.bounds);
    
    FLOAdjustFontSizeLabel *label = [cell.contentView viewWithTag:1000];
    
    //设置文本，调整size
    [label flo_adjustBoundsWithText:arr_text[indexPath.row] font:[UIFont systemFontOfSize:fontSize] maxWidth:screenWidth-10-70 maxHeight:CGFLOAT_MAX];
    CGRect labelFrame = label.frame;
    
    if (indexPath.row == 0) {
        label.backgroundColor = COLOR_RGB(162, 229, 99);
        labelFrame.origin.x = screenWidth-10-CGRectGetWidth(labelFrame);
        labelFrame.origin.y = 15;
    } else {
        label.backgroundColor = [UIColor whiteColor];
        labelFrame.origin.x = 10;
        labelFrame.origin.y = 15;
    }
    label.frame = labelFrame;
    [label flo_setCornerRadius:5];
    
    return cell;
}

@end
