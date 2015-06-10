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
#import "TXBLEOperation.h"
#import "TXSqliteOperate.h"
#import "TXData.h"

@interface MessageController ()<UISearchResultsUpdating,UISearchControllerDelegate>
{
    TXSqliteOperate *txsqlite;
}
@property (strong,nonatomic) NSMutableArray *dataArray;     //短信信息
@property (strong,nonatomic) UISearchController *searchController;  //实现disPlaySearchBar
@property (strong,nonatomic) UITableViewController *searchVC;
@property (strong,nonatomic) NSMutableArray *searchsArray;          //搜索后的结果数组
@property (strong,nonatomic) NSMutableArray *contactsArray;     //短信联系人

@end

@implementation MessageController

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:kShowCusotomTabBar object:self]];
    
    //显示会话的所有联系人，但不重复
    NSMutableArray *aa = [txsqlite searchInfoFromTable:MESSAGE_RECEIVE_RECORDS_TABLE_NAME];
    for (TXData *d in aa) {
        NSString *accp = d.msgAccepter;
        if (![self.contactsArray containsObject:accp]) {
            [self.contactsArray addObject:accp];
        }
    }
    
    VCLog(@"self.contactsArray:%@",self.contactsArray);
    //根据某个number查询某个会话的最后一条记录
    TXData *dd = [[TXData alloc] init];
    for (NSString *num in self.contactsArray) {
        dd =[txsqlite searchConversationFromtable:MESSAGE_RECEIVE_RECORDS_TABLE_NAME hisNumber:num wihtSqlString:SELECT_A_LAST_MESSAGE_RECORDS];
        if (![self.dataArray containsObject:dd]) {
            [self.dataArray  addObject:dd];
        }
        
    }
    VCLog(@"self.dataArray:%@",self.dataArray);
    
    if (self.contactsArray.count > 0 || self.searchsArray.count > 0) {
        [self aaddfootv];
    }
    
    [self.tableView reloadData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = NSLocalizedString(@"Message", nil);
    
    self.dataArray = [[NSMutableArray alloc] init];
    self.searchsArray = [[NSMutableArray alloc] init];
    self.contactsArray = [[NSMutableArray alloc] init];
    
    [self initSearchController];
    
    txsqlite = [[TXSqliteOperate alloc] init];
    
    
    VCLog(@"%@",[NSString stringWithFormat:@"a '%@' b '%@' c '%@' ",@"%1%",@"%1%",@"%1%"]);
    
    
    
}
-(void)aaddfootv
{
    UIView *foovt = [[UIView alloc] initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, 30)];
    UILabel *lline = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, DEVICE_WIDTH, 1)];
    lline.backgroundColor = [UIColor blackColor];
    lline.alpha = .1;
    [foovt addSubview:lline];
    
    self.tableView.tableFooterView = foovt;
}

//searchController
-(void) initSearchController
{
    //需要初始化一下UISearchController:
    // 创建出搜索使用的表示图控制器
    self.searchVC = [[UITableViewController alloc] initWithStyle:UITableViewStylePlain];
    self.searchVC.tableView.dataSource = self;
    self.searchVC.tableView.delegate = self;
    
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:self.searchVC];
    self.searchController.searchResultsUpdater = self;
    self.searchController.delegate = self;
    self.searchController.searchBar.frame = CGRectMake(0, 64, DEVICE_WIDTH, 44.0);
    self.tableView.tableHeaderView = self.searchController.searchBar;
    self.definesPresentationContext = YES;//输入时显示状态栏，
    [self changedSearchBarCancel];
    
}
//将SearchBar上"Cancel"按钮改为”取消“
-(void)changedSearchBarCancel
{
    
    UIButton *cancelButton;
    UIView *topView = self.searchController.searchBar.subviews[0];
    for (UIView *subView in topView.subviews) {
        
        if ([subView isKindOfClass:NSClassFromString(@"UINavigationButton")]) {
            cancelButton = (UIButton *)subView;
            //设置文本和颜色
            [cancelButton setTitle:NSLocalizedString(@"Cancel", nil) forState:UIControlStateNormal];
            [cancelButton setTitleColor:RGBACOLOR(0, 103, 255, 1) forState:UIControlStateNormal];//蓝色
            cancelButton.titleLabel.font = [UIFont fontWithName:@"Heiti SC" size:15];
            
        }
    }
    
}

#pragma mark -- searchController 协议方法
//返回搜索结果
-(void) updateSearchResultsForSearchController:(UISearchController *)searchController
{
    
    
    NSString *searchString = [NSString stringWithFormat:@"%@%@%@",@"%",[self.searchController.searchBar text],@"%"];
    
    VCLog(@"searchString:%@",searchString);
    
    if (self.searchsArray!= nil) {
        [self.searchsArray removeAllObjects];
    }
    //短信搜索
    //根据短信联系人，搜索会话内容
    if (self.searchController.searchBar.text.length >=1) {
        self.searchsArray = [txsqlite searchContentWithInputText:searchString fromTable:MESSAGE_RECEIVE_RECORDS_TABLE_NAME withSql:SELECT_ALL_COINTENT_FROM_MSG];
    }
    
    
    VCLog(@"self.searchsArray :%@",self.searchsArray);
    
    //刷新表格
    //[self.searchVC.tableView reloadData];
    [self.tableView reloadData];
}
- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];

}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    //sections
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    //rows
    if (self.searchController.active) {
        return self.searchsArray.count;
    }
    return self.contactsArray.count;
}

// tableViewcell
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    MessageCell *cell = [tableView dequeueReusableCellWithIdentifier:@"messageCells" forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    //VCLog(@"self.dataArray:%@",self.dataArray);
    TXData *ddata = [self.dataArray objectAtIndex:indexPath.row];
    
    if (self.searchController.active) {
        TXData *sdata = [self.searchsArray objectAtIndex:indexPath.row];
        cell.contactsLabel.text = sdata.msgAccepter;
        cell.contentsLabel.text = sdata.msgContent;
        cell.dateLabel.text = sdata.msgTime;

    }else{
        cell.contactsLabel.text = [self.contactsArray objectAtIndex:indexPath.row];//ddata.msgSender;
        cell.contentsLabel.text = ddata.msgContent;
        cell.dateLabel.text = ddata.msgTime;
    }
    
    // Configure the cell...
    
  
    return cell;
}
//选中某行
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //传值，hisName,hisNumber,hisHome
    TXData *data = [self.dataArray objectAtIndex:indexPath.row];
    data.hisName = data.hisName;
    data.hisNumber = [self.contactsArray objectAtIndex:indexPath.row];//data.msgSender;
    data.hisHome = data.hisHome;//@"hisHome"
    
    MsgDetailController *DetailVC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"msgDetail"];
    DetailVC.datailDatas = data;
    
    [self.navigationController pushViewController:DetailVC animated:YES];
    
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:kHideCusotomTabBar object:self]];
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.searchController.active) {
        return 60;
    }
    return 60;
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

// 允许编辑
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        NSMutableArray *array = [ [ NSMutableArray alloc ] init ];
        
        [ array addObject: indexPath];
        
        //删除数据库数据,整个会话
        NSString *hisNumbers = [self.contactsArray objectAtIndex:indexPath.row];
        [txsqlite deleteContacterWithNumber:hisNumbers formTable:MESSAGE_RECEIVE_RECORDS_TABLE_NAME peopleId:@"" withSql:DELETE_MESSAGE_RECORD_CONVERSATION_SQL];
        
        //删除数组
        [self.dataArray removeObjectAtIndex:indexPath.row];//移除数组的元素
        [self.contactsArray removeObjectAtIndex:indexPath.row];
        
        [tableView deleteRowsAtIndexPaths:array withRowAnimation:UITableViewRowAnimationFade];
        
    }
}

-(NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NSLocalizedString(@"Delete", nil);
}



@end
