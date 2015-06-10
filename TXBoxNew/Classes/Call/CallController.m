//
//  CallController.m
//  TXBoxNew
//
//  Created by Naron on 15/4/13.
//  Copyright (c) 2015年 playtime. All rights reserved.
//

#define kRemoveZZArray @"removeZZArray"

#import "CallController.h"
#import "TXSqliteOperate.h"
#import "CallingController.h"
#import <AddressBookUI/AddressBookUI.h>
#import "NSString+helper.h"
#import "MsgDatas.h"
#import "MsgDetailController.h"
#import "TXNavgationController.h"
#import "TXTelNumSingleton.h"
#import "TXKeyView.h"
#import "CustomTabBarView.h"
#import "Records.h"
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <CoreTelephony/CTCarrier.h>
#import "DiscoveryController.h"

@interface CallController ()<UITextFieldDelegate,ABPersonViewControllerDelegate,ABNewPersonViewControllerDelegate,UIAlertViewDelegate>
{
    NSMutableArray *CallRecords;
    TXSqliteOperate *sqlite;
    CallingController *calling;
    
    MsgDatas *msgdata;
    UIWebView *webView;
    NSUserDefaults *defaults;
    NSMutableArray *mutPhoneArray;
    NSMutableDictionary *phoneDic;      //同一个人的手机号码dic

    TXTelNumSingleton *singleton;   //获取输入的号码
    NSMutableArray *searchResault;
    NSArray *dataList;
    DiscoveryController *discoveryCtrol;
    
    NSMutableArray *zzArray;
    NSString *areaString;
    NSString *opeareString;
    
}

- (IBAction)callAnotherPelple:(UIBarButtonItem *)sender;
@property (weak,nonatomic) UIAlertController *alertc;
@property (strong,nonatomic) NSIndexPath *selectedIndexPath;        //被选中
@end


@implementation CallController

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //显示tabbar
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:kShowCusotomTabBar object:self]];
    
    //textInput
    if([self respondsToSelector:@selector(inputTextDidChanged:)]) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(inputTextDidChanged:) name:kInputCharNoti object:nil];
    }
    // delete
    if([self respondsToSelector:@selector(deleteTextDidChanged:)]) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deleteTextDidChanged:) name:kDeleteCharNoti object:nil];
    }
    
    if([self respondsToSelector:@selector(callviewWillRefresh)]) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(callviewWillRefresh) name:kCallViewReloadData object:nil];
    }
    
    //查询数据库获取通话记录
    NSMutableArray *array = [sqlite searchInfoFromTable:CALL_RECORDS_TABLE_NAME];
    //排序
    CallRecords = (NSMutableArray *)[[array reverseObjectEnumerator] allObjects];
    [self.tableView reloadData];
    //VCLog(@"int max:%i",INT_MAX);
}


-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    //获取联系人数据
    [self loadContacts];
}
- (void)viewDidLoad {
    
    [super viewDidLoad];
    self.title = NSLocalizedString(@"Phone", nil);
    [self loadCallRecords];
    
    self.selectedIndexPath = nil;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;//tableview分割线
    
    if (![[defaults valueForKey:@"opstate"] intValue]) {
        UIAlertView *aaa =[[UIAlertView alloc] initWithTitle:@"" message:[NSString stringWithFormat:@"%@",[self getCarrier]] delegate:self cancelButtonTitle:@"n" otherButtonTitles:@"y", nil];
        [aaa show];
        [defaults setValue:@"1" forKey:@"opstate"];
    }
    
    zzArray =[[NSMutableArray alloc] init];
    //[sqlite openPhoneArearDatabase];
    areaString = [[NSString alloc] init];
    opeareString = [[NSString alloc] init];
    
}

//初始化
- (void) loadCallRecords{
    
    //创建data对象的数组
    CallRecords = [[NSMutableArray alloc] init];
    mutPhoneArray =[[NSMutableArray alloc] init];
    phoneDic = [[NSMutableDictionary alloc] init];
    sqlite = [[TXSqliteOperate alloc] init];
    msgdata = [[MsgDatas alloc] init];
    defaults = [NSUserDefaults standardUserDefaults];
    singleton = [TXTelNumSingleton sharedInstance];
    searchResault = [[NSMutableArray alloc] init];
    
    [defaults setValue:@"0" forKey:@"preState"];
}

-(void)callviewWillRefresh
{
    [self.tableView reloadData];
}

#pragma mark -- 用户退格输入时
-(void)deleteTextDidChanged:(NSNotification*)notifi{
    NSString *lastChar = [[notifi userInfo] valueForKey:@"lastChar"];
    
    //退格
    [self deleteCharWithLastinput:lastChar];
    [self predictaeDataWithState:0];
    
}
#pragma mark -- 用户增加输入时
-(void)inputTextDidChanged:(NSNotification*)notifi{
    
    NSString *searchText = [[notifi userInfo] valueForKey:@"searchBarText"];
    NSString *lastChar = [searchText substringWithRange:NSMakeRange(searchText.length-1, 1)];
    //NSString *testString = [NSString stringWithFormat:@"-%@[0-9,A,B,C].*",lastChar];
    
    NSString *inputString = [NSString stringWithFormat:@"-%@[0-9,A,B,C]*",lastChar];
    //生成zz表达式
    [self zzStringAndArrayInputchar:inputString aChar:lastChar];
    
    [self predictaeDataWithState:1];
}

/**
 *  @pragma state 输入状态，删除0，增加输入1，
 */
-(void)predictaeDataWithState:(int)state{
    
    
    if (searchResault.count != 0) {
        [searchResault removeAllObjects];
    }
    //NSMutableArray *arrayZZMut = [[NSMutableArray alloc] init];
    
    //过滤数据
    for (NSMutableString *str in zzArray) {
        NSPredicate *regextestcm = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", str];
        for (NSDictionary *dict in mutPhoneArray) {
            //匹配姓名
            NSString *pnameNum = [dict valueForKey:@"personNameNum"];
            //VCLog(@"pnameNum:%@ ",pnameNum);
            //VCLog(@"regextestcm-str:%@ ",str);
            if ([regextestcm evaluateWithObject:pnameNum]) {
                if (![searchResault containsObject:dict]) {
                    [searchResault addObject:dict];
                }
               
            }
            //匹配号码
            NSString *phoneNum = [dict valueForKey:@"personTelNum"];
            if ([regextestcm evaluateWithObject:phoneNum]) {
                if (![searchResault containsObject:dict]) {
                    [searchResault addObject:dict];
                }

            }
            
        }
    }
    
    
    [self setModel];
     VCLog(@"searchResault:%@",searchResault);
    
    
    
    if (searchResault.count == 0) {
        if (singleton.singletonValue.length>=7) {
            areaString = [sqlite searchAreaWithHisNumber:[singleton.singletonValue substringToIndex:7]];
            VCLog(@"areaString:%@",areaString);
        }
        
        opeareString = [singleton.singletonValue isMobileNumberWhoOperation];
        
    }
    
    if (state == 0 && singleton.singletonValue.length == 1) {
        [zzArray removeAllObjects];
    }
    
    [self.tableView reloadData];
    
    //重新获取数据库获取通话记录
    NSMutableArray *array = [sqlite searchInfoFromTable:CALL_RECORDS_TABLE_NAME];
    //排序
    CallRecords = (NSMutableArray *)[[array reverseObjectEnumerator] allObjects];
    [self.tableView reloadData];
    
}


//数据模型
-(void)setModel{
    
    NSMutableArray *arrayM = [NSMutableArray array];
    for (NSDictionary *dict in searchResault) {
        
        Records *record = [[Records alloc] init];
        // 给record赋值
        [record setValuesForKeysWithDictionary:dict];//record:<Records: 0x7fa2f27207c0,personTel: 888-555-1212,personName: John Appleseed>
        [arrayM addObject:record];
        
    }
    //VCLog(@"arrayM:%@",arrayM);
    dataList = arrayM;
    //VCLog(@"arrayM-0:%@",[[arrayM objectAtIndex:0] valueForKey:@"personTel"]);
    
}

-(void)zzStringAndArrayInputchar:(NSString *)inputChar aChar:(NSString *)achar
{
    
    if (zzArray.count <1) {
        NSMutableString *mstring = [[NSMutableString alloc] initWithFormat:@"-%@.*",achar];
        [zzArray addObject:mstring];
    }
    
    NSMutableArray *latterArray = [[NSMutableArray alloc] init];
    
    if (singleton.singletonValue.length>1) {
        for (NSMutableString *sss in zzArray) {
            //-1.* -> -1.*-2[0-9].*
            NSMutableString *str1 = [NSMutableString stringWithFormat:@"%@%@",sss,inputChar];
            
            //-1.* -> -12[0-9].*
            if (sss.length <=14 ) {
                [sss insertString:achar atIndex:sss.length-2];
            }else{
                [sss insertString:achar atIndex:sss.length-12];
            }
            
            
            [latterArray addObject:str1];
            [latterArray addObject:sss];
        }
        
        zzArray =latterArray;
    }
    
    
    VCLog(@"zzArray:%@",zzArray);
    
}

-(void)deleteCharWithLastinput:(NSString *)lastinput{
    
    
    NSMutableArray *lArray = [[NSMutableArray alloc] init];
    if (zzArray.count >1) {
        
        for (int i= 0; i<zzArray.count; i++) {
            if (i%2==0) {
                NSString *sas = zzArray[i];
                
                //NSString *zzs = [sas stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"-%@[0-9,A,B,C]*",lastinput] withString:@""];
                NSString *zzs = [sas substringToIndex:sas.length-14];
                if(![lArray containsObject:zzs])
                    [lArray addObject:zzs];
            }
            
        }
        
        zzArray = lArray;
        VCLog(@"lArray:%@",lArray);
    }
    
}


#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    /*
    if (searchResault.count == 0 && singleton.singletonValue.length>=7) {
        return 1;
    }
    */
    
    if (searchResault.count > 0 && singleton.singletonValue.length>=1) {
        return searchResault.count;
    }
    
    if (searchResault.count <= 0) {
        return [CallRecords count];
    }
    
    return 0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    //用CallRecordsCell做初始化
    CallRecordsCell *cell = [tableView dequeueReusableCellWithIdentifier:@"reuseCell" forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    
        //用户输入时
    if (searchResault.count > 0 && singleton.singletonValue.length>=1 ) {
        Records *record = dataList[indexPath.row];
        cell.hisName.text = record.personName;
        cell.hisNumber.hidden = YES;
        cell.callDirection.hidden = YES;
        cell.callLength.hidden = YES;
        cell.callBeginTime.text = record.personTel;
        cell.hisHome.hidden = YES;
        cell.hisOperator.hidden = YES;
    }/* if (searchResault.count == 0 && singleton.singletonValue.length>=7) {
        cell.hisName.text = singleton.singletonValue;
        cell.callBeginTime.text =[NSString stringWithFormat:@"%@ %@",areaString,opeareString] ;
        cell.hisNumber.hidden = YES;
        cell.callDirection.hidden = YES;
        cell.callLength.hidden = YES;
        cell.hisOperator.hidden = YES;
        cell.hisHome.hidden = YES;
    }*/
    //未输入，显示通话记录
    if(searchResault.count <= 0 ) {
        
        //VCLog(@"CallRecords:%@,indexPath.row:%lu",CallRecords,indexPath.row);
        TXData *aRecord  = [CallRecords objectAtIndex:indexPath.row];

        
        cell.callDirection.hidden = NO;
        cell.callLength.hidden = NO;
        cell.hisNumber.hidden = NO;
        cell.hisHome.hidden = NO;
        cell.hisOperator.hidden = NO;
        cell.hisName.text = aRecord.hisName;
        cell.hisNumber.text = [[aRecord.hisNumber purifyString] insertStr];
        cell.callDirection.image = [self imageForRating:[aRecord.callDirection intValue]];
        cell.callLength.text = aRecord.callLength;
        cell.callBeginTime.text = aRecord.callBeginTime;
        cell.hisHome.text = aRecord.hisHome;
        cell.hisOperator.text = aRecord.hisOperator;
        //没有名字。显示为编辑图标
        if (cell.hisName.text.length>0) {
            [cell.PersonButton setImage:[UIImage imageNamed:@"icon_edit"] forState:UIControlStateNormal];
        }
     
    }
    
    
    [cell.CallButton addTarget:self action:@selector(CallButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [cell.MsgButton addTarget:self action:@selector(MsgButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [cell.PersonButton addTarget:self action:@selector(PersonButtonClick:) forControlEvents:UIControlEventTouchUpInside];

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

#pragma mark -- 3个按钮的跳转
-(void)CallButtonClick:(UIButton *)btn
{
    VCLog(@"callbtn click");
}

-(void)MsgButtonClick:(UIButton *)btn
{
    //自定键盘、callBtn,tabbar隐藏
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:kKeyboardAndTabViewHide object:self]];
    //当前选中行
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    TXData *mdata = [[TXData alloc] init];
    TXData *aRecord = [CallRecords objectAtIndex:indexPath.row];
    mdata.hisName = aRecord.hisName;
    mdata.hisNumber = aRecord.hisNumber;
    mdata.hisHome = aRecord.hisHome;
    
    UIStoryboard *board = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    MsgDetailController *controller = [board instantiateViewControllerWithIdentifier:@"msgDetail"];
    controller.datailDatas = mdata;
    
    [self.navigationController pushViewController:controller animated:YES];
    
}
//
-(void)PersonButtonClick:(UIButton *)btn
{
    //隐藏tabbar和callBtn
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:kHideTabBarAndCallBtn object:self]];
    //当前选中行
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    TXData *aRecord = [CallRecords objectAtIndex:indexPath.row];
    VCLog(@"==================hisname:%@",aRecord.hisName);
    if (aRecord.hisName.length==0 || [aRecord.hisName isEqualToString:@""] || aRecord.hisName ==nil) {
        //跳转到添加联系人
        
        [self showAddperson];
        
        VCLog(@"show newPerson view");
    }else
    {
        //跳转 详情->编辑
        [self showPersonViewControllerWithName:aRecord.hisName];
    }
    
}

#pragma mark -- tableView delegate
//设置cell高度
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
        if ([indexPath isEqual:self.selectedIndexPath]) {
            
            return 50 + 50;
        }
        
        return 50;
    
    
    
}

//单元格可编辑
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return YES;
}


//可编辑样式
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (editingStyle == UITableViewCellEditingStyleDelete)
        
    {
        //删除数据库的数据
        TXData *aRecord = [CallRecords objectAtIndex:indexPath.row];

        [sqlite deleteContacterWithNumber:aRecord.hisNumber formTable:CALL_RECORDS_TABLE_NAME peopleId:nil withSql:DELETE_CALL_RECORD_SQL];
        
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

#pragma mark -- 呼转
//呼转方法
- (IBAction)callAnotherPelple:(UIBarButtonItem *)sender
{
    //BOOL loginstate = [defaults valueForKey:LOGIN_STATE];
    //是否登录？
    
    
    //获取拇机号码,
    NSString *phoneNumber = [defaults valueForKey:muji_bind_number];
    
    //已有number和email
    if (phoneNumber.length>0 ) {
        //获取呼转状态
        [self getCallDivert];
    }else
    {   //没有则弹框提示
        UIAlertView *isNoMujiAlert = [[UIAlertView alloc] initWithTitle:@"想要呼转到拇机？" message:@"请到【发现】中【登录】,然后【配置】拇机号码" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:@"不OK", nil];
        isNoMujiAlert.tag =1100;
        [isNoMujiAlert show];
        
        
        //[self addShadeAndAlertView];
    }

}

-(void)getCallDivert
{
    NSString *number = [defaults valueForKey:muji_bind_number];
    if ([[defaults valueForKey:call_divert_state] intValue]) {
        //已呼转,弹框提示，到拇机123456789321的呼转取消？
        
        UIAlertView *aliert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Alerts", nil) message:[NSString stringWithFormat:@"%@ %@?",NSLocalizedString(@"Cancel_Call_Forwarding", nil),number] delegate:self cancelButtonTitle:NSLocalizedString(@"No", nil) otherButtonTitles:NSLocalizedString(@"Yes", nil), nil];
        aliert.delegate = self;
        aliert.tag =1000;
        [aliert show];
        
    }else{
        //未呼转,弹框提示，手机呼转到拇机123456789321？
        UIAlertView *aliert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Alerts", nil) message:[NSString stringWithFormat:@"%@ %@?",NSLocalizedString(@"Call_Forwarding", nil),number] delegate:self cancelButtonTitle:NSLocalizedString(@"No", nil) otherButtonTitles:NSLocalizedString(@"Yes", nil), nil];
        aliert.delegate = self;
        aliert.tag =1001;
        [aliert show];
    }

}



#pragma mark -- AlertView Delegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSMutableString *str;
    NSDate *date = [NSDate date];
    NSDateFormatter *dfmt = [[NSDateFormatter alloc] init];
    dfmt.dateFormat = @"MMddHHmmss";
    NSString *time;

    /****/
    if (alertView.tag == 1000) {
        if (buttonIndex == 1) {
            //取消呼转
            str = [self cancelCallFrowardingWithNumber: [defaults valueForKey:muji_bind_number]];
            
            //设置状态为0
            [defaults setValue:@"0" forKey:call_divert_state];
            //设定呼转结束时间
            time = [dfmt stringFromDate:date ];
            
            //计算时长
            [self intervalFromStartDate:[defaults valueForKey:CallForwardStartTime] toTheEndDate:time];
            
            //上传
            
            
            
            
            
            
            
        }
    }
    
    
    /****/
    if (alertView.tag == 1001) {
        if (buttonIndex == 1) {
            //设置呼转,
            str = [self setCallForwardingWithNumber:[defaults valueForKey:muji_bind_number]];
            //设置状态为1
            [defaults setValue:@"1" forKey:call_divert_state];
            //设定呼转开始时间
            time = [dfmt stringFromDate:date ];
            [defaults setValue:time forKey:CallForwardStartTime];

        }
    }
    
    if (alertView.tag == 1100) {
        if (buttonIndex == 0) {
            //跳转到-发现
            //disvyCtorl
            UIStoryboard *board = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            discoveryCtrol = [board instantiateViewControllerWithIdentifier:@"disvyCtorl"];
            
            [self.navigationController pushViewController:discoveryCtrol animated:YES];
            
            //隐藏tabbar
            [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:kKeyboardAndTabViewHide object:self]];
            
            
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
//计算两个点时间差
- (NSString *)intervalFromStartDate:(NSString *)sDate toTheEndDate:(NSString *)endDate
{
    NSString *string;
    int startTime = [sDate intValue];//max 1231235959
    int endTime = [endDate intValue];
    
    int duringTime = endTime - startTime;
    
    string = [NSString stringWithFormat:@"%d",duringTime];
    
    VCLog(@"string:%@",string);
    //VCLog(@"int max:%i",INT_MAX);//2147483647
    return string;
}

//设置开通呼转短号
-(NSMutableString *)setCallForwardingWithNumber:(NSString *)string
{
    NSMutableString *str;
    //cmcc
    if ([[self getCarrier] isEqualToString:China_Mobile]) {
        str = [[NSMutableString alloc] initWithFormat:@"**21*tel://%@#",string];
    }
    //unicom
    if ([[self getCarrier] isEqualToString:China_Unicom]) {
        str = [[NSMutableString alloc] initWithFormat:@"**21*tel://%@*11#",[defaults valueForKey:muji_bind_number]];
    }
    //telecom
    if ([[self getCarrier] isEqualToString:China_Telecom]) {
        str = [[NSMutableString alloc] initWithFormat:@"*72tel://%@",[defaults valueForKey:muji_bind_number]];
    }
    
    return str;
}

//设置取消呼转短号
-(NSMutableString *)cancelCallFrowardingWithNumber:(NSString *)string
{
    NSMutableString *str;
    //cmcc
    if ([[self getCarrier] isEqualToString:China_Mobile]) {
        str = [[NSMutableString alloc] initWithFormat:@"tel://##21#"];
    }
    //unicom
    if ([[self getCarrier] isEqualToString:China_Unicom]) {
        str = [[NSMutableString alloc] initWithFormat:@"tel://##21#"];
    }
    //telecom
    if ([[self getCarrier] isEqualToString:China_Telecom]) {
        str = [[NSMutableString alloc] initWithFormat:@"tel://*720"];
    }


    return str;
}

- (NSString*)getCarrier
{
    //获取本机运营商
    CTTelephonyNetworkInfo *tInfo = [[CTTelephonyNetworkInfo alloc] init];
    CTCarrier *carrier = [tInfo subscriberCellularProvider];
    NSString * mcc = [carrier mobileCountryCode];//国家码406
    NSString * mnc = [carrier mobileNetworkCode];//网络码
    if (mnc == nil || mnc.length <1 || [mnc isEqualToString:@"SIM Not Inserted"] ) {
        return @"Unknown";
    }else {
        if ([mcc isEqualToString:@"460"]) {
            NSInteger MNC = [mnc intValue];
            switch (MNC) {
                case 00:
                case 02:
                case 07:
                    return China_Mobile;
                    break;
                case 01:
                case 06:
                    return China_Unicom;
                    break;
                case 03:
                case 05:
                    return China_Telecom;
                    break;
                case 20:
                    return China_TieTong;
                    break;
                default:
                    break;
            }
        }
    }
    
    return @"Unknown";
}


#pragma mark-- 获取通讯录联系人
-(NSMutableArray*)loadContacts
{
    [mutPhoneArray removeAllObjects];
    [phoneDic   removeAllObjects];
    
    //初始化电话簿
    ABAddressBookRef myAddressBook = nil;
    CFErrorRef *error = nil;
    
    //判断ios版本，6.0+需获取权限
    if (IOS_DEVICE_VERSION>=6.0) {
        
        myAddressBook=ABAddressBookCreateWithOptions(NULL, error);
        dispatch_semaphore_t sema=dispatch_semaphore_create(0);
        ABAddressBookRequestAccessWithCompletion(myAddressBook, ^(bool greanted, CFErrorRef error){
            dispatch_semaphore_signal(sema);
        });
        
        dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
        
    }
    else
    {
        //6.0以下直接获取
        
        myAddressBook = ABAddressBookCreateWithOptions(nil, error);
        //myAddressBook =ABAddressBookCreate();
    }
    
    if (myAddressBook==nil) {
        return nil;
    };
    
    //取得本地所有联系人记录
    CFArrayRef results = ABAddressBookCopyArrayOfAllPeople(myAddressBook);
    //VCLog(@"results：%@",results);
    
    CFMutableArrayRef mresults=CFArrayCreateMutableCopy(kCFAllocatorDefault,CFArrayGetCount(results),results);
    
    //将结果按照拼音排序，将结果放入mresults数组中
    
    CFArraySortValues(mresults,
                      CFRangeMake(0, CFArrayGetCount(results)),
                      (CFComparatorFunction) ABPersonComparePeopleByName,
                      ((void*)ABPersonGetSortOrdering()));
    
    //遍历所有联系人
    for (int k=0;k<CFArrayGetCount(mresults);k++) {
        NSMutableDictionary *tempDic = [[NSMutableDictionary alloc] init];
        //管理地址簿中条目的基类对象是 ABRecord,可以表示一个人 或者一个群体 ABGroup。ABRecord 的指针，标示为 ABRecordRef
        ABRecordRef record=CFArrayGetValueAtIndex(mresults,k);
        //返回个人或群体完整名称
        //NSString *personname = (__bridge NSString *)ABRecordCopyCompositeName(record);
        
        NSString *firstName =(__bridge NSString *)ABRecordCopyValue(record, kABPersonSortByFirstName);  //返回个人名字
        NSString *lastName =(__bridge NSString *)ABRecordCopyValue(record, kABPersonSortByLastName);    //返回个人姓
        NSString *name;
        if (firstName.length>0 && lastName.length>0) {
            name = [[NSString alloc] initWithFormat:@"%@ %@",firstName,lastName];
        }else if (firstName.length == 0 && lastName.length>0){
            name = [[NSString alloc] initWithFormat:@"%@",lastName];
        }else if (firstName.length >0 && lastName.length==0){
            name = [[NSString alloc] initWithFormat:@"%@",firstName];
        }else
        {
            name = [[NSString alloc] initWithFormat:NSLocalizedString(@"Unknow", nil)];
        }
        
        
        NSString *namePinYin = [name hanziTopinyin];
        NSString *nameNum = [namePinYin pinyinTrimIntNumber];//转数字
        
        //获取电话号码，通用的，基本的,概括的
        ABMultiValueRef personPhone = ABRecordCopyValue(record, kABPersonPhoneProperty);
        //记录在底层数据库中的ID号。具有唯一性
        ABRecordID recordID=ABRecordGetRecordID(record);
        //循环取出详细的每条号码记录
        for (int k = 0; k<ABMultiValueGetCount(personPhone); k++)
        {
            NSString * phone = (__bridge NSString*)ABMultiValueCopyValueAtIndex(personPhone, k);
            //加入phoneDic中
            [phoneDic setObject:(__bridge id)(record) forKey:[NSString stringWithFormat:@"%@%d",phone,recordID]];
            [tempDic setObject:phone forKey:@"personTel"];//把每一条号码存为key:“personTel”的Value
            
            NSString *phoneNum = [NSString stringWithFormat:@"-%@",phone];
            [tempDic setObject:phoneNum forKey:@"personTelNum"];//-数字号码
            //VCLog(@"phoneNum:%@",phoneNum);
            
        }
        [tempDic setObject:name forKey:@"personName"];//把名字存为key:"personName"的Value
        [tempDic setObject:nameNum forKey:@"personNameNum"];//把数字名字保存
        
        //VCLog(@"tempDictemp：%@",tempDic);
        [mutPhoneArray addObject:tempDic];//把tempDic赋给phoneArray数组
        
    }
    VCLog(@"mutPhoneArray：%@",mutPhoneArray);
    
    //[self setModel];
    return mutPhoneArray;
    
}



#pragma mark -- 跳转到添加联系人
//跳转到add联系人
-(void)showAddperson
{
    ABNewPersonViewController *newPerson = [[ABNewPersonViewController alloc]init];
    newPerson.newPersonViewDelegate=self;
    newPerson.title = NSLocalizedString(@"Add_Ctontacts", nil);
    [self.navigationController pushViewController:newPerson animated:YES];
}
#pragma mark --new person
-(void)newPersonViewController:(ABNewPersonViewController *)newPersonView didCompleteWithNewPerson:(ABRecordRef)person
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}


#pragma mark -- 跳转到编辑联系人
//跳转到edit联系人
-(void)showPersonViewControllerWithName:(NSString *)string{
    CFStringRef name = (__bridge CFStringRef)string;
    //CFErrorRef *error;
    //  获取通讯录
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL,NULL) ;//ABAddressBookCreate()
    //  查找名字为Appleseed的联系人
    NSArray *people = (__bridge NSArray *)ABAddressBookCopyPeopleWithName(addressBook,name);//
    // 若找到了，显示其信息
    if ((people != nil) && [people count])
    {
        ABRecordRef person = (__bridge ABRecordRef)[people objectAtIndex:0];
        ABPersonViewController *picker = [[ABPersonViewController alloc] init];
        picker.personViewDelegate = self;
        picker.displayedPerson = person;
        picker.allowsEditing = YES;//是否显示编辑按钮
        picker.allowsActions = NO;//是否显示可以打电话发信息
        [self.navigationController pushViewController:picker animated:YES];
        
    }
    else
    {
        // 提示找不到联系人
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:[NSString stringWithFormat:@"Could not find %@",string] delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles:nil];
        [alert show];
        
    }
    
    CFRelease(addressBook);
    
}

#pragma mark --ABPersonViewControllerDelegate methods
// Does not allow users to perform default actions such as dialing a phone number, when they select a contact property. 不允许用户执行默认行为如拨电话号码，当他们选择一个联系人。
- (BOOL)personViewController:(ABPersonViewController *)personViewController shouldPerformDefaultActionForPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifierForValue
{
    return NO;
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    //移除通知
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kInputCharNoti object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kDeleteCharNoti object:nil];

    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
