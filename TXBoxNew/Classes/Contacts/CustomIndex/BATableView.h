//
//  ABELTableView.h
//  TXBoxNew
//
//  Created by Naron on 15/4/25.
//  Copyright (c) 2015年 playtime. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol BATableViewDelegate;
@interface BATableView : UIView
@property (nonatomic, strong) UITableView * tableView;
@property (nonatomic, strong) id<BATableViewDelegate> delegate;
- (void)reloadData;
@end

@protocol BATableViewDelegate <UITableViewDataSource,UITableViewDelegate>

- (NSArray *)sectionIndexTitlesForABELTableView:(BATableView *)tableView;


@end
