//
//  EditView.h
//  TXBoxNew
//
//  Created by Naron on 15/5/28.
//  Copyright (c) 2015年 playtime. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol EditViewDelegate <NSObject>

-(void)buttonClickAndChanged:(UIButton *)button;

@end

@interface EditView : UIView


@property (strong,nonatomic) UIButton *copysButton;
@property (strong,nonatomic) UIButton *sharesButton;
@property (strong,nonatomic) UIButton *deleteButton;

@property (assign,nonatomic) id <EditViewDelegate> delegate;

@end
