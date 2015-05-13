//
//  DiscoverController.m
//  TXBoxNew
//
//  Created by Naron on 15/4/16.
//  Copyright (c) 2015年 playtime. All rights reserved.
//

#import "DiscoverController.h"
#import "PopView.h"
#import "NSString+helper.h"
#import "BLEDevicesController.h"
#import "DiscoverCell.h"

@interface DiscoverController ()<PopViewDelegate>
{
    PopView *popview;
    UIView *shadeView;
    NSUserDefaults *defaults;
    UIAlertView *_alertView;
    NSArray *titleArray;
    NSArray *labelArray;
}
@end

@implementation DiscoverController

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.tableView reloadData];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    //通知显示tabBar
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:kShowCusotomTabBar object:self]];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = NSLocalizedString(@"Discovery", nil);
    
    defaults = [NSUserDefaults standardUserDefaults];
    if ([[defaults valueForKey:muji_bind_number] length] == 0) {
        self.muji_number.text =NSLocalizedString(@"UnSetting", nil);
    }
    
    //
    _alertView = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"The_Call_Forwarding_was_get_info", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"Sure", nil) otherButtonTitles:nil, nil];
    _alertView.delegate = self;
    
    titleArray = [NSArray arrayWithObjects:NSLocalizedString(@"Configure", nil),NSLocalizedString(@"Vibrate", nil),NSLocalizedString(@"Version", nil),NSLocalizedString(@"My_device", nil), nil];
    labelArray = [NSArray arrayWithObjects:@[NSLocalizedString(@"Configure_E-mail_MuJi-Number", nil)],@[@"来电时APP振动",@"123156"],@[@"APP版本",@"设备版本"],@[NSLocalizedString(@"Setting", nil)], nil];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    if (section == 2 || section ==1) {
        return 2;
    }
    
    return 1;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DiscoverCell *cell = [tableView dequeueReusableCellWithIdentifier:@"discoveryCell" forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    cell.textlb.text = labelArray[indexPath.section][indexPath.row];
    cell.buttons.hidden = YES;
    if (indexPath.section == 0) {
        cell.buttons.hidden = NO;
        [cell.buttons setTitle:[defaults valueForKey:muji_bind_number] forState:UIControlStateNormal];
    }
    
    
    return cell;
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        if ([[defaults valueForKey:muji_bind_number] length]<=0) {
           [self addShadeAndAlertView];
        }
    }
    
    if (indexPath.section == 3) {
        
        UIStoryboard *board = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        UIViewController *controller = [board instantiateViewControllerWithIdentifier:@"devicesid"];
        
        [self.navigationController pushViewController:controller animated:YES];
        
        VCLog(@"4");
    }
}
//标头
-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return titleArray[section];
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

#pragma mark -- popview Delegate
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
            
        }
    }

    
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    VCLog(@"will disappear");
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:kKeyboardAndTabViewHide object:self]];
}

@end
