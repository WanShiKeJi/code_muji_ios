//
//  ShowContactsController.m
//  TXBoxNew
//
//  Created by Naron on 15/6/5.
//  Copyright (c) 2015年 playtime. All rights reserved.
//

#define personTel @"personTel"
#define personName @"personName"

#import "ShowContactsController.h"
#import "ShowContactsCell.h"
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>

@interface ShowContactsController ()

{
    NSMutableArray *mutPhoneArr;
    NSMutableDictionary *phoneDic;      //同一个人的手机号码dic
    NSMutableArray *selectArray;
}
@property (weak, nonatomic) IBOutlet UIBarButtonItem *cancelBtn;

@end

@implementation ShowContactsController

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:kHideCusotomTabBar object:self]];
    self.tabBarController.tabBar.hidden = YES;
    [self loadContacts];
    [self addFootview];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    mutPhoneArr = [[NSMutableArray alloc] init];
    phoneDic = [[NSMutableDictionary alloc] init];
    selectArray = [[NSMutableArray alloc] init];
    
    
}

-(void)addFootview
{
    UIView *footv = [[UIView alloc] initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, 37)];
    UILabel *line =[[UILabel alloc] initWithFrame:CGRectMake(0, 1, DEVICE_HEIGHT, 1)];
    
    line.backgroundColor = [UIColor grayColor];
    line.alpha = .3;
    [footv addSubview:line];
    
    UILabel *text = [[UILabel alloc] initWithFrame:CGRectMake(0, 8, DEVICE_WIDTH, 25)];
    text.text = [NSString stringWithFormat:@"共%lu位联系人",mutPhoneArr.count];
    text.textAlignment = NSTextAlignmentCenter;
    text.font = [UIFont systemFontOfSize:16];
    
    UILabel *line2 =[[UILabel alloc] initWithFrame:CGRectMake(0, 36, DEVICE_HEIGHT, 1)];
    
    line2.backgroundColor = [UIColor grayColor];
    line2.alpha = .3;
    [footv addSubview:line2];
    
    [footv addSubview:text];
    self.tableView.tableFooterView = footv;


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
    return mutPhoneArr.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ShowContactsCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ShowContactsCellID" forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    
    
    cell.name.text = [[mutPhoneArr objectAtIndex:indexPath.row] valueForKey:personName];
    cell.number.text = [[mutPhoneArr objectAtIndex:indexPath.row] valueForKey:personTel];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView
                             cellForRowAtIndexPath: indexPath ];
    
    
    if (cell.accessoryType ==UITableViewCellAccessoryNone){
        cell.accessoryType =UITableViewCellAccessoryCheckmark;
        //选中，如果数组里没有，则add
        if (![selectArray containsObject:[mutPhoneArr objectAtIndex:indexPath.row]]) {
            [selectArray addObject:[mutPhoneArr objectAtIndex:indexPath.row]];
        }
        //VCLog(@"selectArray:%@",selectArray);
        
        
    }
    else{
        
        cell.accessoryType =UITableViewCellAccessoryNone;
        //如果数组里有，则remove
        if ([selectArray containsObject:[mutPhoneArr objectAtIndex:indexPath.row]]) {
            [selectArray removeObject:[mutPhoneArr objectAtIndex:indexPath.row]];
        }
        
        //VCLog(@"selectArray:%@",selectArray);
    }
    
    if (selectArray.count >0) {
        [self.cancelBtn setTitle:@"取消"];
    }else{
        [self.cancelBtn setTitle:@""];
    }
    
    VCLog(@"selectArray:%@",selectArray);
    //[self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}



#pragma mark-- 获取通讯录联系人
-(void)loadContacts
{
    [mutPhoneArr removeAllObjects];
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
        return ;
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
            //加入phoneDic中
            [phoneDic setObject:(__bridge id)(record) forKey:[NSString stringWithFormat:@"%@%d",phone,recordID]];
            [tempDic setObject:phone forKey:personTel];//把每一条号码存为key:“personTel”的Value
            
        }
        [tempDic setObject:name forKey:personName];//把名字存为key:"personName"的Value
        
        //VCLog(@"tempDictemp：%@",tempDic);
        [mutPhoneArr addObject:tempDic];//把tempDic赋给phoneArray数组
        
    }
    VCLog(@"mutPhoneArr：%@",mutPhoneArr);
    
    //return mutPhoneArr;
    
}



/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

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
- (IBAction)cancelClick:(UIBarButtonItem *)sender {
    
    if ([self.cancelBtn.title isEqualToString:@"取消"]) {
        //取消选中
        
        //移除数组
        
    }
    //[self dismissViewControllerAnimated:YES completion:nil];
    
    
    
}





-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
}

@end
