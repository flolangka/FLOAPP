//
//  FLOWorkItemViewModel.m
//  FLOAPP
//
//  Created by 360doc on 2018/5/10.
//  Copyright © 2018年 Flolangka. All rights reserved.
//

#import "FLOWorkItemViewModel.h"
#import "FLOWorkListCell.h"
#import "WorkList+CoreDataClass.h"

@implementation FLOWorkItemViewModel

- (instancetype)initWithItem:(WorkList *)item {
    if (!item || !Def_CheckStringClassAndLength(item.title)) {
        return nil;
    }
    
    self = [super init];
    if (self) {
        _item = item;
        
        [self configAttribute];
    }
    return self;
}

/**
 item 修改后更新显示内容
 */
- (void)update {
    [self configAttribute];
}

- (void)configAttribute {
    //标题
    _title = _item.title;
    
    //时间
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy.MM.dd"];
    
    NSString *timeStr = [formatter stringFromDate:_item.startTime];
    if (_item.status != 0) {
        timeStr = [timeStr stringByAppendingFormat:@"-%@", [formatter stringFromDate:_item.endTime]];
    }
    _timeStr = timeStr;
    
    //编辑按钮
    _editBtnHide = _item.status != 0;
    
    //undo、redo
    _titleRightBtnTitle = _item.status == 0 ? @"undo" : @"redo";
    
    //描述
    _desc = _item.desc;
    
    //目标
    _targets = [_item.items flo_objectFromJSONData];
    _targetsStatus = [_item.itemsStatus flo_objectFromJSONData];
    _targetBtnEnable = _item.status == 0;
    
    //在todo时才显示完成按钮
    if (_item.status == 0) {
        BOOL b = YES;
        for (NSNumber *number in _targetsStatus) {
            if (b) {
                b = number.boolValue;
            } else {
                break;
            }
        }
        _showFinishBtn = b;
    } else {
        _showFinishBtn = NO;
    }
    
    _cellHeight = [FLOWorkListCell heightWithViewModel:self];
}

@end
