//
//  TXTelNumSingleton.m
//  TXBox
//
//  Created by Naron on 15/3/31.
//  Copyright (c) 2015年 com. All rights reserved.
//

#import "TXTelNumSingleton.h"


static TXTelNumSingleton *sharedSingleton = nil;

@implementation TXTelNumSingleton
@synthesize singletonValue;

+ (TXTelNumSingleton *) sharedInstance
{
    if (sharedSingleton == nil) {
        sharedSingleton = [[super allocWithZone:nil] init];
    }
    return sharedSingleton;
}

+ (id) allocWithZone:(struct _NSZone *)zone
{
    return [self sharedInstance];
}

- (id) copyWithZone:(NSZone *) zone
{
    return self;
}


@end
