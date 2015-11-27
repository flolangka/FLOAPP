//
//  FLOMessageTableViewCell.h
//  XMPPChat
//
//  Created by admin on 15/11/27.
//  Copyright © 2015年 Flolangka. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FLOMessageTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *imageV;
@property (weak, nonatomic) IBOutlet UILabel *titleL;
@property (weak, nonatomic) IBOutlet UILabel *detailL;
@property (weak, nonatomic) IBOutlet UILabel *timeL;

@end
