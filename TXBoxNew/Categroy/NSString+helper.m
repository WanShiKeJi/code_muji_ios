//
//  NSString+helper.h
//  hy
//
//  Created by mac on 15-04-12.
//  Copyright (c) 2015年 mac. All rights reserved.
//

#import "NSString+helper.h"

@implementation NSString (helper)

#pragma mark --去除字符串左右的空格以及换行符，中间的清不了
-(NSString *)trimLeftOrRightString{

    return [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

}

#pragma mark --去除字符串中的空格
-(NSString *)trimOfString
{
    //其实是替换
    return [self stringByReplacingOccurrencesOfString:@" " withString:@""];
}

-(NSString *)trimOfStringTwo:(NSString *)string
{
    //其实是替换
    return [string stringByReplacingOccurrencesOfString:@" " withString:@""];
}

#pragma mark --是否为空字符串
-(BOOL) isEmptyString{
    
    return (self == nil || self.length ==0);

}

#pragma mark --过滤字符串中的“－”
-(NSString *) iPhoneStandardFormat{
   return [self stringByReplacingOccurrencesOfString:@"-" withString:@""];
    
}

#pragma mark --过滤字符串中的“(”
-(NSString *) iPhoneStandardedFormat{
    return [self stringByReplacingOccurrencesOfString:@"(" withString:@""];
    
}

#pragma mark --过滤字符串中的“)”
-(NSString *) iPhoneStandardededFormat{
    return [self stringByReplacingOccurrencesOfString:@")" withString:@""];
    
}

#pragma mark --写入系统偏好
-(void)saveToNSDefaultWithKey:(NSString*)key{

    [[NSUserDefaults standardUserDefaults]setObject:self forKey:key];
    [[NSUserDefaults standardUserDefaults]synchronize];

}

#pragma mark --格式化，如“123-4567-8910”
-(NSString *)insertStr
{
    NSMutableString *mutStr = [[NSMutableString alloc] initWithFormat:@"%@",self];
    //str<=7
    if (mutStr.length<=8) {
        return (NSString *)mutStr;
    }
    //str>7
    
    if (mutStr.length>8 ) {
        [mutStr insertString:@"-" atIndex:3];
        [mutStr insertString:@"-" atIndex:8];
    }
    
    
    
    return (NSString *)mutStr;
}

#pragma mark --过滤字符串
-(NSString *)purifyString
{
    NSString *string = [[NSString alloc] init];
    NSString *isString = [[NSString alloc] init];
    if (self.length>0) {
        string = [self trimLeftOrRightString];//去除左右空格和换行符
        string = [string iPhoneStandardedFormat ];//去除左括号
        string = [string iPhoneStandardededFormat];//去除右括号
        string = [string trimOfString];     //去除字符串中间的空格
        string = [string iPhoneStandardFormat];//去除 -
        
        string = [string trimOfString];
        
        isString = [string trimOfStringTwo:string];
        isString = [isString trimLeftOrRightString];
        isString = [isString trimOfString];
        //551 87896
        //123654896
    }
    return isString;
}

#pragma mark --给string 计算文本size
- (CGSize)sizeWithFont:(UIFont *)font maxSize:(CGSize)maxSize
{  NSDictionary *attrs = @{NSFontAttributeName: font};
    CGSize size =[self boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin attributes:attrs context:nil].size;
    return size;
}


#pragma mark --邮箱验证
-(BOOL)isValidateEmail:(NSString *)email
{
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:email];
}

#pragma mark --手机号码验证
-(BOOL) isValidateMobile:(NSString *)mobile
{
    //手机号以13， 15，18开头，八个 \d 数字字符
    NSString *phoneRegex = @"^((13[0-9])|(15[^4,\\D])|(18[0,0-9]))\\d{8}$";
    NSPredicate *phoneTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",phoneRegex];
    //    NSLog(@"phoneTest is %@",phoneTest);
    return [phoneTest evaluateWithObject:mobile];
}

#pragma mark --车牌号验证
-(BOOL) validateCarNo:(NSString* )carNo;
{
    NSString *carRegex = @"^[A-Za-z]{1}[A-Za-z_0-9]{5}$";
    NSPredicate *carTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",carRegex];
    NSLog(@"carTest is %@",carTest);
    return [carTest evaluateWithObject:carNo];
}


@end
