//
//  ContactsCell.m
//  TXBoxNew
//
//  Created by Naron on 15/4/16.
//  Copyright (c) 2015年 playtime. All rights reserved.
//

#import "ContactsCell.h"
#import "TXSqliteOperate.h"

@implementation ContactsCell

- (void)awakeFromNib {
    
    
}

#pragma mark 信息按钮事件
- (IBAction)msgBtn:(UIButton *)sender
{
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:kKeyboardAndTabViewHide object:self]];
    
}
#pragma mark 拨打电话
- (IBAction)callBtn:(UIButton *)sender
{
    //把姓名号码传过去
    NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:self.nameLabel.text,@"hisName",self.numberLabel.text,@"hisNumber", nil];
    
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:kCallingBtnClick object:self userInfo:dict]];
    
}
#pragma mark 编辑
- (IBAction)editBtn:(UIButton *)sender
{
    //[[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:kKeyboardAndTabViewHide object:self]];
    VCLog(@"edit");
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


#pragma mark-创建上下分割线
- (void)drawRect:(CGRect)rect
{
    for (int i =0; i<2; i++) {
        self.imgView = [[UIImageView alloc]initWithFrame:CGRectMake(10, i*kCellHeight-1, self.contentView.frame.size.width-10, 1)];
        //VCLog(@"h:%F",rect.size.height-1);
        //VCLog(@"w:%f",self.contentView.frame.size.width);
        self.imgView.image = [UIImage imageNamed:@"test.png"];

    }
    
    
    [self.contentView addSubview:self.imgView];
}


@end
