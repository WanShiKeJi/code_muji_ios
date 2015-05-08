//
//  CallRecordsCell.m
//  TXBoxNew
//
//  Created by Naron on 15/4/13.
//  Copyright (c) 2015年 playtime. All rights reserved.
//

#import "CallRecordsCell.h"

@implementation CallRecordsCell

- (void)awakeFromNib {
    // Initialization code
    
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)callBtn:(UIButton *)sender {
    //把姓名号码传过去
    NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:self.hisName.text,@"hisName",self.hisNumber.text,@"hisNumber", nil];
    
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:kCallingBtnClick object:self userInfo:dict]];
    
    
    
    //[self.celldelegate initCallOutView];
    //VCLog(@"call");
}

- (IBAction)mesBtn:(UIButton *)sender {
    
    //NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:self.hisName.text,@"hisName",self.hisNumber.text,@"hisNumber",self.hisHome.text,@"hisHome", nil];
    
    //kKeyboardAndTabViewHide
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:kKeyboardAndTabViewHide object:self]];
    
    //VCLog(@"msg");
}
- (IBAction)personBtn:(UIButton *)sender {
        
    
    
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:kShowAddContacts object:self]];
    //VCLog(@"person");
}


#pragma mark-创建上下分割线
- (void)drawRect:(CGRect)rect
{
    for (int i =0; i<2; i++) {
        _view = [[UIImageView alloc]initWithFrame:CGRectMake(10, -1+i*rect.size.height, rect.size.width-10, 1)];
        _view.image = [UIImage imageNamed:@"test.png"];
    }
    [self.contentView addSubview:_view];
}

@end