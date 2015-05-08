//
//  TXBLEOperation.h
//  TXBox
//
//  Created by Naron on 15/4/9.
//  Copyright (c) 2015年 com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>


@interface TXBLEOperation : NSObject
{
    CBCentralManager *manager;
}
@property (nonatomic,strong) CBCentralManager *manager;


-(int) requestBTPair:(NSString *)str;
-(int) receiveBTLink:(NSString *)str;
-(int) handShake;
@end
