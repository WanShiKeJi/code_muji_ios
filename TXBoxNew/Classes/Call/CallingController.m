//
//  CallingController.m
//  TXBoxNew
//
//  Created by Naron on 15/4/21.
//  Copyright (c) 2015年 playtime. All rights reserved.
//

#import "CallingController.h"
#import "TXCallAction.h"
#import <ImageIO/ImageIO.h>

@interface CallingController ()
{
    TXCallAction *callAct;
    int times;
    NSTimer *timer;
    NSUserDefaults *defaults;
    NSTimer *tState;

    CGImageSourceRef gif; // 保存gif动画
    NSDictionary *gifProperties; // 保存gif动画属性
    size_t index; // gif动画播放开始的帧序号
    size_t count; // gif动画的总帧数
    NSTimer *timertimer; // 播放gif动画所使用的timer
    
}
- (IBAction)packUpClick:(UIButton *)sender;
@property (weak, nonatomic) IBOutlet UIButton *packUp;
@property (weak, nonatomic) IBOutlet UIView *gifView;
@end

@implementation CallingController
@synthesize nameLabel,numberLabel,timeLength;



- (void)viewDidLoad {
    
    [super viewDidLoad];
    callAct = [[TXCallAction alloc] init];
    defaults = [NSUserDefaults standardUserDefaults];
    self.timeLength.text = NSLocalizedString(@"Calling", nil);
    
    times = 0;
    
    //加载gif
    [self initWithGifFrame:CGRectMake(0, 0, 0, 0) filePath:[[NSBundle mainBundle] pathForResource:@"board" ofType:@"gif"]];
    
    //获取连接状态，是否接通
    if (self.nameLabel.text.length ==0) {
        tState = [NSTimer scheduledTimerWithTimeInterval:1.f target:self selector:@selector(getConnectState) userInfo:nil repeats:YES];
        [tState fire];
    }
}

//获取连接(打电话)状态
-(void) getConnectState
{
    
    //返回为1，已接通
    if ([callAct callOutAction:1]) {
        
        [defaults setValue:@"1"  forKey:@"isOrNotConnect"];
        [tState invalidate];
        tState = nil;
        
        //开始计时
        
        timer = [NSTimer scheduledTimerWithTimeInterval:1.f target:self selector:@selector(changedCount) userInfo:nil repeats:YES];
        [timer fire];

        
    }else
    {
    
        [defaults setValue:@"0" forKey:@"isOrNotConnect"];
    }
}


//加载gif
- (void)initWithGifFrame:(CGRect)frame filePath:(NSString *)filePath
{
    
    NSDictionary *gifLoopCount = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:0] forKey:(NSString *)kCGImagePropertyGIFLoopCount];
    
    gifProperties = [NSDictionary dictionaryWithObject:gifLoopCount forKey:(NSString *)kCGImagePropertyGIFDictionary] ;
    
    gif = CGImageSourceCreateWithURL((CFURLRef)[NSURL fileURLWithPath:filePath], (CFDictionaryRef)gifProperties);
    
    count =CGImageSourceGetCount(gif);
    
    timertimer = [NSTimer scheduledTimerWithTimeInterval:0.05 target:self selector:@selector(playGif) userInfo:nil repeats:YES];
    [timertimer fire];
    
}
//开始动画
-(void)playGif
{
    index ++;
    index = index%count;
    CGImageRef ref = CGImageSourceCreateImageAtIndex(gif, index, (CFDictionaryRef)gifProperties);
    self.gifView.layer.contents = (__bridge id)ref;
    CFRelease(ref);
}
//stop定时器
-(void)stopTimer
{
    [timertimer invalidate];//停止计时器
    timertimer = nil;   //置为nil
    
    [tState invalidate];
    tState  = nil;
    
    [timer invalidate];
    timer  = nil;
    
}


-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.timeLength.text = @"";
    //创建定时器
    
    //我的号码
    NSString *myPhoneNumber = [NSString stringWithFormat:@"%@",@"my phone number"];
    
    //如果电话接通，开始计时
    if ([callAct callOutAction:0]) {
        
        [callAct callOutFromNumber:myPhoneNumber HisNumber:self.numberLabel.text];
        
    }
    
    
}

//结束通话
-(IBAction)cut:(UIButton *)sender;
{
    
    NSUserDefaults *accountDefaults = [NSUserDefaults standardUserDefaults];
    [accountDefaults setValue:self.timeLength.text forKey:@"timeLength"];
    
    self.timeLength.text = NSLocalizedString(@"Call_Over", nil);
    [UIView beginAnimations:@"" context:@""];
    [UIView setAnimationDuration:.9];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    self.view.alpha = 0;
    
    [UIView setAnimationRepeatCount:0];
    [UIView commitAnimations];

    //保存资料数据 callOut
    NSString *st = [NSString stringWithFormat:@"%@",[accountDefaults objectForKey:@"timeLength"]];
    if (st.length>0) {
        [callAct callEndByMeWithState:1 hisNumber:self.numberLabel.text hisName: self.nameLabel.text timeLength:st];
    }else
    {
        st = @"00:00";
        [callAct callEndByMeWithState:1 hisNumber:self.numberLabel.text hisName: self.nameLabel.text timeLength:st];
    }
    
    [self stopTimer];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.view removeFromSuperview];
        
        //刷新表格
        
    });
    
    
    
}

//计时，时长的改变
-(void) changedCount
{
    times ++;
    
    NSString *second;
    NSString *min;
    NSString *hours;
    
    //小于10秒
    //00:0s
    hours = @"";
    if (times <10) {
        min = [NSString stringWithFormat:@"00"];
    }
    
    if (10<=times && times<60) {

        min = [NSString stringWithFormat:@"0%d",times/60];
        
    }
    // 1min <= times < 1hours
    if (60<=times && times<3600) {

        if (times/60<10) {
            min = [NSString stringWithFormat:@"0%d",times/60];
        }else
        {
            min = [NSString stringWithFormat:@"%d",times/60];
        }
        
        
    }
    // 1hours <=times < 10 hours
    if (times>=3600 && times<36000) {
        hours = [NSString stringWithFormat:@"0%d:",times/3600];
        if ((times/60)%60<10) {
            min = [NSString stringWithFormat:@"0%d",(times/60)%60];
        }else
        {
            min = [NSString stringWithFormat:@"%d",(times/60)%60];
        }
        
        
        
    }
    
    // times >= 10 hours
    if (times >=36000) {
        hours = [NSString stringWithFormat:@"%d:",times/3600];
        if (times/60<10) {
            min = [NSString stringWithFormat:@"0%d",times/60];
        }else
        {
            min = [NSString stringWithFormat:@"%d",times/60];
        }
        
        
    }
    
    if (times%60 <10) {
        second = [NSString stringWithFormat:@"0%d",times%60];
    }else
    {
        second = [NSString stringWithFormat:@"%d",times%60];
    }

    self.timeLength.text = [NSString stringWithFormat:@"%@%@:%@",hours,min,second];
    VCLog(@"timeLength :%@",self.timeLength.text);
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self stopTimer];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [UIView beginAnimations:@"" context:@""];
    [UIView setAnimationDuration:.9];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    //self.view.alpha = 0;
    
    [UIView setAnimationRepeatCount:0];
    [UIView commitAnimations];
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)packUpClick:(UIButton *)sender {
    
    [UIView beginAnimations:@"" context:@""];
    [UIView setAnimationDuration:.9];
    [UIView setAnimationCurve:
     UIViewAnimationCurveEaseInOut];
    /*
    self.view.frame = CGRectMake(0, 0, DEVICE_WIDTH, 50);
    [self.nameLabel removeFromSuperview];
    [self.numberLabel removeFromSuperview];
    [self.gifView removeFromSuperview];
    [self.packUp removeFromSuperview];
    //self.timeLength.frame = CGRectMake(<#CGFloat x#>, <#CGFloat y#>, <#CGFloat width#>, <#CGFloat height#>)
    */
    [UIView setAnimationRepeatCount:0];
    [UIView commitAnimations];
    
    
    
    
}
@end
