//
//  MsgFrame.m
//  TXBoxNew
//
//  Created by Naron on 15/5/7.
//  Copyright (c) 2015年 playtime. All rights reserved.
//

#import "MsgFrame.h"
#import "Message.h"

@implementation MsgFrame
@synthesize delegate;

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    [self setMessage:_message];
}


- (void)setMessage:(Message *)message{
    
    _message = message;
    
    // 1、计算时间的位置
    CGFloat timeX;
    //if (_showTime){
        
        CGFloat timeY = 0;//kMargin  与cell边框高度间隔
        CGSize timeSize = [_message.time sizeWithAttributes:@{NSFontAttributeName:kTimeFont}];
        //VCLog(@"----%@", NSStringFromCGSize(timeSize));
        //=480-77-10-20-?
        timeX = DEVICE_WIDTH - timeSize.width-kMargin-kEdging-[self getMargin];//
        if (_message.type == MessageTypeHe) {
            timeX = kMargin+kEdging;
        }
        
        _timeF = CGRectMake(timeX, timeY, timeSize.width + kTimeMarginW, timeSize.height + kTimeMarginH);
   // }
    
    
    // 2、计算头像位置
    CGFloat iconX = kMargin;
    // 2.1 如果是自己发得，头像在右边
    if (_message.type == MessageTypeMe) {
        iconX = DEVICE_WIDTH - kMargin - kIconWH;
    }
    
    CGFloat iconY = CGRectGetMaxY(_timeF);
    _iconF = CGRectMake(iconX, iconY, kIconWH, kIconWH);
    
     
    // 3、计算内容位置
    CGFloat contentX = CGRectGetMaxX(_iconF) + kMargin;
    CGFloat contentY = iconY;
    CGSize contentSize = [_message.content boundingRectWithSize:CGSizeMake(DEVICE_WIDTH*.618, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:kContentFont} context:nil].size;
    
    if (_message.type == MessageTypeMe) {
        contentX = iconX  - contentSize.width - kContentLeft - kContentRight-[self getMargin];
    }
    
    _contentF = CGRectMake(contentX, contentY, contentSize.width + kContentLeft + kContentRight, contentSize.height + kContentTop + kContentBottom);
    
    // 4、计算高度
    _cellHeight = MAX(CGRectGetMaxY(_contentF), CGRectGetMaxY(_iconF))  + kMargin;
    //_cellHeight = MAX(CGRectGetMaxY(_contentF), CGRectGetMaxY(_iconF));
}


-(CGFloat)getMargin
{
    VCLog(@"%f",[self.delegate changeRightMargin]);
    return [self.delegate changeRightMargin];
}

@end
