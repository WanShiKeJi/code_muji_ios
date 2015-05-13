//
//  AddContacterController.m
//  TXBoxNew
//
//  Created by Naron on 15/4/24.
//  Copyright (c) 2015年 playtime. All rights reserved.
//

#import "AddContacterController.h"
#import <AddressBookUI/AddressBookUI.h>

@interface AddContacterController ()<ABNewPersonViewControllerDelegate>
{
    ABNewPersonViewController *newPerson;
}
@end

@implementation AddContacterController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = NSLocalizedString(@"New_Person", nil);
    
    newPerson = [[ABNewPersonViewController alloc] init];
    newPerson.newPersonViewDelegate = self;
    UINavigationController *navigation = [[UINavigationController alloc] initWithRootViewController:newPerson];
    //[self.navigationController pushViewController:new animated:YES];
    
    [self presentViewController:navigation animated:YES completion:^{
        NSLog(@"new show");
    }];}

-(void)newPersonViewController:(ABNewPersonViewController *)newPersonView didCompleteWithNewPerson:(ABRecordRef)person
{
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
