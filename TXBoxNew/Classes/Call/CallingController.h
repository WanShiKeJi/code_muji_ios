//
//  CallingController.h
//  TXBoxNew
//
//  Created by Naron on 15/4/21.
//  Copyright (c) 2015年 playtime. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CallingController : UIViewController
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;    //姓名
@property (weak, nonatomic) IBOutlet UILabel *numberLabel;  //号码
@property (weak, nonatomic) IBOutlet UILabel *timeLength;   //通话时长
-(IBAction)cut:(UIButton *)sender;  //挂断
@end
