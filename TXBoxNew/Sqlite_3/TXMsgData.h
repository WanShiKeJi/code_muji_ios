//
//  TXMsgData.h
//  TXBoxNew
//
//  Created by Naron on 15/5/20.
//  Copyright (c) 2015年 playtime. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TXMsgData : NSObject

@property(assign , nonatomic) int peopleId;
@property (strong, nonatomic) NSString *hisName;        //对方在通讯录中的名字，没有存则不显示
@property (strong, nonatomic) NSString *hisNumber;      //对方号码
@property (strong, nonatomic) NSString *msgBeginTime;   //收到信息时间
@property (strong, nonatomic) NSString *msgContent;     //短信内容

@end
