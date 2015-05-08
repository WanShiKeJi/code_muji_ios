//
//  TXGeneral+helper.h
//  TXBoxNew
//
//  Created by Naron on 15/4/20.
//  Copyright (c) 2015年 playtime. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TXGeneral_helper : NSObject

/****计算时间差*****/
- (NSString *)prettyDateWithReference:(NSDate *)reference;

/*****手机号运营商*******/
- (NSString *)isMobileNumber:(NSString *)number;

/*****手机号归属地*******/
-(NSString *) getNumbersAddress:(NSString *)number;


/****计算2个时间点的时间差****/
- (NSString *)intervalFromLastDate:(NSString *)sDate toTheDate:(NSString *)endDate;

@end
