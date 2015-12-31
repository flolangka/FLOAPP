//
//  FLOSystemSoundTableViewController.m
//  XMPPChat
//
//  Created by admin on 15/12/31.
//  Copyright © 2015年 Flolangka. All rights reserved.
//

#import "FLOSystemSoundTableViewController.h"
#import <AudioToolbox/AudioToolbox.h>

static NSString * const cellID = @"cellIdentifier";

@interface FLOSystemSoundTableViewController ()

@property (nonatomic, strong) NSArray *displayNames;
@property (nonatomic, strong) NSMutableArray *soundCodes;

@end

@implementation FLOSystemSoundTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self configDataSource];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _displayNames.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellID];
    }
    
    cell.textLabel.text = _displayNames[indexPath.row];
    cell.detailTextLabel.text = _soundCodes[indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    AudioServicesPlaySystemSound([_soundCodes[indexPath.row] unsignedIntValue]);
}

#pragma mark - 配置数据源
- (void)configDataSource
{
    self.displayNames = @[@"new-mail",
                          @"mail-sent",
                          @"Voicemail",
                          @"ReceivedMessage",
                          @"SentMessage",
                          @"alarm",
                          @"low_power",
                          @"sms-received1",
                          @"sms-received2",
                          @"sms-received3",
                          @"sms-received4",
                          @"SMSReceived_Vibrate",
                          @"sms-received1",
                          @"sms-received5",
                          @"sms-received6",
                          @"Voicemail",
                          @"tweet_sent",
                          @"Anticipate",
                          @"Bloom",
                          @"Calypso",
                          @"Choo_Choo",
                          @"Descent",
                          @"Fanfare",
                          @"Ladder",
                          @"Minuet",
                          @"News_Flash",
                          @"Noir",
                          @"Sherwood_Forest",
                          @"Spell",
                          @"Suspense",
                          @"Telegraph",
                          @"Tiptoes",
                          @"Typewriters",
                          @"Update",
                          @"ussd",
                          @"SIMToolkitCallDropped",
                          @"SIMToolkitGeneralBeep",
                          @"SIMToolkitNegativeACK",
                          @"SIMToolkitPositiveACK",
                          @"SIMToolkitSMS",
                          @"Tink",
                          @"ct-busy",
                          @"ct-congestion",
                          @"ct-path-ack",
                          @"ct-error",
                          @"ct-call-waiting",
                          @"ct-keytone2",
                          @"lock",
                          @"unlock",
                          @"FailedUnlock",
                          @"Tink",
                          @"Tock",
                          @"Tock",
                          @"beep-beep",
                          @"RingerChanged",
                          @"photoShutter",
                          @"shake",
                          @"jbl_begin",
                          @"jbl_confirm",
                          @"jbl_cancel",
                          @"begin_record",
                          @"end_record",
                          @"jbl_ambiguous",
                          @"jbl_no_match",
                          @"begin_video_record",
                          @"end_video_record",
                          @"vc~invitation-accepted",
                          @"vc~ringing",
                          @"vc~ended",
                          @"ct-call-waiting",
                          @"vc~ringing",
                          @"dtmf-0",
                          @"dtmf-1",
                          @"dtmf-2",
                          @"dtmf-3",
                          @"dtmf-4",
                          @"dtmf-5",
                          @"dtmf-6.",
                          @"dtmf-7",
                          @"dtmf-8",
                          @"dtmf-9",
                          @"dtmf-star",
                          @"dtmf-pound",
                          @"long_low_short_high",
                          @"short_double_high",
                          @"short_low_high",
                          @"short_double_low",
                          @"short_double_low",
                          @"middle_9_short_double_low",
                          @"Voicemail",
                          @"ReceivedMessage",
                          @"new-mail",
                          @"mail-sent",
                          @"alarm",
                          @"lock",
                          @"lock",
                          @"sms-received1",
                          @"sms-received2",
                          @"sms-received3",
                          @"sms-received4",
                          @"SMSReceived_Vibrate",
                          @"sms-received1",
                          @"sms-received5",
                          @"sms-received6",
                          @"Voicemail",
                          @"Anticipate",
                          @"Bloom",
                          @"Calypso",
                          @"Choo_Choo",
                          @"Descent",
                          @"Fanfare",
                          @"Ladder",
                          @"Minuet",
                          @"News_Flash",
                          @"Noir",
                          @"Sherwood_Forest",
                          @"Spell",
                          @"Suspense",
                          @"Telegraph",
                          @"Tiptoes",
                          @"Typewriters",
                          @"Update",
                          @"RingerVibeChanged",
                          @"SilentVibeChanged",
                          @"Vibrate"
                          ];
    
    
    self.soundCodes = [NSMutableArray array];
    for (int i = 1000; i < 1017; i++) {
        [_soundCodes addObject:[NSString stringWithFormat:@"%d", i]];
    }
    for (int i = 1020; i < 1037; i++) {
        [_soundCodes addObject:[NSString stringWithFormat:@"%d", i]];
    }
    for (int i = 1050; i < 1056; i++) {
        [_soundCodes addObject:[NSString stringWithFormat:@"%d", i]];
    }
    [_soundCodes addObject:@"57"];
    for (int i = 1070; i < 1076; i++) {
        [_soundCodes addObject:[NSString stringWithFormat:@"%d", i]];
    }
    for (int i = 1100; i < 1119; i++) {
        [_soundCodes addObject:[NSString stringWithFormat:@"%d", i]];
    }
    for (int i = 1150; i < 1155; i++) {
        [_soundCodes addObject:[NSString stringWithFormat:@"%d", i]];
    }
    for (int i = 1200; i < 1212; i++) {
        [_soundCodes addObject:[NSString stringWithFormat:@"%d", i]];
    }
    for (int i = 1254; i < 1260; i++) {
        [_soundCodes addObject:[NSString stringWithFormat:@"%d", i]];
    }
    for (int i = 1300; i < 1316; i++) {
        [_soundCodes addObject:[NSString stringWithFormat:@"%d", i]];
    }
    for (int i = 1320; i < 1337; i++) {
        [_soundCodes addObject:[NSString stringWithFormat:@"%d", i]];
    }
    [_soundCodes addObject:@"1350"];
    [_soundCodes addObject:@"1351"];
    [_soundCodes addObject:@"4095"];
}

@end
