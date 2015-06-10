//
//  TXCallAction.m
//  TXBox
//
//  Created by Naron on 15/4/9.
//  Copyright (c) 2015年 com. All rights reserved.
//

#import "TXCallAction.h"
#import "TXGeneral+helper.h"
#import "NSString+helper.h"

@implementation TXCallAction
@synthesize data,txSqlite,startDate;

-(id)init
{
    if (self = [super init]) {
        
        txSqlite = [[TXSqliteOperate alloc] init];
        data = [[TXData alloc] init];
        startDate = [[NSDate alloc] init];
    }
    return self;
}

#pragma mark -- 接电话
-(int) callIn:(NSString *)hisnumber
{
    startDate = [NSDate date];
    
    return 0;
}
-(int) callInAction
{
    return 0;
}

#pragma mark -- 拨电话
-(int) callOutFromNumber:(NSString *)myNumber HisNumber:(NSString *)hisNumber
{
    //获取当前时间，开始拨打
    startDate = [NSDate date];
    
    if (myNumber.length >0) {
        
        
        VCLog(@"call out 1");
        return 1;

        
    }
    return 0;
}
-(int) callOutAction:(int)sender
{
    if (sender) {
        return 1;
    }
    
    return 0;
}
#pragma mark -- 通话结束

-(int) callEndByMeWithState:(int)state
                  hisNumber:(NSString *)hisNumber
                    hisName:(NSString *)hisName
                 timeLength:(NSString *)times
{
    //保存数据信息
    [self saveDataWithHisNumber:hisNumber hisName:hisName startDate:self.startDate timeLength:times callDirection:[NSString stringWithFormat:@"%d",state]];
    
    return 0;
}
-(int) callEndByHim:(int)state
{
    return 0;
}

#pragma mark -- 保存数据信息
-(void) saveDataWithHisNumber:(NSString *)hisNumber
                      hisName:(NSString *)hisName
                    startDate:(NSDate *)date
                   timeLength:(NSString *)times
                callDirection:(NSString *)direction
{
    //时间格式
    NSDateFormatter *dateFormate = [[NSDateFormatter alloc] init];
    [dateFormate setDateFormat:@"yy/M/d HH:mm"];
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
    strOperators = [TXGeneral_helper isMobileNumber:hisNumber];
    
    //归属地
    NSString *strAddress = [[NSString alloc] init];
    if (hisNumber.length >=7) {
        
        strAddress = [txSqlite searchAreaWithHisNumber:[[hisNumber purifyString] substringToIndex:7]];
        
    }else{
        strAddress = @"";
    }
    
    
    //data.tel_id =singleton.telID;//不需要存id，
    data.hisNumber = strNunmber;
    data.callBeginTime = strDate;
    data.hisOperator = strOperators;
    data.hisHome = strAddress;
    data.hisName = strName;
    data.callDirection = direction;
    data.callLength = strCallLength;
    
    [txSqlite addInfo:data inTable:CALL_RECORDS_TABLE_NAME withSql:CALL_RECORDS_ADDINFO_SQL];
}

// 时间转字符串，
-(NSString *) dateTurnStringWithDate:(NSDate *)date dateFormate:(NSString *)formate
{
    //想要的时间格式
    NSDateFormatter *dateFormate = [[NSDateFormatter alloc] init];
    [dateFormate setDateFormat:formate];
    [dateFormate setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"]];//中国
    //
    NSString *string = [dateFormate stringFromDate:date];
    
    return string;
    
}

@end
