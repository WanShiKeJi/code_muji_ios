//
//  CallController.m
//  TXBoxNew
//
//  Created by Naron on 15/4/13.
//  Copyright (c) 2015年 playtime. All rights reserved.
//

#import "CallController.h"
#import "TXSqliteOperate.h"
#import "CallingController.h"
#import <AddressBookUI/AddressBookUI.h>
#import "NSString+helper.h"
#import "MsgDatas.h"
#import "PopView.h"
#import "MsgDetailController.h"
#import "TXNavgationController.h"

@interface CallController ()<UITextFieldDelegate,ABNewPersonViewControllerDelegate,UIAlertViewDelegate,PopViewDelegate>
{
    NSMutableArray *CallRecords;
    TXSqliteOperate *sqlite;
    CallingController *calling;
    ABNewPersonViewController *newPerson;
    MsgDatas *msgdata;
    UIWebView *webView;
    UIView *shadeView;  //遮罩层
    PopView *popview;   //提示框
    UIAlertView *_alertView; //提示框
    NSUserDefaults *defaults;

}

- (IBAction)callAnotherPelple:(UIBarButtonItem *)sender;
@property (weak,nonatomic) UIAlertController *alertc;
@property (strong,nonatomic) NSIndexPath *selectedIndexPath;        //被选中
@end


@implementation CallController



//从数据库中加载通话记录
- (void) loadCallRecords{
    //创建data对象的数组
    CallRecords = [[NSMutableArray alloc] init];
    
    sqlite = [[TXSqliteOperate alloc] init];

}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //显示tabbar
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:kShowCusotomTabBar object:self]];
    
    //查询
    NSMutableArray *array = [sqlite searchInfoFrom:CALL_RECORDS_TABLE_NAME];
    //排序
    CallRecords = (NSMutableArray *)[[array reverseObjectEnumerator] allObjects];
    [self.tableView reloadData];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = NSLocalizedString(@"Phone", nil);
    [self loadCallRecords];
    
    self.selectedIndexPath = nil;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;//tableview分割线
    
    //
    msgdata = [[MsgDatas alloc] init];
    defaults = [NSUserDefaults standardUserDefaults];
    //通知
    if([self respondsToSelector:@selector(showAddperson:)]) {
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showAddperson:) name:kShowAddContacts object:nil];
    }

    
    //创建提醒对话框
    _alertView = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"Please_enter_the_correct_info", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"Sure", nil) otherButtonTitles:nil, nil];
    _alertView.delegate = self;
    [_alertView textFieldAtIndex:0];//获取输入框，在UIAlertViewStyle -> input模式
}

//跳转到add联系人
-(void)showAddperson:(NSNotification *)notifi
{
    newPerson = [[ABNewPersonViewController alloc]init];
    newPerson.newPersonViewDelegate=self;
    newPerson.title = NSLocalizedString(@"Add_Ctontacts", nil);
    
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
    
    [cell.MsgButton addTarget:self action:@selector(MsgButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    
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
-(void)MsgButtonClick:(UIButton *)btn
{
    //自定键盘、callBtn,tabbar隐藏
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:kKeyboardAndTabViewHide object:self]];
    
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    TXData *aRecord = [CallRecords objectAtIndex:indexPath.row];
    msgdata.hisName = aRecord.hisName;
    msgdata.hisNumber = aRecord.hisNumber;
    msgdata.hisHome = aRecord.hisHome;
    
    UIStoryboard *board = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    MsgDetailController *controller = [board instantiateViewControllerWithIdentifier:@"msgDetail"];
    controller.datailDatas = msgdata;
    
    [self.navigationController pushViewController:controller animated:YES];
    
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
    return NSLocalizedString(@"Delete", nil);
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

//跳转前，把选中行的值传过去
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    /*
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    TXData *aRecord = [CallRecords objectAtIndex:indexPath.row];
    msgdata.hisName = aRecord.hisName;
    msgdata.hisNumber = aRecord.hisNumber;
    msgdata.hisHome = aRecord.hisHome;
    if(![segue.identifier isEqualToString:@"msgDetail"]){
        
        id page2 = segue.destinationViewController;
        [page2 setValue:msgdata forKey:@"datailDatas"];
    }
    */
    
}

//呼转方法
- (IBAction)callAnotherPelple:(UIBarButtonItem *)sender
{
    //获取拇机,email号码,
    NSString *phoneNumber = [defaults valueForKey:muji_bind_number];
    NSString *emailNumber = [defaults valueForKey:email_number];
    
    //已有number和email
    if (phoneNumber.length>0 && emailNumber.length>0 ) {
        //获取呼转状态
        [self getCallDivert];
    }else
    {   //没有则弹框提示
        [self addShadeAndAlertView];
    }

}

-(void)getCallDivert
{
    NSString *number = [defaults valueForKey:muji_bind_number];
    if ([[defaults valueForKey:call_divert] intValue]) {
        //已呼转,弹框提示，到拇机123456789321的呼转取消？
        
        UIAlertView *aliert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Alerts", nil) message:[NSString stringWithFormat:@"%@ %@?",NSLocalizedString(@"Cancel_Call_Forwarding", nil),number] delegate:self cancelButtonTitle:NSLocalizedString(@"No", nil) otherButtonTitles:NSLocalizedString(@"Yes", nil), nil];
        aliert.delegate = self;
        aliert.tag =100;
        [aliert show];
        
    }else{
        //未呼转,弹框提示，手机呼转到拇机123456789321？
        UIAlertView *aliert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Alerts", nil) message:[NSString stringWithFormat:@"%@ %@?",NSLocalizedString(@"Call_Forwarding", nil),number] delegate:self cancelButtonTitle:NSLocalizedString(@"No", nil) otherButtonTitles:NSLocalizedString(@"Yes", nil), nil];
        aliert.delegate = self;
        aliert.tag =101;
        [aliert show];
    }

}

#pragma mark -- 弹出框
-(void)addShadeAndAlertView
{
    //透明层
    shadeView =[[UIView alloc] initWithFrame:self.view.window.bounds];
    shadeView.backgroundColor = [UIColor grayColor];//self.view.window.bounds
    shadeView.alpha = .5;
    
    //pop
    popview = [[PopView alloc] initWithFrame:CGRectMake((DEVICE_WIDTH-200)/2, (DEVICE_HEIGHT-170)/2-50, 200, 170)];
    popview.delegate = self;
    [popview initWithTitle:NSLocalizedString(@"The_Call_Forwarding_was_get_info", nil) firstMsg:NSLocalizedString(@"E-mail", nil) secondMsg:NSLocalizedString(@"MuJi-Number", nil) cancelButtonTitle:NSLocalizedString(@"Cancel", nil) otherButtonTitles:NSLocalizedString(@"Sure", nil)];
    
    [self.view.window addSubview:shadeView];
    [self.view.window addSubview:popview];
}


#pragma mark-- pop delegate
-(void)resaultsButtonClick:(UIButton *)button firstField:(UITextField *)ffield secondField:(UITextField *)sfield
{
    //获取输入的text
    NSString *email =ffield.text;
    NSString *number = [sfield.text trimOfString];
    //取消
    if (button.tag == 0) {
        
        [shadeView removeFromSuperview];
        [popview removeFromSuperview];
    }
    //sure按钮
    if (button.tag == 1) {
        if (email.length<=0 || number.length<=0 || ![email isValidateEmail:email] || ![number isValidateMobile:number]) {
            [_alertView show];
        }else
        {
            //保存数据
            [defaults setValue:email forKey:email_number];
            [defaults setValue:number forKey:muji_bind_number];
            
            VCLog(@"save-->email:%@,number:%@",email,number);
            [shadeView removeFromSuperview];
            [popview removeFromSuperview];
            
            [self getCallDivert];
        }
    }
    
    
}

#pragma mark -- AlertView Delegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSMutableString *str;
    /****/
    if (alertView.tag == 100) {
        if (buttonIndex == 1) {
            //取消呼转
            str = [[NSMutableString alloc] initWithFormat:@"**21*tel://%@#",[defaults valueForKey:muji_bind_number]];
            
            //设置状态为0
            [defaults setValue:@"0" forKey:call_divert];
        }
    }
    
    
    /****/
    if (alertView.tag == 101) {
        if (buttonIndex == 1) {
            //设置呼转,
            str = [[NSMutableString alloc] initWithFormat:@"**21*tel://%@#",[defaults valueForKey:muji_bind_number]];
            //设置状态为1
            [defaults setValue:@"1" forKey:call_divert];

        }
    }
    if (str.length>0) {
        // 呼叫
        // 不要将webView添加到self.view，如果添加会遮挡原有的视图
        if (webView == nil) {
            webView = [[UIWebView alloc] init];
        }
        
        NSURL *url = [NSURL URLWithString:str];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        
        [webView loadRequest:request];
        VCLog(@"anotherNumber:%@",str);
    }
    
}

-(UIImage *)hjkl
{
    UIGraphicsBeginImageContextWithOptions(self.view.bounds.size, self.view.opaque, 0.0);
    
    //当前层渲染到上下文
    [self.view.layer renderInContext:UIGraphicsGetCurrentContext()];
    
    //上下文形成图片
    UIImage * img = UIGraphicsGetImageFromCurrentImageContext();
    //结束并删除当前基于位图的图形上下文。
    UIGraphicsEndImageContext();
    return img;
}

@end
