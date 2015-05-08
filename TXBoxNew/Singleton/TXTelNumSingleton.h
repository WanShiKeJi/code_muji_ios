//
//  TXTelNumSingleton.h
//  TXBox
//
//  Created by Naron on 15/3/31.
//  Copyright (c) 2015年 com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TXTelNumSingleton : NSObject


{
    NSString *singletonValue;
    
}
@property (strong,nonatomic) NSString *singletonValue;
+(TXTelNumSingleton *) sharedInstance;
@end
