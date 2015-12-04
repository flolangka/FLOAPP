//
//  FLOCollectionViewCell.m
//  XMPPChat
//
//  Created by admin on 15/12/4.
//  Copyright © 2015年 Flolangka. All rights reserved.
//

#import "FLOCollectionViewCell.h"

@implementation FLOCollectionViewCell

- (void)awakeFromNib
{
    self.layer.borderWidth = 1.0;
    self.layer.borderColor = [UIColor lightGrayColor].CGColor;
}

@end
