//
//  MsgDatas.m
//  TXBoxNew
//
//  Created by Naron on 15/4/21.
//  Copyright (c) 2015年 playtime. All rights reserved.
//

#import "MsgDatas.h"

@implementation MsgDatas

@synthesize hisHome,hisName,hisNumber;

- (NSString *)description

{
    return [NSString stringWithFormat:@"name:%@,number: %@,home: %@", hisName, hisNumber, hisHome];
    
}


@end
