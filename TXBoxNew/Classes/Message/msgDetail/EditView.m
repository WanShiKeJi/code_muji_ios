//
//  EditView.m
//  TXBoxNew
//
//  Created by Naron on 15/5/28.
//  Copyright (c) 2015年 playtime. All rights reserved.
//

#import "EditView.h"

@implementation EditView
@synthesize copysButton,sharesButton,deleteButton,delegate;

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    //self.backgroundColor = [UIColor grayColor];
    UILabel *line =[[UILabel alloc] initWithFrame:CGRectMake(0, 1, rect.size.width, 1)];
    line.backgroundColor = [UIColor grayColor];
    line.alpha = .7;
    [self addSubview:line];
    
    
    copysButton = [UIButton buttonWithType:UIButtonTypeCustom];
    copysButton.frame =  CGRectMake(70, 10, 40, 30);
    copysButton.tag = 2000;
    [copysButton setEnabled:NO];
    [copysButton setImage:[UIImage imageNamed:@"Fav_Multi_CopyH"] forState:UIControlStateNormal];
    [copysButton addTarget:self action:@selector(btnck:) forControlEvents:UIControlEventTouchUpInside];
    
    sharesButton = [UIButton buttonWithType:UIButtonTypeCustom];
    sharesButton.frame =  CGRectMake(140, 10, 40, 30);
    sharesButton.tag = 2001;
    [sharesButton setEnabled:NO];
    [sharesButton setImage:[UIImage imageNamed:@"Fav_Multi_ForwardH"] forState:UIControlStateNormal];
    [sharesButton addTarget:self action:@selector(btnck:) forControlEvents:UIControlEventTouchUpInside];
    
    deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
    deleteButton.frame =  CGRectMake(210, 10, 40, 30);
    deleteButton.tag = 2002;
    [deleteButton setEnabled:NO];
    [deleteButton setImage:[UIImage imageNamed:@"Fav_Multi_DeleteH"] forState:UIControlStateNormal];
    [deleteButton addTarget:self action:@selector(btnck:) forControlEvents:UIControlEventTouchUpInside];
    
    [self addSubview:copysButton];
    [self addSubview:sharesButton];
    [self addSubview:deleteButton];
        
        
    
    
}

-(void)btnck:(UIButton *)button
{
    [self.delegate buttonClickAndChanged:button];
}

@end
