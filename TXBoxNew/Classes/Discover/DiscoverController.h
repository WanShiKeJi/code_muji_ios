//
//  DiscoverController.h
//  TXBoxNew
//
//  Created by Naron on 15/4/16.
//  Copyright (c) 2015年 playtime. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DiscoverController : UITableViewController
@property (weak, nonatomic) IBOutlet UILabel *callInVibrate;//来电时振动
@property (weak, nonatomic) IBOutlet UILabel *connectVibrate;//接通时振动
@property (weak, nonatomic) IBOutlet UISwitch *callInSwitch;//
@property (weak, nonatomic) IBOutlet UISwitch *connectSwitch;
@property (weak, nonatomic) IBOutlet UILabel *appVersion;//app版本
@property (weak, nonatomic) IBOutlet UILabel *firmwareVersion;//固件版本
@property (weak, nonatomic) IBOutlet UILabel *nowAppVersion;//now app版本
@property (weak, nonatomic) IBOutlet UIImageView *appVersionImg;
@property (weak, nonatomic) IBOutlet UIImageView *firmwareImg;
@property (weak, nonatomic) IBOutlet UILabel *nowFirmwearVson;//now固件版本
@property (weak, nonatomic) IBOutlet UILabel *setting;//设置
@property BOOL isShow;

@end
