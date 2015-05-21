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
#import "PinYin4Objc.h"
#import "TXTelNumSingleton.h"
#import "TXKeyView.h"
#import "CustomTabBarView.h"
#import "Records.h"

@interface CallController ()<UITextFieldDelegate,ABPersonViewControllerDelegate,ABNewPersonViewControllerDelegate,UIAlertViewDelegate,PopViewDelegate>
{
    NSMutableArray *CallRecords;
    TXSqliteOperate *sqlite;
    CallingController *calling;
    
    MsgDatas *msgdata;
    UIWebView *webView;
    UIView *shadeView;  //遮罩层
    PopView *popview;   //提示框
    UIAlertView *_alertView; //提示框
    NSUserDefaults *defaults;
    NSMutableArray *mutPhoneArray;
    NSMutableDictionary *phoneDic;      //同一个人的手机号码dic

    TXTelNumSingleton *singleton;   //获取输入的号码
    NSMutableArray *searchResault;
    NSArray *dataList;
}

- (IBAction)callAnotherPelple:(UIBarButtonItem *)sender;
@property (weak,nonatomic) UIAlertController *alertc;
@property (strong,nonatomic) NSIndexPath *selectedIndexPath;        //被选中
@end


@implementation CallController

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //键盘活动  键盘出现时
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWasShow:) name:UIKeyboardDidShowNotification object:nil];
    
    //显示tabbar
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:kShowCusotomTabBar object:self]];
    //textInput
    if([self respondsToSelector:@selector(inputTextDidChanged:)]) {
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(inputTextDidChanged:) name:ktextChangeNotify object:nil];
    }
    
    //查询数据库获取通话记录
    NSMutableArray *array = [sqlite searchInfoFrom:CALL_RECORDS_TABLE_NAME];
    //排序
    CallRecords = (NSMutableArray *)[[array reverseObjectEnumerator] allObjects];
    [self.tableView reloadData];
    
}

//键盘显示
- (void)keyboardWasShow:(NSNotification*)aNotification
{
    NSDictionary* info = [aNotification userInfo];
    /*
     NSNumber *duration = [info objectForKey:UIKeyboardAnimationDurationUserInfoKey];
     VCLog(@"duration:%@",duration);
     CGRect beginRect = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue];
     */
    CGRect endRect = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    VCLog(@"·······%f",endRect.size.height);
    [UIView beginAnimations:@"" context:nil];
    popview.frame =  CGRectMake((DEVICE_WIDTH-PopViewWidth)/2, DEVICE_HEIGHT-PopViewHeight-endRect.size.height, PopViewWidth, PopViewHeight);
    [UIView setAnimationDuration:.25];
    [UIView commitAnimations];
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
    
    //创建提醒对话框
    _alertView = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"Please_enter_the_correct_info", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"Sure", nil) otherButtonTitles:nil, nil];
    _alertView.delegate = self;
    [_alertView textFieldAtIndex:0];//获取输入框，在UIAlertViewStyle -> input模式
    
    
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
    
    //[self hanziTopinyin];
}


#pragma mark -- 用户输入时
-(void)inputTextDidChanged:(NSNotification*)notifi{
    
    NSPredicate *preicate = [NSPredicate predicateWithFormat:@"(SELF.personName CONTAINS[cd] %@) or (self.personTel contains[cd] %@)", singleton.singletonValue,singleton.singletonValue ];
    
    if (searchResault!= nil) {
        [searchResault removeAllObjects];
    }
    
    //过滤数据
    searchResault = [NSMutableArray arrayWithArray:[dataList filteredArrayUsingPredicate:preicate]];
    
    VCLog(@"searchRes%@",searchResault);
    VCLog(@"%@",singleton.singletonValue);
    
    
    [self.tableView reloadData];
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    if (singleton.singletonValue.length !=0) {
        return searchResault.count;
    }
    return [CallRecords count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    //用CallRecordsCell做初始化
    CallRecordsCell *cell = [tableView dequeueReusableCellWithIdentifier:@"reuseCell" forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    //1.是原来的表
    //更新cell的label，让其显示data对象的itemName
    TXData *aRecord = [CallRecords objectAtIndex:indexPath.row];
    
    
        //2.用户输入时
    if (singleton.singletonValue.length!=0) {
        Records *record = searchResault[indexPath.row];
        cell.hisName.text = record.personName;
        cell.hisNumber.text = record.personTel;
    }else{
        cell.hisName.text = aRecord.hisName;
        cell.hisNumber.text = [[aRecord.hisNumber purifyString] insertStr];
        cell.callDirection.image = [self imageForRating:[aRecord.callDirection intValue]];
        cell.callLength.text = aRecord.callLength;
        cell.callBeginTime.text = aRecord.callBeginTime;
        cell.hisHome.text = aRecord.hisHome;
        cell.hisOperator.text = aRecord.hisOperator;
        
    }
    //没有名字。显示为编辑图标
    if (cell.hisName.text.length!=0) {
        [cell.PersonButton setImage:[UIImage imageNamed:@"icon_edit"] forState:UIControlStateNormal];
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
    TXData *aRecord = [CallRecords objectAtIndex:indexPath.row];
    msgdata.hisName = aRecord.hisName;
    msgdata.hisNumber = aRecord.hisNumber;
    msgdata.hisHome = aRecord.hisHome;
    
    UIStoryboard *board = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    MsgDetailController *controller = [board instantiateViewControllerWithIdentifier:@"msgDetail"];
    controller.datailDatas = msgdata;
    
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

#pragma mark -- 呼转
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
    [self.view.window addSubview:shadeView];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(shadeViewTap:)];
    tap.numberOfTapsRequired = 1;
    [shadeView addGestureRecognizer:tap];
    
    
    //pop
    popview = [[PopView alloc] initWithFrame:CGRectMake((DEVICE_WIDTH-PopViewWidth)/2, DEVICE_HEIGHT-PopViewHeight-216, PopViewWidth, PopViewHeight)];
    popview.delegate = self;
    [popview initWithTitle:NSLocalizedString(@"The_Call_Forwarding_was_get_info", nil) firstMsg:NSLocalizedString(@"E-mail", nil) secondMsg:NSLocalizedString(@"MuJi-Number", nil) cancelButtonTitle:NSLocalizedString(@"Cancel", nil) otherButtonTitles:NSLocalizedString(@"Sure", nil)];
    
    
    [self.view.window addSubview:popview];
}

-(void)shadeViewTap:(UIGestureRecognizer *)recongnizer
{
    VCLog(@"-------tap");
    
    [shadeView removeFromSuperview];
    [popview removeFromSuperview];
}

#pragma mark-- popview delegate
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
        if (email.length<=0 || number.length<=0 || ![number isValidateMobile:number]) {
            [_alertView show];
        }else
        {
            //本地保存数据
            [defaults setValue:email forKey:email_number];
            [defaults setValue:number forKey:muji_bind_number];
            
            //上传到服务器
            /*
            AVUser *auser = [AVUser user];
            auser.username = sfield.text;//号码
            auser.password = @"";
            auser.email = ffield.text;//邮箱
            
            [auser signUpInBackgroundWithBlock:^(BOOL suc,NSError *error){
                
                if (suc) {
                    VCLog(@"sign suc");
                }else{
                    VCLog(@"reg error-code:%ld errorInfo:%@",(long)error.code,error.localizedDescription);
                    UIAlertView *alert =[[UIAlertView alloc] initWithTitle:error.localizedDescription message:nil delegate:self cancelButtonTitle:@"是" otherButtonTitles:nil, nil];
                    alert.delegate = self;
                    [alert show];
                }
            }];
            */
             
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
        
        
        //获取电话号码，通用的，基本的,概括的
        ABMultiValueRef personPhone = ABRecordCopyValue(record, kABPersonPhoneProperty);
        //记录在底层数据库中的ID号。具有唯一性
        ABRecordID recordID=ABRecordGetRecordID(record);
        //循环取出详细的每条号码记录
        for (int k = 0; k<ABMultiValueGetCount(personPhone); k++)
        {
            NSString * phone = (__bridge NSString*)ABMultiValueCopyValueAtIndex(personPhone, k);
            //范围0~3
            NSRange range=NSMakeRange(0,3);
            NSString *str=[phone substringWithRange:range];
            //若前3个字符为+86，从后一位开始取出
            if ([str isEqualToString:@"+86"]) {
                phone=[phone substringFromIndex:3];
            }
            //加入phoneDic中
            [phoneDic setObject:(__bridge id)(record) forKey:[NSString stringWithFormat:@"%@%d",phone,recordID]];
            [tempDic setObject:phone forKey:@"personTel"];//把每一条号码存为key:“personTel”的Value
            
        }
        [tempDic setObject:name forKey:@"personName"];//把名字存为key:"personName"的Value
        //VCLog(@"tempDictemp：%@",tempDic);
        [mutPhoneArray addObject:tempDic];//把tempDic赋给phoneArray数组
        
    }
    VCLog(@"mutPhoneArray：%@",mutPhoneArray);
    
    [self setModel];
    return mutPhoneArray;
    
}

//数据模型
-(void)setModel{
    
    NSMutableArray *arrayM = [NSMutableArray array];
    for (NSDictionary *dict in mutPhoneArray) {
        
        Records *record = [[Records alloc] init];
        // 给record赋值
        [record setValuesForKeysWithDictionary:dict];//record:<Records: 0x7fa2f27207c0,personTel: 888-555-1212,personName: John Appleseed>
        [arrayM addObject:record];
        
    }
    VCLog(@"arrayM:%@",arrayM);
    dataList = arrayM;
    //VCLog(@"arrayM-0:%@",[[arrayM objectAtIndex:0] valueForKey:@"personTel"]);
}

#pragma mark -- 汉字转拼音
-(void)hanziTopinyin{
    
    HanyuPinyinOutputFormat *outputFormat =[[HanyuPinyinOutputFormat alloc] init];
    [outputFormat setToneType:ToneTypeWithoutTone];//声调
    [outputFormat setVCharType:VCharTypeWithV];
    [outputFormat setCaseType:CaseTypeLowercase];//大小写
    
    NSMutableArray *arr = [[NSMutableArray alloc] initWithObjects:@"你好",@"大家好",@"李显示",@"我在", nil];
    NSMutableArray *arr2 =[[NSMutableArray alloc] init];
    for (int i=0; i<arr.count; i++) {
        NSString *outputPinyin = [PinyinHelper toHanyuPinyinStringWithNSString:arr[i] withHanyuPinyinOutputFormat:outputFormat withNSString:@""];
        VCLog(@"outputPinyin:%@",outputPinyin);
        [arr2 addObject:outputPinyin];
        
    }
    VCLog(@"arr:%@",arr2);
    
    
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


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
