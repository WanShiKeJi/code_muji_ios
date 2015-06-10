//
//  NSString+helper.h
//  hy
//
//  Created by mac on 15-04-12.
//  Copyright (c) 2015年 mac. All rights reserved.
//

#import "NSString+helper.h"
#import "PinYin4Objc.h"


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

#pragma mark --过滤字符串中的““”
-(NSString *) iPhoneStandardedleftMarkFormat{
    return [self stringByReplacingOccurrencesOfString:@"“" withString:@""];
    
}
#pragma mark --过滤字符串中的“””
-(NSString *) iPhoneStandardedrightMarkFormat{
    return [self stringByReplacingOccurrencesOfString:@"”" withString:@""];
    
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
    
    if (mutStr.length>8 &&mutStr.length<=11) {
        [mutStr insertString:@"-" atIndex:3];
        [mutStr insertString:@"-" atIndex:8];
        return (NSString *)mutStr;
    }
    
    if (mutStr.length==12 ) {
        [mutStr insertString:@"-" atIndex:4];
        return (NSString *)mutStr;

    }
    
    if (mutStr.length>11) {
        [mutStr insertString:@" " atIndex:3];
        [mutStr insertString:@"-" atIndex:7];
        [mutStr insertString:@"-" atIndex:12];
        return (NSString *)mutStr;
    }
    
    
    return (NSString *)mutStr;
}

#pragma mark --过滤字符串
-(NSString *)purifyString
{
    NSString *string = [[NSString alloc] init];
    
    if (self.length>0) {
        string = [self trimLeftOrRightString];//去除左右空格和换行符
        string = [string iPhoneStandardedFormat ];//去除左括号
        string = [string iPhoneStandardededFormat];//去除右括号
        string = [string trimOfString];     //去除字符串中间的空格
        string = [string iPhoneStandardFormat];//去除 -
        
        string = [string iPhoneStandardedleftMarkFormat];
        string = [string iPhoneStandardedrightMarkFormat];
        //551 87896
        //123654896
    }
    return string;
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

#pragma mark -- 汉字转拼音
-(NSString  *)hanziTopinyin{
    
    HanyuPinyinOutputFormat *outputFormat =[[HanyuPinyinOutputFormat alloc] init];
    [outputFormat setToneType:ToneTypeWithoutTone];//声调
    [outputFormat setVCharType:VCharTypeWithV];//特殊拼音的显示格式如 ü
    [outputFormat setCaseType:CaseTypeLowercase];//大小写
    
    NSMutableString *mstring = [[NSMutableString alloc] initWithFormat:@"-%@",self];
    NSString *outputPinyin = [PinyinHelper toHanyuPinyinStringWithNSString:mstring withHanyuPinyinOutputFormat:outputFormat withNSString:@"-"];
    //VCLog(@"-------------outputpy:%@",outputPinyin);
    
    return outputPinyin;
}

#pragma mark -- 拼音转数字
-(NSString *)pinyinTrimIntNumber
{
    
    NSString *lString=[[NSString alloc] init];
    NSString *ss = [[NSString alloc] init];
    for (int i =0; i<self.length; i++) {
        char s = [self  characterAtIndex:i];
        switch (s) {
            case 'a':
            case 'b':
            case 'c':
            case 'A':
            case 'B':
            case 'C':
                ss = @"2";
                break;
            case 'd':
            case 'e':
            case 'f':
            case 'D':
            case 'E':
            case 'F':
                ss = @"3";
                break;
            case 'g':
            case 'h':
            case 'i':
            case 'G':
            case 'H':
            case 'I':
                ss = @"4";
                break;
            case 'j':
            case 'k':
            case 'l':
            case 'J':
            case 'K':
            case 'L':
                ss = @"5";
                break;
            case 'm':
            case 'n':
            case 'o':
            case 'M':
            case 'N':
            case 'O':
                ss = @"6";
                break;
            case 'p':
            case 'q':
            case 'r':
            case 's':
            case 'P':
            case 'Q':
            case 'R':
            case 'S':
                ss = @"7";
                break;
            case 't':
            case 'u':
            case 'v':
            case 'T':
            case 'U':
            case 'V':
                ss = @"8";
                break;
            case 'w':
            case 'x':
            case 'y':
            case 'z':
            case 'W':
            case 'X':
            case 'Y':
            case 'Z':
                ss = @"9";
                break;
            case '*':
                ss = @"A";
                break;
            case '#':
                ss = @"B";
                break;
            case '+':
                ss = @"C";
                break;
            default:
                ss = [self substringWithRange:NSMakeRange(i, 1)];
                break;
        }
        
        lString = [NSString stringWithFormat:@"%@%@",lString,ss];
    }
    if (self.length == 1) {
        return [NSString stringWithFormat:@"%@1",lString];
    }
    //VCLog(@"-lString:%@",[NSString stringWithFormat:@"-%@",lString]);
    return [NSString stringWithFormat:@"%@",lString];
}

-(NSString *)isMobileNumberWhoOperation
{
    //处理str
    NSString *mobileNum = [self purifyString];
    if (mobileNum.length == 0) {
        return @"";
    }
    
    /**
     * 手机号码
     * 移动：134,135,136,137,138,139,150,151,152,157,158,159,182,183,187,188
     * 联通：130,131,132,155,156,185,186
     * 电信：133,153,180,189
     */
    
    /**
     * 中国移动
     */
    NSString * CM = @"^1(34[0-8]|(3[5-9]|5[0127-9]|8[2378])\\d).*$";
    /**
     * 中国联通
     */
    NSString * CU = @"^1(3[0-2]|5[56]|8[56]).*$";
    /**
     * 中国电信
     */
    NSString * CT = @"^1(33|53|8[09]).*$";
    
    NSPredicate *regextestcm = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CM];
    NSPredicate *regextestcu = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CU];
    NSPredicate *regextestct = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CT];
    
    NSString *str = [[NSString alloc] init];
    
    if([regextestcm evaluateWithObject:mobileNum] == YES) {
        str = NSLocalizedString(@"Communication_Corp", nil);
        VCLog(@"China Mobile");
    } else if([regextestct evaluateWithObject:mobileNum] == YES) {
        str =  NSLocalizedString(@"Unicom", nil);
        VCLog(@"China Telecom");
    } else if ([regextestcu evaluateWithObject:mobileNum] == YES) {
        str =  NSLocalizedString(@"Telecom", nil);
        VCLog(@"China Unicom");
    } else {
        str  = NSLocalizedString(@"Other", nil);
        VCLog(@"Unknow");
    }
    
    
    
    return str;
    
    
}


@end
