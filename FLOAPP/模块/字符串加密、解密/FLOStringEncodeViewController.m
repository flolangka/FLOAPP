//
//  FLOStringEncodeViewController.m
//  FLOAPP
//
//  Created by 沈敏 on 2017/4/29.
//  Copyright © 2017年 Flolangka. All rights reserved.
//

#import "FLOStringEncodeViewController.h"

@interface FLOStringEncodeViewController ()<UIPickerViewDelegate, UIPickerViewDataSource>

@property (weak, nonatomic) IBOutlet UITextView *originalTextV;
@property (weak, nonatomic) IBOutlet UITextView *resultTextV;

@property (weak, nonatomic) IBOutlet UIButton *btnSelect;

@property (nonatomic, strong) UIPickerView *pickerV;
@property (nonatomic, copy) NSArray *dataArr;

@end

@implementation FLOStringEncodeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"字符串加密、解密";
    [self configDataArr];
    
    self.pickerV = [[UIPickerView alloc] initWithFrame:CGRectMake(0, DEVICE_SCREEN_HEIGHT-300-64, DEVICE_SCREEN_WIDTH, 300)];
    _pickerV.dataSource = self;
    _pickerV.delegate = self;
    [self.view addSubview:_pickerV];
    _pickerV.hidden = YES;
    
    [_btnSelect setTitle:_dataArr.firstObject forState:UIControlStateNormal];
    
}
- (void)configDataArr {
    self.dataArr = @[@"1", @"2", @"3"];
}

- (IBAction)selectAction:(UIButton *)sender {
    _pickerV.hidden = !_pickerV.hidden;
    
    [_originalTextV resignFirstResponder];
}
- (IBAction)encodeAction:(UIButton *)sender {
    _pickerV.hidden = YES;
    [_originalTextV resignFirstResponder];
    
    if (_originalTextV.text.length) {
        
    }
}
- (IBAction)decodeAction:(UIButton *)sender {
    _pickerV.hidden = YES;
    [_originalTextV resignFirstResponder];
    
}
- (IBAction)resultToOriginalAction:(UIButton *)sender {
    _pickerV.hidden = YES;
    [_originalTextV resignFirstResponder];
    
    if (_resultTextV.text.length) {
        _originalTextV.text = _resultTextV.text;
        _resultTextV.text = @"";
    }
}

#pragma mark - UIPickerView
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return _dataArr.count;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component {
    return 30;
}

- (nullable NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return _dataArr[row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    [_btnSelect setTitle:_dataArr[row] forState:UIControlStateNormal];
    
    pickerView.hidden = YES;
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
