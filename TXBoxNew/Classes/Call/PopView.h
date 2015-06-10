//
//  PopView.h
//  TXBoxNew
//
//  Created by Naron on 15/5/12.
//  Copyright (c) 2015年 playtime. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PopViewDelegate <NSObject>
//点击按钮动作
-(void)resaultsButtonClick:(UIButton *)button  textField:(UITextField *)sfield;

@end

@interface PopView : UIView<UITextFieldDelegate>

@property (strong,nonatomic) UIImageView *imgv;
@property (strong,nonatomic) UITextField *secondField;

-(void)initWithTitle:(NSString *)title label:(NSString *)label cancelButtonTitle:(NSString *)cancelTitle otherButtonTitles:(NSString *)sureTitle;

@property (assign,nonatomic) id<PopViewDelegate> delegate;

@end
