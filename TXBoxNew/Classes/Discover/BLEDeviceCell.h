//
//  BLEDeviceCell.h
//  TXBoxNew
//
//  Created by Naron on 15/4/28.
//  Copyright (c) 2015年 playtime. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BLEDeviceCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *isConnection;

@end
