//
//  CallingController.h
//  TXBoxNew
//
//  Created by Naron on 15/4/21.
//  Copyright (c) 2015年 playtime. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CallingController : UIViewController
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *numberLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLength;
-(IBAction)cut:(UIButton *)sender;
@end
