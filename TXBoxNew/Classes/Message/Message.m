//
//  Message.m
//  TXBoxNew
//
//  Created by Naron on 15/5/7.
//  Copyright (c) 2015年 playtime. All rights reserved.
//

#import "Message.h"

@implementation Message

- (void)setDict:(NSDictionary *)dict{
    
    _dict = dict;
    
    self.icon = dict[@"icon"];
    self.time = dict[@"time"];
    self.content = dict[@"content"];
    self.type = [dict[@"type"] intValue];
}

@end
