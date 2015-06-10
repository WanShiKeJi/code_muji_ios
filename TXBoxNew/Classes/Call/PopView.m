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

-(void)initWithTitle:(NSString *)title label:(NSString *)label cancelButtonTitle:(NSString *)cancelTitle otherButtonTitles:(NSString *)sureTitle
{
    self.backgroundColor = [UIColor clearColor];
    self.imgv = [[UIImageView alloc] initWithFrame:self.bounds];
    self.imgv.backgroundColor = RGBACOLOR(246, 246, 246, 1);
    self.imgv.layer.cornerRadius = 5;
    self.imgv.userInteractionEnabled = YES;
    
    
    //标题
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 5, SELF_WIDTH-5*2, 40)];
    titleLabel.font = [UIFont systemFontOfSize:18];
    titleLabel.text = title;
    titleLabel.numberOfLines = 0;
    
    titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    titleLabel.textAlignment = NSTextAlignmentCenter;//居中显示
    [self.imgv addSubview:titleLabel];
    
    //文字
    UILabel *labela = [[UILabel alloc] init];
    labela.frame = CGRectMake(5, 40, SELF_WIDTH-10, 20);
    labela.font = [UIFont systemFontOfSize:14];
    labela.text = label;
    [self.imgv addSubview:labela];
    
    //textField
    self.secondField = [[UITextField alloc] initWithFrame:CGRectMake(5, 65,SELF_WIDTH-10, 30)];
    self.secondField.placeholder = @"138 1380 0000";
    self.secondField.keyboardType = UIKeyboardTypeNumberPad;
    self.secondField.borderStyle = UITextBorderStyleRoundedRect;
    self.secondField.clearButtonMode = UITextFieldViewModeWhileEditing;
    [self.secondField becomeFirstResponder];
    //设置格式化输入
    self.secondField.numericFormatter = [AKNumericFormatter formatterWithMask:@"*** **** ****" placeholderCharacter:'*'];

    [self.imgv addSubview:self.secondField];
    //两个按钮
    for (int i= 0; i<2; i++) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setTitleColor:RGBACOLOR(0, 103, 255, 1) forState:UIControlStateNormal];
        button.frame = CGRectMake(SELF_WIDTH/2*i, self.frame.size.height-40, SELF_WIDTH/2, 40);
        [button setTitle:sureTitle forState:UIControlStateNormal];
        button.titleLabel.font = [UIFont systemFontOfSize:18];
        button.tag = i;
        if (i == 0) {
            [button setTitle:cancelTitle forState:UIControlStateNormal];
        }
        
        [button addTarget:self action:@selector(buttonClicks:) forControlEvents:UIControlEventTouchUpInside];
        [self.imgv addSubview:button];
    }
    
    //竖线
    UILabel *lineA =[[UILabel alloc] initWithFrame:CGRectMake(0, self.frame.size.height-39, self.frame.size.width, 1)];
    lineA.backgroundColor = [UIColor blackColor];
    lineA.alpha = .17;
    [self.imgv addSubview:lineA];
    
    //竖线
    UILabel *line =[[UILabel alloc] initWithFrame:CGRectMake(SELF_WIDTH/2, self.frame.size.height-38, 1, 39)];
    line.backgroundColor = [UIColor blackColor];
    line.alpha = .17;
    [self.imgv addSubview:line];
    
    [self addSubview:self.imgv];
}

-(void)buttonClicks:(UIButton *)btn
{
    
    if (btn.tag == 0) {
        
        [self.delegate resaultsButtonClick:btn textField:self.secondField];
        VCLog(@"remove");
    }else
    {
        VCLog(@"click sure");
        [self.delegate resaultsButtonClick:btn textField:self.secondField];
    }
    
    
    
}


@end
