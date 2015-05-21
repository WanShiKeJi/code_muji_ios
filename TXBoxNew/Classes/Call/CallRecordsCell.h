//
//  CallRecordsCell.h
//  TXBoxNew
//
//  Created by Naron on 15/4/13.
//  Copyright (c) 2015年 playtime. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CallRecordsCell : UITableViewCell
{
    UIImageView *_view;
}
@property (weak, nonatomic) IBOutlet UILabel *hisName;//对方在通讯录中的名字，没有存则不显示
@property (weak, nonatomic) IBOutlet UILabel *hisNumber;//对方号码
@property (weak, nonatomic) IBOutlet UIImageView *callDirection;//电话的方向
@property (weak, nonatomic) IBOutlet UILabel *callLength;//通话时长
@property (weak, nonatomic) IBOutlet UILabel *callBeginTime;//通话开始时间
@property (weak, nonatomic) IBOutlet UILabel *hisHome;//对方归属地
@property (weak, nonatomic) IBOutlet UILabel *hisOperator;//对方的归属运营商

@property (weak, nonatomic) IBOutlet UIButton *CallButton;
@property (weak, nonatomic) IBOutlet UIButton *MsgButton;
@property (weak, nonatomic) IBOutlet UIButton *PersonButton;

- (IBAction)callBtn:(UIButton *)sender;



@end
