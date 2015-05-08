//
//  CustomTabBarView.h
//  TXBoxNew
//
//  Created by Naron on 15/4/22.
//  Copyright (c) 2015年 playtime. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomTabBarBtn.h"
#import "TXKeyView.h"

@protocol tabBarViewDelegate <NSObject>

-(void) eventCallBtn:(UIButton *)button;
-(void) changeViewController:(CustomTabBarBtn *)button;

@end


@interface CustomTabBarView : UIView
{
    CustomTabBarBtn *previousBtn;
    //TXCallAction *callAct;
    BOOL flag;
}

@property (assign,nonatomic) id<tabBarViewDelegate> delegate;

@property (strong,nonatomic) TXKeyView *keyView;
@property (nonatomic,strong) UIButton *callBtn;


@end
