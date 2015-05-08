//
//  MessageController.m
//  TXBoxNew
//
//  Created by Naron on 15/4/21.
//  Copyright (c) 2015年 playtime. All rights reserved.
//

#import "MessageController.h"
#import "MessageCell.h"
#import "MsgDatas.h"
#import "MsgDetailController.h"

@interface MessageController ()

@property (strong,nonatomic) NSMutableArray *array;

@end

@implementation MessageController

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:kShowCusotomTabBar object:self]];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    self.array = [NSMutableArray arrayWithObjects:@"1",nil];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return self.array.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    MessageCell *cell = [tableView dequeueReusableCellWithIdentifier:@"msgCells" forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.contactsLabel.text = [self.array objectAtIndex:indexPath.row];
    cell.contentsLabel.text = @"contents";
    cell.dateLabel.text = @"2015/04/21 10:59";
    // Configure the cell...
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    MsgDatas *data = [[MsgDatas alloc] init];
    data.hisName = [self.array objectAtIndex:indexPath.row];
    data.hisNumber = @"12341231234";
    data.hisHome = @"hisHome";
    
    MsgDetailController *DetailVC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"msgDetail"];
    DetailVC.datailDatas = data;
    
    [self.navigationController pushViewController:DetailVC animated:YES];
    
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:kHideCusotomTabBar object:self]];
    
}


// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}



// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        NSMutableArray *array = [ [ NSMutableArray alloc ] init ];
        
        [ array addObject: indexPath];
        
        [self.array removeObjectAtIndex:indexPath.row];//移除数组的元素
        
        
        [tableView deleteRowsAtIndexPaths:array withRowAnimation:UITableViewRowAnimationFade];
    }
}

-(NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return @"删除";
}

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
