//
//  CallController.m
//  TXBoxNew
//
//  Created by Naron on 15/4/13.
//  Copyright (c) 2015年 playtime. All rights reserved.
//

#import "CallController.h"
#import "TXSqliteOperate.h"
#import "CallDetailController.h"
#import "CallingController.h"
#import <AddressBookUI/AddressBookUI.h>
#import "NSString+helper.h"
#import "MsgDatas.h"

@interface CallController ()<UITextFieldDelegate,ABNewPersonViewControllerDelegate>
{
    NSMutableArray *CallRecords;
    TXSqliteOperate *sqlite;
    CallingController *calling;
    ABNewPersonViewController *newPerson;
    MsgDatas *msgdata;
}

@property (strong,nonatomic) NSIndexPath *selectedIndexPath;        //被选中
@end


@implementation CallController



//从数据库中加载通话记录
- (void) loadCallRecords{
    //创建data对象的数组
    CallRecords = [[NSMutableArray alloc] init];
    
    sqlite = [[TXSqliteOperate alloc] init];

    //CallRecords = [NSMutableArray arrayWithObjects:@"zs",@"ls",@"ww", nil];
    //self.CallRecords = [sqlite searchInfoFrom:CALL_RECORDS_TABLE_NAME];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //显示tabbar
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:kShowCusotomTabBar object:self]];
    
    //查询
    NSMutableArray *array = [sqlite searchInfoFrom:CALL_RECORDS_TABLE_NAME];
    //排序
    CallRecords = [[array reverseObjectEnumerator] allObjects];
    [self.tableView reloadData];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadCallRecords];
    
    self.selectedIndexPath = nil;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;//tableview分割线
    
    //
    msgdata = [[MsgDatas alloc] init];
    
    //通知
    if([self respondsToSelector:@selector(showAddperson:)]) {
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showAddperson:) name:kShowAddContacts object:nil];
    }

}

//跳转到add联系人
-(void)showAddperson:(NSNotification *)notifi
{
    newPerson = [[ABNewPersonViewController alloc]init];
    newPerson.newPersonViewDelegate=self;
    newPerson.title = @"添加联系人";
    
    [self.navigationController pushViewController:newPerson animated:YES];
    VCLog(@"show");
}

-(void)newPersonViewController:(ABNewPersonViewController *)newPersonView didCompleteWithNewPerson:(ABRecordRef)person
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return [CallRecords count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    //用CallRecordsCell做初始化
    CallRecordsCell *cell = [tableView dequeueReusableCellWithIdentifier:@"reuseCell" forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    //更新cell的label，让其显示data对象的itemName
    TXData *aRecord = [CallRecords objectAtIndex:indexPath.row];
    
    cell.hisName.text = aRecord.hisName;
    cell.hisNumber.text = [[aRecord.hisNumber purifyString] insertStr];
    cell.callDirection.image = [self imageForRating:[aRecord.callDirection intValue]];
    //cell.callDirection.image = [self imageForRating:2];
    cell.callLength.text = aRecord.callLength;
    cell.callBeginTime.text = aRecord.callBeginTime;
    cell.hisHome.text = aRecord.hisHome;
    cell.hisOperator.text = aRecord.hisOperator;
    /*
    cell.hisName.text = [CallRecords objectAtIndex:indexPath.row];;
    cell.hisNumber.text = [NSString stringWithFormat:@"1381380000%ld",(long)indexPath.row];
    cell.callDirection.image = [self imageForRating:1];
    cell.callLength.text = @"05:40";
    cell.callBeginTime.text = @"2015/4/21 9:30";
    cell.hisHome.text = @"sz";
    cell.hisOperator.text = @"移动";
    */
    
    
    
    return cell;
}
//选择图标
- (UIImage *)imageForRating:(int)rating
{
    switch (rating)
    {
        case 0: return [UIImage imageNamed:@"icon_call_in.png"];
        case 1: return [UIImage imageNamed:@"icon_call_out.png"];
        case 2: return [UIImage imageNamed:@"icon_call_missed.png"];
    }
    return nil;
}

//单元格可编辑
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {

    return YES;
}

//设置cell高度
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([indexPath isEqual:self.selectedIndexPath]) {
        
        return 50 + 50;
    }
    
    return 50;
    
}


//可编辑样式
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (editingStyle == UITableViewCellEditingStyleDelete)
        
    {
        //删除数据库的数据
        TXData *aRecord = [CallRecords objectAtIndex:indexPath.row];
        [sqlite deleteContacterWithNumber:aRecord.hisNumber formTable:CALL_RECORDS_TABLE_NAME];

        
        NSMutableArray *array = [ [ NSMutableArray alloc ] init ];
        [array addObject: indexPath];
        
        //移除数组的元素
        [CallRecords removeObjectAtIndex:indexPath.row];
        //删除单元格
        [ self.tableView deleteRowsAtIndexPaths: array withRowAnimation: UITableViewRowAnimationLeft];
        
    }

}

/*改变删除按钮的text*/
-(NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return @"删除";
}

//样式--删除
-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}

//选中cell时
-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([indexPath isEqual:self.selectedIndexPath] ) {
        
        self.selectedIndexPath = nil;
        
    }else {
        
        self.selectedIndexPath = indexPath;
    }
    
    [tableView beginUpdates];
    [tableView endUpdates];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    TXData *aRecord = [CallRecords objectAtIndex:indexPath.row];
    msgdata.hisName = aRecord.hisName;
    msgdata.hisNumber = aRecord.hisNumber;
    msgdata.hisHome = aRecord.hisHome;
    
    id view =[segue destinationViewController];
    [view setValue:msgdata forKey:@"datailDatas"];
    
}

@end
