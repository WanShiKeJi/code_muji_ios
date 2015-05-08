//
//  ContactsCell.h
//  TXBoxNew
//
//  Created by Naron on 15/4/16.
//  Copyright (c) 2015年 playtime. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ContactsCell : UITableViewCell
@property (weak  ,nonatomic) IBOutlet UILabel *nameLabel;
@property (weak  ,nonatomic) IBOutlet UILabel *numberLabel;
@property (strong,nonatomic) UIImageView *imgView;
@property (weak, nonatomic) IBOutlet UIButton *msgsBtn;


- (IBAction)callBtn:(UIButton *)sender;
- (IBAction)msgBtn:(UIButton *)sender;
- (IBAction)editBtn:(UIButton *)sender;

@end
