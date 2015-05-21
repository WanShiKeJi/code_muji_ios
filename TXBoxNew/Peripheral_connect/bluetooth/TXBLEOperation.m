//
//  TXBLEOperation.m
//  TXBox
//
//  Created by Naron on 15/4/9.
//  Copyright (c) 2015年 com. All rights reserved.
//

#import "TXBLEOperation.h"
#import "TXSqliteOperate.h"

@implementation TXBLEOperation
@synthesize manager;



//请求配对设备
-(int) requestBTPair:(NSString *)str
{
    return 0;
}
//请求连接手机
-(int) receiveBTLink:(NSString *)str
{
    return 0;
}
//握手消息
-(int) handShake
{
    return 0;
}

-(void)getMessageFromMuji:(NSString *)hisNumber msgContent:(NSString *)content
{
    TXSqliteOperate *txsqlite = [[TXSqliteOperate alloc] init];
    [txsqlite createMsgTable:hisNumber];//一个电话号码建一张表
    
    //保存数据
    //txsqlite addInfo:<#(TXMsgData *)#> intoTable:<#(NSString *)#>
    
    
    
}
/*
#pragma mark -- 保存数据信息
-(void) saveDataWithHisNumber:(NSString *)hisNumber
                      hisName:(NSString *)hisName
                    startDate:(NSDate *)date
                   timeLength:(NSString *)times
                callDirection:(NSString *)direction
{
    //时间格式
    NSDateFormatter *dateFormate = [[NSDateFormatter alloc] init];
    [dateFormate setDateFormat:@"yy/MM/dd HH:mm"];
    [dateFormate setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"]];//中国
    //开始时间
    NSString *strDate = [dateFormate stringFromDate:date];//sreDate:如1503261130
    
    /*
     //开始时间
     [dateFormate setDateFormat:@"HH:mm:ss"];
     NSString *strDate2 = [dateFormate stringFromDate:date];//sreDate2:如113059
     
     //结束时间
     NSDate *endDate = [NSDate date];
     [dateFormate setDateFormat:@"HH:mm:ss"];
     NSString *strEndDate =[dateFormate stringFromDate:endDate];//strEndDate:如113559
     
     //计算之间时间
     NSString *strCallLength = [self intervalFromLastDate:strDate2 toTheDate:strEndDate];
     */
    /*
    //通话时长
    NSString *strCallLength = times;
    //姓名
    NSString *strName = [[NSString alloc] init];
    if (hisName.length>0) {
        
        strName  =hisName;
    }else
    {
        strName = @"";
    }
    //姓名
    NSString *strNunmber = [[NSString alloc] init];
    if (hisNumber.length>0) {
        
        strNunmber  =hisNumber;
    }else
    {
        strNunmber = @"";
    }
    
    //运营商
    NSString *strOperators = [[NSString alloc] init];
    TXGeneral_helper *general = [[TXGeneral_helper alloc] init];
    strOperators = [general isMobileNumber:hisNumber];
    
    //归属地
    NSString *strAddress = [[NSString alloc] init];
    strAddress = @"";
    
    //data.tel_id =singleton.telID;//不需要存id，
    data.hisNumber = strNunmber;
    data.callBeginTime = strDate;
    data.hisOperator = strOperators;
    data.hisHome = strAddress;
    data.hisName = strName;
    data.callDirection = direction;
    data.callLength = strCallLength;
    
    [txSqlite addInfo:data into:CALL_RECORDS_TABLE_NAME];
}
*/

@end
