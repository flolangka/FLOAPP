//
//  FLONotificationTimeTableViewController.m
//  FLOAPP
//
//  Created by 360doc on 2017/12/29.
//  Copyright © 2017年 Flolangka. All rights reserved.
//

#import "FLONotificationTimeTableViewController.h"
#import "NotificationTime+CoreDataClass.h"
#import "APLCoreDataStackManager.h"
#import "FLONotificationTimeAddViewController.h"

#import <Masonry.h>
#import <AVFoundation/AVFoundation.h>
#import <UserNotifications/UserNotifications.h>

@interface FLONotificationTimeTableViewController ()<UIPickerViewDelegate, UIPickerViewDataSource>

@property (nonatomic, strong) NSMutableArray *dataArr;
@property (nonatomic, assign) NSInteger cellRow;    //当前选择声音的cellRow

@property (nonatomic, strong) UIControl *soundPickerMaskV;
@property (nonatomic, strong) UIPickerView *soundPickerV;
@property (nonatomic, copy  ) NSArray *soundDataArr;

@property (nonatomic, strong) AVAudioPlayer *player;

@end

@implementation FLONotificationTimeTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //通知声音
    _soundDataArr = @[@"Default", @"Monody", @"Class_Historian"];
    
    //导航栏
    [self configNav];
}

- (void)viewWillAppear:(BOOL)animated {
    [self initData];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self playerStop];
}

- (void)configNav {
    self.title = @"定时通知";
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addTimeNoti)];
}

- (void)addTimeNoti {
    FLONotificationTimeAddViewController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"SBIDFLONotificationTimeAddViewController"];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)initData {
    //查询数据库
    //建立请求
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"NotificationTime"];
    //读取数据
    NSArray *array = [[APLCoreDataStackManager sharedManager].managedObjectContext executeFetchRequest:request error:nil];
    
    _dataArr = [NSMutableArray arrayWithArray:array];
    [self.tableView reloadData];
}

- (void)musicBtnAction:(UIButton *)sender {
    UIView *sv = sender.superview;
    if (![sv isKindOfClass:[UITableViewCell class]]) {
        sv = sv.superview;
    }
    
    if ([sv isKindOfClass:[UITableViewCell class]]) {
        UITableViewCell *cell = (UITableViewCell *)sv;
        NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
        
        if (indexPath.row < _dataArr.count) {
            //cell高亮
            cell.highlighted = YES;
            
            _cellRow = indexPath.row;
            NotificationTime *obj = _dataArr[_cellRow];
            
            //选中当前声音
            NSInteger pickerIndex = [_soundDataArr indexOfObject:obj.sound];
            if (pickerIndex == NSNotFound) {
                pickerIndex = 0;
            }
            [self.soundPickerV selectRow:pickerIndex inComponent:0 animated:NO];
            self.soundPickerMaskV.hidden = NO;
        }
    }
}

#pragma mark - 懒加载
//全屏蒙层
- (UIControl *)soundPickerMaskV {
    if (!_soundPickerMaskV) {
        _soundPickerMaskV = [[UIControl alloc] initWithFrame:CGRectMake(0, 0, DEVICE_SCREEN_WIDTH, DEVICE_SCREEN_HEIGHT - NAVIGATIONTITLEVIEWHEIGHT)];
        _soundPickerMaskV.backgroundColor = COLOR_RGB3SAMEAlpha(0, 0.2);
        [_soundPickerMaskV addTarget:self action:@selector(maskViewAction:) forControlEvents:UIControlEventTouchUpInside];
        
        [self.view addSubview:_soundPickerMaskV];
        _soundPickerMaskV.hidden = YES;
    }
    
    return _soundPickerMaskV;
}

//滚轮
- (UIPickerView *)soundPickerV {
    if (!_soundPickerV) {
        _soundPickerV = [[UIPickerView alloc] init];
        _soundPickerV.backgroundColor = COLOR_RGB3SAME(255);
        [self.soundPickerMaskV addSubview:_soundPickerV];
        [_soundPickerV mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.soundPickerMaskV);
            make.right.equalTo(self.soundPickerMaskV);
            make.bottom.equalTo(self.soundPickerMaskV);
            make.height.mas_equalTo(230);
        }];
        _soundPickerV.dataSource = self;
        _soundPickerV.delegate = self;
    }
    return _soundPickerV;
}

#pragma mark - UIPickerView Delefate
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return _soundDataArr.count;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component {
    return 30;
}

- (nullable NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return _soundDataArr[row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    //播放并保存
    NSString *soundName = @"";
    if (row > 0) {
        soundName = _soundDataArr[row];
        
        [self playSound:soundName];
    } else {
        [self playerStop];
        
        AudioServicesPlaySystemSound(1007);
    }
    
    NotificationTime *obj = _dataArr[_cellRow];
    obj.sound = soundName;
}

- (void)maskViewAction:(id)sender {
    if (sender == _soundPickerMaskV) {
        if (_cellRow < _dataArr.count) {
            //cell取消高亮
            UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:_cellRow inSection:0]];
            cell.highlighted = NO;
        }
        
        //存库
        [[APLCoreDataStackManager sharedManager].managedObjectContext save:nil];
        
        _soundPickerMaskV.hidden = YES;
    }
    
    [self playerStop];
}

#pragma mark - 播放声音
- (void)playSound:(NSString *)soundName {
    if (_player) {
        [self playerStop];
    }
    
    NSURL *soundFileURL = [[NSBundle mainBundle] URLForResource:soundName withExtension:@"caf"];
    AVAudioPlayer *splayer = [[AVAudioPlayer alloc] initWithContentsOfURL:soundFileURL error:nil];
    self.player = splayer;
    [_player play];
}

- (void)playerStop {
    if (_player) {
        [_player stop];
        _player = nil;
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _dataArr.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellid = @"reuseIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellid];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellid];
        
        // 通知声音按钮
        UIButton *musicBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [cell.contentView addSubview:musicBtn];
        [musicBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(cell.contentView).offset(-15);
            make.centerY.equalTo(cell.contentView);
            make.size.mas_equalTo(CGSizeMake(35, 35));
        }];
        [musicBtn setImage:[UIImage imageNamed:@"music"] forState:UIControlStateNormal];
        [musicBtn addTarget:self action:@selector(musicBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    NotificationTime *obj = _dataArr[indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"%@（%lld时%lld分%lld秒）", obj.title, (obj.time/(60*60)), (obj.time%(60*60))/60, (obj.time%(60*60))%60];
    cell.detailTextLabel.text = obj.body;
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;
}

- (nullable NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    return @"删除";
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [[APLCoreDataStackManager sharedManager].managedObjectContext deleteObject:_dataArr[indexPath.row]];
        [[APLCoreDataStackManager sharedManager].managedObjectContext save:nil];
        
        [_dataArr removeObjectAtIndex:indexPath.row];
        
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NotificationTime *obj = _dataArr[indexPath.row];
    
    //延时推送通知
    UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
    content.sound = Def_CheckStringClassAndLength(obj.sound) ? [UNNotificationSound soundNamed:[NSString stringWithFormat:@"%@.caf", obj.sound]] : [UNNotificationSound defaultSound];
    content.title = obj.title;
    content.body = obj.body;
    
    UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:[NSString stringWithFormat:@"%lld", obj.time] content:content trigger:[UNTimeIntervalNotificationTrigger triggerWithTimeInterval:obj.time repeats:NO]];
    [[UNUserNotificationCenter currentNotificationCenter] addNotificationRequest:request withCompletionHandler:nil];    
}

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
