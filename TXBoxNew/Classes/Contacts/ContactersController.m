//
//  ContactersController.m
//  TXBoxNew
//
//  Created by Naron on 15/4/25.
//  Copyright (c) 2015年 playtime. All rights reserved.
//

#import "ContactersController.h"
#import "ContactsCell.h"
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
#import "pinyin.h"
#import "Records.h"
#import "NSString+helper.h"
#import "BATableView.h"
#import "MsgDetailController.h"
#import "MsgDatas.h"

@interface ContactersController ()<UISearchBarDelegate,UISearchResultsUpdating,BATableViewDelegate,ABNewPersonViewControllerDelegate>
{
    NSMutableDictionary *sectionDic;    //sections数据
    NSMutableDictionary *phoneDic;      //同一个人的手机号码dic，
    NSMutableArray *phoneArray;         //联系人({name:@"",tel:@""},{name:@"",tel:@""})
    NSArray *sortedArray;               //排序后的数组
    ABNewPersonViewController *newPerson;
    MsgDatas *msgdata;
}

@property (strong,nonatomic) UISearchBar *conSearchBar;    //搜索框
@property (strong,nonatomic) UISearchController *searchController;  //实现disPlaySearchBar
@property (strong,nonatomic) NSMutableArray *searchsArray;          //搜索后的结果数组
@property (retain,nonatomic) NSArray *dataList;                     //存放数据模型数组
@property (strong,nonatomic) NSIndexPath *selectedIndexPath;        //被选中

@property (nonatomic, strong) BATableView *contactTableView;


@end

@implementation ContactersController



- (void)viewDidLoad {
    [super viewDidLoad];
    
    sectionDic= [[NSMutableDictionary alloc] init];
    phoneDic=[[NSMutableDictionary alloc] init];
    phoneArray = [[NSMutableArray alloc] init];
    msgdata = [[MsgDatas alloc] init];
    
    [self createTableView];
    
    //分割线为none
    [self.contactTableView.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    
    //指定其协议
    self.conSearchBar.placeholder = @"搜索";
    //self.tableView.tableHeaderView = self.conSearchBar;
    //self.tableView.sectionIndexBackgroundColor = [UIColor clearColor];//设置索引的背景颜色
    self.conSearchBar.delegate = self;
    
    self.selectedIndexPath = nil;
    
    [self initSearchController];
    
    
}

//页面即将展示
-(void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    
    //获取所有联系人
    [self loadContacts];
    [self PacketSequencing];
    
    //刷新表格数据
    [self.contactTableView reloadData];
    //通知显示tabBar
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:kShowCusotomTabBar object:self]];
    
    
    
    
}

// 创建tableView
- (void) createTableView {
    self.contactTableView = [[BATableView alloc] initWithFrame:self.view.bounds];
    self.contactTableView.delegate = self;
    [self.view addSubview:self.contactTableView];
}

-(void) initSearchController
{
    //需要初始化一下UISearchController:
    
    _searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    
    _searchController.searchResultsUpdater = self;
    
    _searchController.dimsBackgroundDuringPresentation = YES;//搜索时背景遮罩
    
    _searchController.hidesNavigationBarDuringPresentation = YES;//搜索时隐藏导航栏
    
    _searchController.searchBar.frame = CGRectMake(self.searchController.searchBar.frame.origin.x, self.searchController.searchBar.frame.origin.y, self.searchController.searchBar.frame.size.width, 44.0);
    
    self.contactTableView.tableView.tableHeaderView = self.searchController.searchBar;
    [self.view addSubview:self.searchController.view];
}


// 导入通讯录
-(NSMutableArray*)loadContacts
{
    [phoneArray removeAllObjects];
    [sectionDic removeAllObjects];
    [phoneDic   removeAllObjects];
    
    //设置sectionDic的键（key）,无值
    for (int i = 0; i < 26; i++){
        
        [sectionDic setObject:[NSMutableArray array] forKey:[NSString stringWithFormat:@"%c",'A'+i]];
    }
    [sectionDic setObject:[NSMutableArray array] forKey:[NSString stringWithFormat:@"%c",'#']];
    
    
    //初始化电话簿
    ABAddressBookRef myAddressBook = nil;
    
    //判断ios版本，6.0+需获取权限
    if (IOS_DEVICE_VERSION>=6.0) {
        
        myAddressBook=ABAddressBookCreateWithOptions(NULL, NULL);
        dispatch_semaphore_t sema=dispatch_semaphore_create(0);
        ABAddressBookRequestAccessWithCompletion(myAddressBook, ^(bool greanted, CFErrorRef error){
            dispatch_semaphore_signal(sema);
        });
        
        dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
        
    }
    else
    {
        //6.0以下直接获取
        CFErrorRef *error = nil;
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
            name = [[NSString alloc] initWithFormat:@"未知名字"];
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
        [phoneArray addObject:tempDic];//把tempDic赋给phoneArray数组
        
    }
    VCLog(@"phoneArray：%@",phoneArray);
    
    //数据模型
    [self setModel];
    
    return phoneArray;
    
    /***
     *  __bridge               arc显式转换。 与__unsafe_unretained 关键字一样 只是引用。
     *  __bridge_retained      类型被转换时，其对象的所有权也将被变换后变量所持有
     *  __bridge_transfer      本来拥有对象所有权的变量，在类型转换后，让其释放原先所有权 就相当于__bridge_retained后，原对像执行了release操作
     */
    
}


#pragma mark-对所有联系人进行分组排序

-(void)PacketSequencing{
    
    //分区title数组
    NSMutableArray *sectionArray = [[NSMutableArray alloc] init];
    NSString *sectionName;  //分区title，如A,B,C,D,#
    for (int i=0; i<phoneArray.count; i++) {
        
        //取出phoneArray中的“personName”，的第0个字符
        char firstChar = pinyinFirstLetter([[phoneArray[i] objectForKey:@"personName"] characterAtIndex:0]);
        //  若firstChar再 a~z 之间，顺序排列
        if ((firstChar >='a' && firstChar<='z')||(firstChar>='A' && firstChar<='Z')) {
            
            sectionName = [[NSString stringWithFormat:@"%c",firstChar] uppercaseString];
            
        }
        else {
            sectionName=[[NSString stringWithFormat:@"%c",'#'] uppercaseString];
        }
        //把phoneArray[i]添加到sectionDic的key中
        [[sectionDic objectForKey:sectionName] addObject:phoneArray[i]];
        
        //字符在数组中不存在，则加入
        if (![sectionArray containsObject:sectionName]) {
            
            [sectionArray addObject:sectionName];
        }
        
    }
    
    //对数组排序
    sortedArray =[sectionArray sortedArrayUsingSelector:@selector(compare:)];
    
    VCLog(@"sectionDic :%@",sectionDic );
    VCLog(@"sortedArray :%@",sortedArray);
}

//返回分区
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    //是搜索后的tableView
    if (self.searchController.active) {
        return 1;
    }
    return sortedArray.count;//否则返回索引个数
}


//返回行数/每个分区
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (self.searchController.active) {
        return self.searchsArray.count;
    }
    
    //返回sectionDic的 key里有值的value的个数
    NSString *key=[NSString stringWithFormat:@"%@",sortedArray[section]];
    
    return  [[sectionDic objectForKey:key] count];
    
}


//返回分区title
-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    
    if (self.searchController.active) {
        return nil;
    }
    //返回和右侧索引相同的title
    if ([tableView isEqual:self.contactTableView.tableView]) {
        
        //VCLog(@"key_section_title : %@",sortedArray[section]);
        return  sortedArray[section];
        
    }
    
    return nil;
}

//返回索引
-(NSArray *)sectionIndexTitlesForABELTableView:(BATableView *)tableView
{
    //是原始表，返回A~Z#;
    if (!self.searchController.active) {
        
        NSMutableArray *indices = [[NSMutableArray alloc]init];
        //[indices addObject:@"{search}"];//放大镜图标
        
        for (int i =0; i<sortedArray.count; i++) {
            [indices addObject:sortedArray[i]];
        }
        [indices addObject:@"#"];
        //VCLog(@"indices :%@",indices);
        return indices;
    }
    
    
    return nil;
}

//返回行（单元格）
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    //ContactsCell *cell = [tableView dequeueReusableCellWithIdentifier:@"contactsCell" forIndexPath:indexPath];
    //cell.selectionStyle = UITableViewCellSelectionStyleNone;//取消cell选中背景色
    static NSString *CellIdentifier = @"CellID";
    
    ContactsCell *cell = (ContactsCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil){
        //加载cell-xib
        cell = [[[NSBundle mainBundle] loadNibNamed:@"ContactsCell" owner:self options:nil] objectAtIndex:0];
        
    }
    //取消cell 选中背景色
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    
    //搜索后
    if (self.searchController.active) {
        //把searchArray根据每行显示
        Records *record = self.searchsArray[indexPath.row];
        cell.nameLabel.text = record.personName;
    }
    else{
        //原生表
        NSString *key=[NSString stringWithFormat:@"%@",sortedArray[indexPath.section]];
        
        NSMutableArray *persons=[sectionDic objectForKey:key];
        
        cell.nameLabel.text = [[persons objectAtIndex:indexPath.row] objectForKey:@"personName"];
        //cell.numberLabel.text = [[persons objectAtIndex:indexPath.row] objectForKey:@"personTel"];
        cell.numberLabel.text = [[[[persons objectAtIndex:indexPath.row] objectForKey:@"personTel"] purifyString] insertStr];
        VCLog(@"name:%@,number:%@",cell.nameLabel.text,cell.numberLabel.text);
        
        [cell.msgsBtn addTarget:self action:@selector(msgsBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return cell;
}
-(void)msgsBtnClick:(UIButton *)btn
{
    
    //进入msgDetail
    UIStoryboard *board = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    MsgDetailController *msgDetail = [board instantiateViewControllerWithIdentifier:@"msgDetail"];
    
    NSIndexPath *indexPath = [self.contactTableView.tableView indexPathForSelectedRow];
    NSString *key=[NSString stringWithFormat:@"%@",sortedArray[indexPath.section]];
    
    NSMutableArray *persons=[sectionDic objectForKey:key];

    
    msgdata.hisName = [[persons objectAtIndex:indexPath.row] objectForKey:@"personName"];
    msgdata.hisNumber = [[[persons objectAtIndex:indexPath.row] objectForKey:@"personTel"] purifyString];
    msgdata.hisHome = @"home";
    msgDetail.datailDatas =msgdata;
    [self.navigationController pushViewController:msgDetail animated:YES];
    
    VCLog(@"msgsclick");
}

//点击单元格
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

//设置cell高度
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([indexPath isEqual:self.selectedIndexPath]) {
        
        return kCellHeight + 40.f;
    }
    
    return kCellHeight;
    
}


//数据模型
-(void)setModel{
    
    NSMutableArray *arrayM = [NSMutableArray array];
    for (NSDictionary *dict in phoneArray) {
        
        Records *record = [[Records alloc] init];
        // 给record赋值
        [record setValuesForKeysWithDictionary:dict];//record:<Records: 0x7fa2f27207c0,personTel: 888-555-1212,personName: John Appleseed>
        [arrayM addObject:record];
        
    }
    VCLog(@"arrayM:%@",arrayM);
    self.dataList = arrayM;
    //VCLog(@"arrayM-0:%@",[[arrayM objectAtIndex:0] valueForKey:@"personTel"]);
}

#pragma mark -- searchController 协议方法

//返回搜索结果
-(void) updateSearchResultsForSearchController:(UISearchController *)searchController
{
    NSString *searchString = [self.searchController.searchBar text];
    
    //NSPredicate *preicate = [NSPredicate predicateWithFormat:@"(SELF.personName CONTAINS[c] %@) OR (SELF.personTel contains [c] %@)", searchString];
    NSPredicate *preicate = [NSPredicate predicateWithFormat:@"(SELF.personName CONTAINS[c] %@) or (self.personTel contains[c] %@)", searchString,searchString ];
    
    if (self.searchsArray!= nil) {
        [self.searchsArray removeAllObjects];
    }
    
    //过滤数据
    self.searchsArray= [NSMutableArray arrayWithArray:[_dataList filteredArrayUsingPredicate:preicate]];
    VCLog(@"searchArray :%@",self.searchsArray);
    VCLog(@"preicate :%@",preicate);
    //刷新表格
    
    [self.contactTableView reloadData];
}

/*改变删除按钮的text*/
-(NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return @"删除";
}

// 是否可以编辑
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return NO;
}

// 支持编辑类型
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    if (editingStyle == UITableViewCellEditingStyleDelete)
        
    {
        NSMutableArray *array = [ [ NSMutableArray alloc ] init ];
        
        [ array addObject: indexPath];
        
        //移除数组的元素
        [phoneArray removeObjectAtIndex:indexPath.row];
        
        //删除单元格
        [ self.contactTableView.tableView deleteRowsAtIndexPaths: array withRowAnimation: UITableViewRowAnimationLeft];
        
        //排序
        [self PacketSequencing];
        
        //刷新表格数据
        [self.contactTableView reloadData];
        
        //
        
        NSString *key=[NSString stringWithFormat:@"%@",sortedArray[indexPath.section]];
        
        NSMutableArray *persons=[sectionDic objectForKey:key];
        //VCLog(@"persons :%@",persons);
        
        NSString *str = [[persons objectAtIndex:indexPath.row] objectForKey:@"personName"];
        
        VCLog(@"personName:%@",str);
        
        //删除通讯录联系人
        
    }
    
    
    
}

#pragma mark --删除联系人
//根据名字以及手机号码删除联系人
-(BOOL)delete:(NSString *)name mobile:(NSString *)pNumber
{
    CFErrorRef *error;
    
    // 1.初始化并创建通讯录对象，记得释放内存
    ABAddressBookRef addressBook = ABAddressBookCreate();
    
    NSArray *array = (__bridge NSArray *)ABAddressBookCopyArrayOfAllPeople(addressBook);
    // 3.遍历所有的联系人并修改指定的联系人
    for (id obj in array) {
        ABRecordRef people = (__bridge ABRecordRef)obj;
        //名
        NSString *ln = (__bridge NSString *)ABRecordCopyValue(people, kABPersonLastNameProperty);
        //姓
        NSString *fn = (__bridge NSString *)ABRecordCopyValue(people, kABPersonFirstNameProperty);
        ABMultiValueRef mv = ABRecordCopyValue(people, kABPersonPhoneProperty);
        //手机号
        NSArray *phones = (__bridge NSArray *)ABMultiValueCopyArrayOfAllValues(mv);
        
        NSString *s = [[NSString alloc] initWithFormat:@"%@%@",fn,ln];
        BOOL phoneNumber=NO;
        for (NSString *p in phones) {
            //NSString *str = [p iPhoneStandardFormat];
            // 由于获得到的电话号码可能不符合标准，所以要先将其格式化再比较是否存在
            if ([p isEqual:pNumber]) {
                phoneNumber = YES;
                break;
            }
        }
        
        //若找到的名字和号码相匹配，执行删除
        if ([s isEqualToString:[name trimOfString]] && phoneNumber) {
            
            ABAddressBookRemoveRecord(addressBook, people, error);
            
        }
    }
    //保存
    ABAddressBookSave(addressBook, error);
    // 释放通讯录对象的内存
    if (addressBook) {
        CFRelease(addressBook);
    }
    
    return YES;
}


#pragma mark -- 新增联系人
-(IBAction)addNewContacts:(UIBarButtonItem *)sender
{
    newPerson =[[ABNewPersonViewController alloc] init];
    newPerson.newPersonViewDelegate = self;
    
    [self.navigationController pushViewController:newPerson animated:YES];

    
}

//返回
-(void)newPersonViewController:(ABNewPersonViewController *)newPersonView didCompleteWithNewPerson:(ABRecordRef)person
{
    VCLog(@"add new people:%@",person);
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


@end
