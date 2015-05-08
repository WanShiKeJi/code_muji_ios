//
//  CallDetailController.h
//  TXBoxNew
//
//  Created by Naron on 15/4/16.
//  Copyright (c) 2015年 playtime. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CallDetailController : UITableViewController

@property (weak, nonatomic) IBOutlet UIBarButtonItem *saveBtn;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *numberLabel;
@property (weak, nonatomic) IBOutlet UITextField *nameField;
@property (weak, nonatomic) IBOutlet UITextField *numberField;

@end

