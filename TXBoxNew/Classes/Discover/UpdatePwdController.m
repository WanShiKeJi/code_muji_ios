//
//  UpdatePwdController.m
//  TXBoxNew
//
//  Created by Naron on 15/6/2.
//  Copyright (c) 2015年 playtime. All rights reserved.
//

#import "UpdatePwdController.h"

@interface UpdatePwdController ()<UITextFieldDelegate>
{
    int secondsCountDowns;
    NSTimer *countDownTimer;
}
@property (weak, nonatomic) IBOutlet UITextField *updNumberField;
@property (weak, nonatomic) IBOutlet UITextField *updPwdField;
@property (weak, nonatomic) IBOutlet UITextField *updSmsCodeField;
@property (weak, nonatomic) IBOutlet UITextField *updpwdAgainField;

@property (weak, nonatomic) IBOutlet UIButton *updSmsCodeBtn;
- (IBAction)updSmsCodeBtnClick:(UIButton *)sender;

@property (weak, nonatomic) IBOutlet UIButton *updtePwdBtn;
- (IBAction)updatePwdBtnClick:(UIButton *)sender;
@end

@implementation UpdatePwdController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.updtePwdBtn.layer.cornerRadius = 3.f;
    UISwipeGestureRecognizer *swipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(updateViewSwipeActions:)];
    swipe.direction = UISwipeGestureRecognizerDirectionDown;
    
    self.updNumberField.delegate = self;
    self.updPwdField.delegate = self;
    self.updSmsCodeField.delegate = self;
    self.updpwdAgainField.delegate =self;
    
    [self.updNumberField addGestureRecognizer:swipe];
    [self.updPwdField addGestureRecognizer:swipe];
    [self.updSmsCodeField addGestureRecognizer:swipe];
    [self.updpwdAgainField addGestureRecognizer:swipe];
    
    
    [self.updtePwdBtn setBackgroundColor:RGBACOLOR(100, 211, 100, 1)];
    [self.updtePwdBtn setEnabled:NO];
    self.updtePwdBtn.alpha =.5;
}


-(void)updateViewSwipeActions:(UISwipeGestureRecognizer *)recognizer
{
    [self closeKeyBoard];
}
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self closeKeyBoard];
}

-(void)closeKeyBoard{
    [self.updNumberField resignFirstResponder];
    [self.updPwdField resignFirstResponder];
    [self.updSmsCodeField resignFirstResponder];
    [self.updpwdAgainField resignFirstResponder];

}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    
    if (self.updNumberField.text.length>0 && self.updPwdField.text.length >0 && self.updSmsCodeField.text.length >0 && self.updpwdAgainField.text.length >0 ) {
        [self.updtePwdBtn setEnabled:YES];
        self.updtePwdBtn.alpha = 1.f;
    }else{
        [self.updtePwdBtn setEnabled:NO];
        self.updtePwdBtn.alpha = 0.5f;
    }
    
    return YES;
}
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self closeKeyBoard];
    //
    //[self loginUserAccount];
    return YES;
}

- (IBAction)updSmsCodeBtnClick:(UIButton *)sender{
    
    //请求手机验证码
    [AVUser requestMobilePhoneVerify:self.updNumberField.text withBlock:^(BOOL suc,NSError *error){
        if (suc) {
            VCLog(@"req smscode suc");
            
        }else{
            VCLog(@"req smscode error-code:%ld errorInfo:%@",(long)error.code,error.localizedDescription);
        }
    }];

    
    secondsCountDowns = 60;//60秒倒计时
    countDownTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timeFireMethod) userInfo:nil repeats:YES];
    
    [self.updSmsCodeBtn setEnabled:NO];
}

-(void)timeFireMethod{
    
    secondsCountDowns--;
    
    [self.updSmsCodeBtn setTitle:[NSString stringWithFormat:@"重新获取%d",secondsCountDowns] forState:UIControlStateNormal];
    [self.updSmsCodeBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    if(secondsCountDowns==0){
        [countDownTimer invalidate];
        [self.updSmsCodeBtn setTitle:@"重新获取" forState:UIControlStateNormal];
        [self.updSmsCodeBtn setTitleColor:RGBACOLOR(0, 120, 230, 1) forState:UIControlStateNormal];
        [self.updSmsCodeBtn setEnabled:YES];
    }
}


- (IBAction)updatePwdBtnClick:(UIButton *)sender{
    
    //验证手机验证码
    [AVUser verifyMobilePhone:self.updSmsCodeField.text withBlock:^(BOOL suc,NSError *error){
        if (suc) {
            VCLog(@"验证smscode suc");
            
            //重置密码
            [AVUser resetPasswordWithSmsCode:self.updSmsCodeField.text newPassword:self.updpwdAgainField.text block:^(BOOL suc,NSError *error){
                if (error) {
                    VCLog(@"重置pwd error-code:%ld errorInfo:%@",(long)error.code,error.localizedDescription);
                }else{
                    VCLog(@"重置pwd suc");
                }
                
                
            }];
            
            
        }else{
            VCLog(@"验证smscode error-code:%ld errorInfo:%@",(long)error.code,error.localizedDescription);
        }
    }];
    
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
