//
//  TXMessageProcessing.h
//  TXBox
//
//  Created by Naron on 15/4/9.
//  Copyright (c) 2015年 com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TXMessageProcessing : NSObject

/**
 *    @brief    收短信
 *
 *    @param    hisNumber    发信人
 *    @param    content     内容
 */
-(int) msgInFrom:(NSString *)hisNumber msgContent:(NSString *)content;

/**
 *  @brief    发短信
 *
 *  @param   myNumber    发信人
 *  @param    hisNumber    收信人
 *  @param  content 内容
 */
-(int) msgOutFrom:(NSString *)myNumber to:(NSString *)hisNumber msgContent:(NSString *)content;
@end
