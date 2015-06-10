//
//  Records.m
//  VideoCall
//
//  Created by mac on 14-12-4.
//  Copyright (c) 2014年 mac. All rights reserved.
//

#import "Records.h"

@implementation Records

- (NSString *)description

{
    return [NSString stringWithFormat:@"<Records: %p,personTel: %@,personName: %@,personTelNum: %@,personNameNum: %@>", self, self.personTel, self.personName,self.personTelNum, self.personNameNum];
    
}
@end
