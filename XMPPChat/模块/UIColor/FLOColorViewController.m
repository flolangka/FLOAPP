//
//  FLOColorViewController.m
//  XMPPChat
//
//  Created by 沈敏 on 16/8/16.
//  Copyright © 2016年 Flolangka. All rights reserved.
//

#import "FLOColorViewController.h"

@interface FLOColorViewController () <UITextFieldDelegate>

{
    UIView *RGBContentV;
    UITextField *textField_R;
    UITextField *textField_G;
    UITextField *textField_B;
    UILabel *RGBAlphaLabel;
    UISlider *RGBAlphaSlider;
    NSArray *arrNum;
    
    UIView *hexContentV;
    UITextField *textField_hex;
    UISlider *hexAlphaSlider;
    UILabel *hexAlphaLabel;
    NSArray *arrHex;
    
    UIView *grayContentV;
    UILabel *grayLabel;
    UISlider *graySlider;
    UILabel *grayAlphaLabel;
    UISlider *grayAlphaSlider;
}

@end

@implementation FLOColorViewController

- (instancetype)init {
    self = [super init];
    if (self) {
        self.title = @"UIColor";
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    arrHex = @[@"0",@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9",@"a",@"b",@"c",@"d",@"e",@"f",@"A",@"B",@"C",@"D",@"E",@"F"];
    arrNum = @[@"0",@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9"];
    
    self.tableView.bounces = NO;
    [self configTableViewHeaderView];
}

- (void)configTableViewHeaderView {

    {   //RGBA
        RGBContentV = [[UIView alloc] initWithFrame:CGRectMake(0, 0, DEVICE_SCREEN_WIDTH, 80)];
        
        textField_R = [[UITextField alloc] initWithFrame:CGRectMake(16, 10, 50, 30)];
        textField_R.layer.borderColor = [UIColor lightGrayColor].CGColor;
        textField_R.layer.borderWidth = 1.;
        textField_R.placeholder = @"255";
        textField_R.text = @"255";
        textField_R.delegate = self;
        
        
        textField_G = [[UITextField alloc] initWithFrame:CGRectMake(16+50+16, 10, 50, 30)];
        textField_G.layer.borderColor = [UIColor lightGrayColor].CGColor;
        textField_G.layer.borderWidth = 1.;
        textField_G.placeholder = @"255";
        textField_G.text = @"255";
        textField_G.delegate = self;
        
        
        textField_B = [[UITextField alloc] initWithFrame:CGRectMake(16+50+16+50+16, 10, 50, 30)];
        textField_B.layer.borderColor = [UIColor lightGrayColor].CGColor;
        textField_B.layer.borderWidth = 1.;
        textField_B.placeholder = @"255";
        textField_B.text = @"0";
        textField_B.delegate = self;
        
        RGBAlphaLabel = [[UILabel alloc] initWithFrame:CGRectMake(16, 50, 100, 17)];
        RGBAlphaLabel.font = [UIFont systemFontOfSize:14];
        
        RGBAlphaSlider = [[UISlider alloc] initWithFrame:CGRectMake(140, 40, DEVICE_SCREEN_WIDTH-150, 30)];
        RGBAlphaSlider.value = 1;
        [RGBAlphaSlider addTarget:self action:@selector(RGBAlphaSliderValueChanged:) forControlEvents:UIControlEventValueChanged];
        
        [RGBContentV addSubview:textField_R];
        [RGBContentV addSubview:textField_G];
        [RGBContentV addSubview:textField_B];
        [RGBContentV addSubview:RGBAlphaLabel];
        [RGBContentV addSubview:RGBAlphaSlider];
        
        [self RGBAlphaSliderValueChanged:nil];
    }
    {   //0x000000A
        hexContentV = [[UIView alloc] initWithFrame:CGRectMake(0, 80, DEVICE_SCREEN_WIDTH, 60)];
        
        textField_hex = [[UITextField alloc] initWithFrame:CGRectMake(16, 5, 100, 30)];
        textField_hex.layer.borderColor = [UIColor lightGrayColor].CGColor;
        textField_hex.layer.borderWidth = 1.;
        textField_hex.placeholder = @"0x000000";
        textField_hex.text = @"0x0dad51";
        textField_hex.delegate = self;
        
        hexAlphaLabel = [[UILabel alloc] initWithFrame:CGRectMake(16, 40, 100, 17)];
        hexAlphaLabel.font = [UIFont systemFontOfSize:14];
        
        hexAlphaSlider = [[UISlider alloc] initWithFrame:CGRectMake(140, 15, DEVICE_SCREEN_WIDTH-150, 30)];
        hexAlphaSlider.value = 0.5;
        [hexAlphaSlider addTarget:self action:@selector(hexAlphaSliderValueChanged:) forControlEvents:UIControlEventValueChanged];
        
        [hexContentV addSubview:textField_hex];
        [hexContentV addSubview:hexAlphaLabel];
        [hexContentV addSubview:hexAlphaSlider];
        
        [self hexAlphaSliderValueChanged:nil];
    }
    {   //grayscaleA
        grayContentV = [[UIView alloc] initWithFrame:CGRectMake(0, 140, DEVICE_SCREEN_WIDTH, 60)];
        
        grayLabel = [[UILabel alloc] initWithFrame:CGRectMake(16, 6.5, 150-30, 17)];
        grayLabel.font = [UIFont systemFontOfSize:14];
        
        graySlider = [[UISlider alloc] initWithFrame:CGRectMake(140, 0, DEVICE_SCREEN_WIDTH - 150, 30)];
        graySlider.value = 0.5;
        [graySlider addTarget:self action:@selector(graySliderValueChanged:) forControlEvents:UIControlEventValueChanged];
        
        grayAlphaLabel = [[UILabel alloc] initWithFrame:CGRectMake(16, 6.5+30, 150-30, 17)];
        grayAlphaLabel.font = [UIFont systemFontOfSize:14];
        
        grayAlphaSlider = [[UISlider alloc] initWithFrame:CGRectMake(140, 30, DEVICE_SCREEN_WIDTH - 150, 30)];
        grayAlphaSlider.value = 0.8;
        [grayAlphaSlider addTarget:self action:@selector(graySliderValueChanged:) forControlEvents:UIControlEventValueChanged];
        
        [grayContentV addSubview:grayLabel];
        [grayContentV addSubview:graySlider];
        [grayContentV addSubview:grayAlphaLabel];
        [grayContentV addSubview:grayAlphaSlider];
        
        [self graySliderValueChanged:nil];
    }
    
    UIView *headerV = [[UIView alloc] initWithFrame:CGRectMake(0, 0, DEVICE_SCREEN_WIDTH, 200)];
    [headerV addSubview:RGBContentV];
    [headerV addSubview:hexContentV];
    [headerV addSubview:grayContentV];
    
    self.tableView.tableHeaderView = headerV;
}

- (void)RGBAlphaSliderValueChanged:(UISlider *)slider {
    RGBAlphaLabel.text = [NSString stringWithFormat:@"Alpha   %.2f", RGBAlphaSlider.value];
    
    @try {
        int r = textField_R.text.length > 0 ? [textField_R.text intValue] : 0;
        int g = textField_G.text.length > 0 ? [textField_G.text intValue] : 0;
        int b = textField_B.text.length > 0 ? [textField_B.text intValue] : 0;
        RGBContentV.backgroundColor = COLOR_RGBAlpha(r, g, b, RGBAlphaSlider.value);
    } @catch (NSException *exception) {
    } @finally {
    }
    
}

- (void)hexAlphaSliderValueChanged:(UISlider *)slider {
    hexAlphaLabel.text = [NSString stringWithFormat:@"Alpha   %.2f", hexAlphaSlider.value];
    
    if ([textField_hex.text hasPrefix:@"0x"] && textField_hex.text.length == 8) {
        @try {
            //十六进制转十进制
            NSInteger r = strtoul([[textField_hex.text substringWithRange:NSMakeRange(2, 2)] UTF8String],0,16);
            NSInteger g = strtoul([[textField_hex.text substringWithRange:NSMakeRange(4, 2)] UTF8String],0,16);
            NSInteger b = strtoul([[textField_hex.text substringWithRange:NSMakeRange(6, 2)] UTF8String],0,16);
            hexContentV.backgroundColor = COLOR_RGBAlpha(r, g, b, hexAlphaSlider.value);
        } @catch (NSException *exception) {
            textField_hex.text = @"0x000000";
            [self hexAlphaSliderValueChanged:nil];
        } @finally {
        }
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    
    if (textField == textField_hex) {
        [self hexAlphaSliderValueChanged:nil];
    } else {
        [textField resignFirstResponder];
        if (textField_R.text.length > 0 && textField_G.text.length > 0 && textField_B.text.length > 0) {
            [self RGBAlphaSliderValueChanged:nil];
        }
    }
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if (textField == textField_hex) {
        if ([string isEqualToString:@""] && textField.text.length < 3) {
            return NO;
        } else if (![string isEqualToString:@""]) {
            if (textField.text.length > 7) {
                return NO;
            } else if (![arrHex containsObject:string]) {
                return NO;
            }
        }
    } else if (![string isEqualToString:@""])  {
        if (textField.text.length > 2) {
            return NO;
        } else if (![arrNum containsObject:string]) {
            return NO;
        }
    }
    
    return YES;
}

- (void)graySliderValueChanged:(UISlider *)slider {
    grayLabel.text = [NSString stringWithFormat:@"grayScale   %.2f", graySlider.value];
    grayAlphaLabel.text = [NSString stringWithFormat:@"Alpha   %.2f", grayAlphaSlider.value];
    grayContentV.backgroundColor = [UIColor colorWithWhite:graySlider.value alpha:grayAlphaSlider.value];
}

#pragma mark - tableView
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 17;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
        
        UIView *fillColorV = [[UIView alloc] initWithFrame:CGRectMake(DEVICE_SCREEN_WIDTH-80, 0, 80, 60)];
        fillColorV.tag = 1000;
        [cell.contentView addSubview:fillColorV];
        
        UILabel *colorNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(16, 0, DEVICE_SCREEN_WIDTH-32-80, 60)];
        colorNameLabel.tag = 1001;
        [cell.contentView addSubview:colorNameLabel];
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    UIView *fillColorV = [cell.contentView viewWithTag:1000];
    UILabel *colorNameLabel = [cell.contentView viewWithTag:1001];
    
    switch (indexPath.row) {
        case 0:
        {
            colorNameLabel.text = @"blackColor";
            fillColorV.backgroundColor = [UIColor blackColor];
        }
            break;
        case 1:
        {
            colorNameLabel.text = @"darkGrayColor";
            fillColorV.backgroundColor = [UIColor darkGrayColor];
        }
            break;
        case 2:
        {
            colorNameLabel.text = @"lightGrayColor";
            fillColorV.backgroundColor = [UIColor lightGrayColor];
        }
            break;
        case 3:
        {
            colorNameLabel.text = @"whiteColor";
            fillColorV.backgroundColor = [UIColor whiteColor];
        }
            break;
        case 4:
        {
            colorNameLabel.text = @"grayColor";
            fillColorV.backgroundColor = [UIColor grayColor];
        }
            break;
        case 5:
        {
            colorNameLabel.text = @"redColor";
            fillColorV.backgroundColor = [UIColor redColor];
        }
            break;
        case 6:
        {
            colorNameLabel.text = @"greenColor";
            fillColorV.backgroundColor = [UIColor greenColor];
        }
            break;
        case 7:
        {
            colorNameLabel.text = @"blueColor";
            fillColorV.backgroundColor = [UIColor blueColor];
        }
            break;
        case 8:
        {
            colorNameLabel.text = @"cyanColor";
            fillColorV.backgroundColor = [UIColor cyanColor];
        }
            break;
        case 9:
        {
            colorNameLabel.text = @"yellowColor";
            fillColorV.backgroundColor = [UIColor yellowColor];
        }
            break;
        case 10:
        {
            colorNameLabel.text = @"magentaColor";
            fillColorV.backgroundColor = [UIColor magentaColor];
        }
            break;
        case 11:
        {
            colorNameLabel.text = @"orangeColor";
            fillColorV.backgroundColor = [UIColor orangeColor];
        }
            break;
        case 12:
        {
            colorNameLabel.text = @"purpleColor";
            fillColorV.backgroundColor = [UIColor purpleColor];
        }
            break;
        case 13:
        {
            colorNameLabel.text = @"brownColor";
            fillColorV.backgroundColor = [UIColor brownColor];
        }
            break;
        case 14:
        {
            colorNameLabel.text = @"lightTextColor";
            fillColorV.backgroundColor = [UIColor lightTextColor];
        }
            break;
        case 15:
        {
            colorNameLabel.text = @"darkTextColor";
            fillColorV.backgroundColor = [UIColor darkTextColor];
        }
            break;
        case 16:
        {
            colorNameLabel.text = @"groupTableViewBackgroundColor";
            fillColorV.backgroundColor = [UIColor groupTableViewBackgroundColor];
        }
            break;
            
        default:
            break;
    }
    
    return cell;
}

@end
