//
//  MessageCell.h
//  TXBoxNew
//
//  Created by Naron on 15/4/21.
//  Copyright (c) 2015年 playtime. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MessageCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *contactsLabel;
@property (weak, nonatomic) IBOutlet UILabel *contentsLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;

@end
