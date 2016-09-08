//
//  FLOFontSizeViewController.m
//  XMPPChat
//
//  Created by 沈敏 on 16/5/9.
//  Copyright © 2016年 Flolangka. All rights reserved.
//

#import "FLOFontSizeViewController.h"

@interface FLOFontSizeViewController ()<UIPickerViewDelegate, UIPickerViewDataSource>

{
    UITextField *textField;
    UITextField *sizeTF;
    UILabel *fontLabel;
    
    UIButton *showBtn;
    UIView *pickerBackV;
    UIPickerView *pickerV;
    
    UILabel *resultLabel;
    UILabel *indicatorLabel;
    
    NSMutableArray *dataArr;
}

@end

@implementation FLOFontSizeViewController

- (instancetype)init {
    self = [super init];
    if (self) {
        self.title = @"FontSize";
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    dataArr = [NSMutableArray arrayWithArray:[UIFont familyNames]];
    [dataArr insertObject:@"SystemFont" atIndex:0];
    [dataArr insertObject:@"BoldSystemFont" atIndex:1];
    self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    
    textField = [[UITextField alloc] initWithFrame:CGRectMake(8, 8, CGRectGetWidth(self.view.frame)-16, 30)];
    textField.placeholder = @"输入";
    textField.textAlignment = NSTextAlignmentCenter;
    textField.layer.cornerRadius = 10.;
    textField.layer.masksToBounds = YES;
    textField.layer.borderWidth = 1;
    textField.backgroundColor = [UIColor whiteColor];
    
    sizeTF = [[UITextField alloc] initWithFrame:CGRectMake(8, 46, 80, 30)];
    sizeTF.placeholder = @"字号";
    sizeTF.textAlignment = NSTextAlignmentCenter;
    sizeTF.layer.cornerRadius = 10.;
    sizeTF.layer.masksToBounds = YES;
    sizeTF.layer.borderWidth = 1;
    sizeTF.backgroundColor = [UIColor whiteColor];
    
    fontLabel = [[UILabel alloc] initWithFrame:CGRectMake(96, 46, CGRectGetWidth(self.view.frame)-160-8*4, 30)];
    fontLabel.textAlignment = NSTextAlignmentCenter;
    fontLabel.text = @"SystemFont";
    fontLabel.layer.borderWidth = 1;
    fontLabel.layer.cornerRadius = 10.;
    fontLabel.layer.masksToBounds = YES;
    fontLabel.backgroundColor = [UIColor whiteColor];
    
    pickerV = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 200, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame)-230)];
    pickerV.dataSource = self;
    pickerV.delegate = self;
    
    showBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    showBtn.frame = CGRectMake(CGRectGetWidth(self.view.frame)-8-80, 46, 80, 30);
    [showBtn setTitle:@"submit" forState:UIControlStateNormal];
    [showBtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    showBtn.layer.borderWidth = 1.;
    showBtn.layer.cornerRadius = 10.;
    showBtn.layer.masksToBounds = YES;
    showBtn.backgroundColor = [UIColor whiteColor];
    [showBtn addTarget:self action:@selector(showBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    
    resultLabel = [[UILabel alloc] initWithFrame:CGRectMake(8, 90, CGRectGetWidth(self.view.frame)-16, 0)];
    resultLabel.backgroundColor = [UIColor orangeColor];
    indicatorLabel = [[UILabel alloc] initWithFrame:CGRectMake(8, 140, CGRectGetWidth(self.view.frame)-16, 21)];
    indicatorLabel.textAlignment = NSTextAlignmentCenter;
    
    [self.view addSubview:textField];
    [self.view addSubview:sizeTF];
    [self.view addSubview:fontLabel];
    [self.view addSubview:showBtn];
    [self.view addSubview:resultLabel];
    [self.view addSubview:indicatorLabel];
    [self.view addSubview:pickerV];
    
    [pickerV selectRow:17 inComponent:1 animated:NO];
}

- (void)showBtnAction:(UIButton *)sender {
    [textField resignFirstResponder];
    [sizeTF resignFirstResponder];
    
    if (sizeTF.text.length < 1) {
        sizeTF.text = @"17";
    }
    
    if ([fontLabel.text isEqualToString:@"SystemFont"]) {
        resultLabel.font = [UIFont systemFontOfSize:[sizeTF.text floatValue]];
    } else if ([fontLabel.text isEqualToString:@"BoldSystemFont"]) {
        resultLabel.font = [UIFont boldSystemFontOfSize:[sizeTF.text floatValue]];
    }else {
        resultLabel.font = [UIFont fontWithName:fontLabel.text size:[sizeTF.text floatValue]];
    }
    
    resultLabel.text = textField.text.length ? textField.text : @"输入内容啊！！！";
    CGSize size = [resultLabel sizeThatFits:CGSizeMake(CGRectGetWidth(self.view.frame)-16, 21)];
    resultLabel.frame = CGRectMake(8, 84, size.width, size.height);
    resultLabel.center = CGPointMake(CGRectGetMidX(self.view.frame), 112);
    indicatorLabel.text = [NSString stringWithFormat:@"宽:%.1f, 高:%.1f", size.width, size.height];
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 2;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return component ? 30 : dataArr.count;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component {
    return 30;
}

- (nullable NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return component ? [NSString stringWithFormat:@"%ld", row] : dataArr[row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    if (component) {
        sizeTF.text = [NSString stringWithFormat:@"%ld", row];
    } else {
        fontLabel.text = dataArr[row];
    }
    
    [self showBtnAction:nil];
}

@end
