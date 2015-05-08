//
//  TXMessageProcessing.m
//  TXBox
//
//  Created by Naron on 15/4/9.
//  Copyright (c) 2015年 com. All rights reserved.
//

#import "TXMessageProcessing.h"

@implementation TXMessageProcessing

#pragma mark -- 收短信
-(int) msgInFrom:(NSString *)hisNumber msgContent:(NSString *)content
{
    
    if (hisNumber.length>0 ) {
        VCLog(@"1");
        return 1;
    }
    VCLog(@"0");
    return 0;
}

#pragma mark -- 发短信
-(int) msgOutFrom:(NSString *)myNumber to:(NSString *)hisNumber msgContent:(NSString *)content
{
    if (myNumber.length>0 && hisNumber.length>0) {
        VCLog(@"1");
        return 1;
    }
    VCLog(@"0");
    return 0;
}
@end
