//
//  TXCallAction.h
//  TXBox
//
//  Created by Naron on 15/4/9.
//  Copyright (c) 2015年 com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TXData.h"
#import "TXSqliteOperate.h"


@interface TXCallAction : NSObject

@property (nonatomic,strong) TXData *data;
@property (nonatomic,strong) TXSqliteOperate *txSqlite;

@property (nonatomic,strong) NSDate *startDate;

//接电话
-(int) callIn:(NSString *)hisnumber;
-(int) callInAction;
//拨电话
-(int) callOutFromNumber:(NSString *)myNumber HisNumber:(NSString *)hisNumber;
-(int) callOutAction:(int)sender;
//通话结束
-(int) callEndByMeWithState:(int)state
                  hisNumber:(NSString *)hisNumber
                    hisName:(NSString *)hisName
                 timeLength:(NSString *)times;
-(int) callEndByHim:(int)state;


@end
