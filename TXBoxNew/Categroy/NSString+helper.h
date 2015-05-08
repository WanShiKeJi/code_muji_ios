//
//  NSString+helper.h
//  hy
//
//  Created by mac on 15-04-12.
//  Copyright (c) 2015年 mac. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (helper)
/**
 *  清空字符串左右的空白字符
 *
 *  @return 字符串
 */
-(NSString*)trimLeftOrRightString;

/**
 *  清空字符串中间的空白字符
 *
 *  @return 字符串
 */
-(NSString *)trimOfString;

/**
 *  是否空字符串
 *
 *  @return 如果字符串为nil或者长度为0返回YES
 */
-(BOOL) isEmptyString;

/**
 *  过滤字符串中"-"
 *
 *  @return string
 */
-(NSString *) iPhoneStandardFormat;

-(NSString *) iPhoneStandardededFormat;
-(NSString *) iPhoneStandardedFormat;

-(NSString *)foradstr;

#pragma mark --格式化，如“123-4567-8910”
-(NSString *)insertStr;

-(NSString *)purifyString;

-(void)saveToNSDefaultWithKey:(NSString*)key;
@end
