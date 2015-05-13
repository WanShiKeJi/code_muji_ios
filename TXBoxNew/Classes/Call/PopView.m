//
//  PopView.m
//  TXBoxNew
//
//  Created by Naron on 15/5/12.
//  Copyright (c) 2015年 playtime. All rights reserved.
//
#define SELF_WIDTH self.frame.size.width

#import "PopView.h"
#import "NSString+helper.h"
#import "UITextField+AKNumericFormatter.h"
#import "AKNumericFormatter.h"

@implementation PopView


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    
    
}

-(void)initWithTitle:(NSString *)title firstMsg:(NSString *)fmsg secondMsg:(NSString *)smsg cancelButtonTitle:(NSString *)cancelTitle otherButtonTitles:(NSString *)sureTitle
{
    self.backgroundColor = [UIColor clearColor];
    self.imgv = [[UIImageView alloc] initWithFrame:self.bounds];
    self.imgv.backgroundColor = [UIColor whiteColor];
    self.imgv.layer.cornerRadius = 5;
    self.imgv.userInteractionEnabled = YES;
    
    
    //标题
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 5, SELF_WIDTH-5*2, 40)];
    titleLabel.text = title;
    titleLabel.numberOfLines = 0;
    
    titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    titleLabel.textAlignment = NSTextAlignmentCenter;//居中显示
    titleLabel.font = [UIFont systemFontOfSize:14];
    [self.imgv addSubview:titleLabel];
    
    //文字
    //文字
    for (int i= 0; i<2; i++) {
        UILabel *label = [[UILabel alloc] init];
        label.frame = CGRectMake(0, 40, SELF_WIDTH, 20);
        label.font = [UIFont systemFontOfSize:14];
        label.text = fmsg;
        
        if (i==1) {
            label.frame = CGRectMake(0, 90, SELF_WIDTH, 20);
            label.text = smsg;
        }
        
        [self.imgv addSubview:label];
    
    }
    
    //第一个输入框
    self.firstField = [[UITextField alloc] initWithFrame:CGRectMake(0, 60, SELF_WIDTH, 30)];
    self.firstField.borderStyle = UITextBorderStyleRoundedRect;
    self.firstField.delegate = self;
    self.firstField.placeholder = @"abc@163.com";
    self.firstField.keyboardType = UIKeyboardTypeEmailAddress;
    [self.firstField becomeFirstResponder];
    
    //第二个textField
    self.secondField = [[UITextField alloc] initWithFrame:CGRectMake(0, 110,SELF_WIDTH, 30)];
    self.secondField.placeholder = @"138 1380 0000";
    self.secondField.keyboardType = UIKeyboardTypeNumberPad;
    self.secondField.borderStyle = UITextBorderStyleRoundedRect;
    //设置格式化输入
    self.secondField.numericFormatter = [AKNumericFormatter formatterWithMask:@"*** **** ****" placeholderCharacter:'*'];

    
    [self.imgv addSubview:self.firstField];
    [self.imgv addSubview:self.secondField];
    //两个按钮
    for (int i= 0; i<2; i++) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        button.frame = CGRectMake(SELF_WIDTH/2*i, self.frame.size.height-30, SELF_WIDTH/2, 30);
        [button setTitle:sureTitle forState:UIControlStateNormal];
        button.titleLabel.font = [UIFont systemFontOfSize:14];
        button.tag = i;
        if (i == 0) {
            [button setTitle:cancelTitle forState:UIControlStateNormal];
        }
        
        [button addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.imgv addSubview:button];
    }
    
    //竖线
    UILabel *line =[[UILabel alloc] initWithFrame:CGRectMake(SELF_WIDTH/2, self.frame.size.height-28, 1, 25)];
    line.backgroundColor = [UIColor blackColor];
    line.alpha = .27;
    [self.imgv addSubview:line];
    
    [self addSubview:self.imgv];
}

-(void)buttonClick:(UIButton *)btn 
{
    
    if (btn.tag == 0) {
        
        [self.delegate resaultsButtonClick:btn firstField:self.firstField secondField:self.secondField];
        VCLog(@"remove");
    }else
    {
        VCLog(@"click sure");
        [self.delegate resaultsButtonClick:btn firstField:self.firstField secondField:self.secondField];
    }
    
    
    
}


@end
