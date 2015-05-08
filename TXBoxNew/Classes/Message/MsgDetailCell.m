//
//  MsgDetailCell.m
//  TXBoxNew
//
//  Created by Naron on 15/5/7.
//  Copyright (c) 2015年 playtime. All rights reserved.
//

#import "MsgDetailCell.h"
#import "Message.h"
#import "MsgFrame.h"

@implementation MsgDetailCell


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        // 设置透明
        //self.backgroundColor = [UIColor clearColor];
        
        // 创建时间标签
        timeBtn = [[UIButton alloc] init];
        timeBtn.frame = CGRectMake(50, 0, 30, 20);
        [timeBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        timeBtn.titleLabel.font = kTimeFont;
        timeBtn.enabled = NO;
        [timeBtn setBackgroundImage:[UIImage imageNamed:@"chat_timeline_bg.png"] forState:UIControlStateNormal];
        [self.contentView addSubview:timeBtn];
        
        // 2、创建头像
        iconView = [[UIImageView alloc] init];
        //[self.contentView addSubview:iconView];
        
        // 创建内容
        contentBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [contentBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        contentBtn.titleLabel.font = kContentFont;
        contentBtn.titleLabel.numberOfLines = 0;
        [self.contentView addSubview:contentBtn];


    }

    return self;
}

- (void)awakeFromNib {
    
    // 设置透明
    //self.backgroundColor = [UIColor clearColor];
    
    // 创建时间标签
    timeBtn = [[UIButton alloc] init];
    timeBtn.frame = CGRectMake(50, 0, 30, 20);
    [timeBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    timeBtn.titleLabel.font = kTimeFont;
    timeBtn.enabled = NO;
    [timeBtn setBackgroundImage:[UIImage imageNamed:@"chat_timeline_bg.png"] forState:UIControlStateNormal];
    [self.contentView addSubview:timeBtn];
    
    // 2、创建头像
    iconView = [[UIImageView alloc] init];
    //[self.contentView addSubview:iconView];
    
    // 创建内容
    contentBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [contentBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    contentBtn.titleLabel.font = kContentFont;
    contentBtn.titleLabel.numberOfLines = 0;
    [self.contentView addSubview:contentBtn];
    
}



-(void)setMsgFrame:(MsgFrame *)msgFrame
{
    msgFrame = msgFrame;
    Message *message = msgFrame.message;
    
    // 1、设置时间
    [timeBtn setTitle:message.time forState:UIControlStateNormal];
    
    timeBtn.frame = msgFrame.timeF;
    
    // 2、设置头像
    iconView.image = [UIImage imageNamed:message.icon];
    iconView.frame = msgFrame.iconF;
    
    // 3、设置内容
    [contentBtn setTitle:message.content forState:UIControlStateNormal];
    contentBtn.contentEdgeInsets = UIEdgeInsetsMake(kContentTop, kContentLeft, kContentBottom, kContentRight);
    contentBtn.frame = msgFrame.contentF;
    
    if (message.type == MessageTypeMe) {
        contentBtn.contentEdgeInsets = UIEdgeInsetsMake(kContentTop, kContentRight, kContentBottom, kContentLeft);
    }
    
    UIImage *normal , *focused;
    if (message.type == MessageTypeMe) {
        
        normal = [UIImage imageNamed:@"chatto_bg_normal.png"];//messages_right_bubble
        normal = [normal stretchableImageWithLeftCapWidth:normal.size.width * 0.5 topCapHeight:normal.size.height * 0.7];
        focused = [UIImage imageNamed:@"chatto_bg_focused.png"];
        focused = [focused stretchableImageWithLeftCapWidth:focused.size.width * 0.5 topCapHeight:focused.size.height * 0.7];
    }else{
        
        normal = [UIImage imageNamed:@"chatfrom_bg_normal.png"];//messages_left_bubble_selected
        normal = [normal stretchableImageWithLeftCapWidth:normal.size.width * 0.5 topCapHeight:normal.size.height * 0.7];
        focused = [UIImage imageNamed:@"chatfrom_bg_focused.png"];
        focused = [focused stretchableImageWithLeftCapWidth:focused.size.width * 0.5 topCapHeight:focused.size.height * 0.7];
        
    }
    [contentBtn setBackgroundImage:normal forState:UIControlStateNormal];
    [contentBtn setBackgroundImage:focused forState:UIControlStateHighlighted];
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
