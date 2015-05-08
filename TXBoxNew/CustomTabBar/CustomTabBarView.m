//
//  CustomTabBarView.m
//  TXBoxNew
//
//  Created by Naron on 15/4/22.
//  Copyright (c) 2015年 playtime. All rights reserved.
//

#import "CustomTabBarView.h"


@implementation CustomTabBarView


- (void)drawRect:(CGRect)rect {
    
    //添加4个button
    [self creatButtonWithNormalName:@"icon_call24"andSelectName:@"icon_up24"andTitle:@"电话"andIndex:0];
    [self creatButtonWithNormalName:@"icon_message24"andSelectName:@"icon_message24selected"andTitle:@"信息"andIndex:1];
    [self creatButtonWithNormalName:@"icon_person24"andSelectName:@"icon_person24selected"andTitle:@"通讯录"andIndex:2];
    [self creatButtonWithNormalName:@"icon_discovery24"andSelectName:@"icon_discovery24selected"andTitle:@"发现"andIndex:3];
    //添加呼叫button
    [self addCallBtn];
    
}

//创建button
- (void)creatButtonWithNormalName:(NSString *)normal andSelectName:(NSString *)selected andTitle:(NSString *)title andIndex:(int)index
{
    //初始化button
    CustomTabBarBtn *button = [CustomTabBarBtn buttonWithType:UIButtonTypeCustom];
    button.exclusiveTouch = YES;
    button.highlighted = NO;
    button.tag = index;
    
    //设置frame
    CGFloat buttonW = self.frame.size.width / 4.f;
    CGFloat buttonH = self.frame.size.height;
    button.frame = CGRectMake(buttonW *index, 0, buttonW, buttonH);
    
    //设置图片，文字
    [button setImage:[UIImage imageNamed:normal] withTitle:title forState:UIControlStateNormal];
    [button setImage:[UIImage imageNamed:selected] withTitle:title forState:UIControlStateSelected];
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [button setTitleColor:RGBACOLOR(0, 174, 154, 1) forState:UIControlStateSelected];
    button.titleLabel.font = [UIFont systemFontOfSize:10];// 设置标题的字体大小
    
    //事件
    [button addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    
    //对齐
    button.imageView.contentMode = UIViewContentModeCenter; // 让图片在按钮内居中
    button.titleLabel.textAlignment = NSTextAlignmentCenter; // 让标题在按钮内居中
    
    [self addSubview:button];
    
}

//button事件
-(void) buttonClick:(CustomTabBarBtn *)button
{
    
    //防止按钮快速点击造成多次响应
    if (button.tag == 0) {
        [[self class] cancelPreviousPerformRequestsWithTarget:self selector:@selector(todoSomething:) object:button];
        [self performSelector:@selector(todoSomething:) withObject:button afterDelay:0.2f];
    }else
    {
        [self.delegate changeViewController:button];
    }
    
    
    
    
}

-(void)todoSomething:(CustomTabBarBtn *)button
{
    [self.delegate changeViewController:button ];
}

//添加呼叫按钮
-(void) addCallBtn
{
    self.callBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.callBtn.frame = CGRectMake(self.frame.size.width/4, 0, self.frame.size.width/2, self.frame.size.height);
    self.callBtn.hidden = YES;
    [self.callBtn setImage:[UIImage imageNamed:@"call"] forState:UIControlStateNormal];
    [self.callBtn addTarget:self action:@selector(callBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    
    [self addSubview: self.callBtn];
}

//呼叫按钮事件
-(void) callBtnClick:(UIButton *)btn
{
    [self.delegate eventCallBtn:btn];
}



@end
