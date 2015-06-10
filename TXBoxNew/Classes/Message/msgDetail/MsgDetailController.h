//
//  MsgDetailController.h
//  TXBoxNew
//
//  Created by Naron on 15/4/21.
//  Copyright (c) 2015年 playtime. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TXData.h"
#import "HPGrowingTextView.h"

@interface MsgDetailController : UIViewController<HPGrowingTextViewDelegate>

@property (nonatomic,strong) TXData *datailDatas;

@end
