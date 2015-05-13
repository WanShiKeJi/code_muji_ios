//
//  HPTextViewInternal.h
//  TXBoxNew
//
//  Created by Naron on 15/4/21.
//  Copyright (c) 2015年 playtime. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface HPTextViewInternal : UITextView

@property (nonatomic, strong) NSString *placeholder;    //提示文字
@property (nonatomic, strong) UIColor *placeholderColor;//提示文字颜色
@property (nonatomic) BOOL displayPlaceHolder;          //是否显示提示文字

@end
