//
//  DiscoveryController.m
//  TXBoxNew
//
//  Created by Naron on 15/5/29.
//  Copyright (c) 2015年 playtime. All rights reserved.
//

#import "DiscoveryController.h"
#import "NSString+helper.h"
#import "PopView.h"
#import <ImageIO/ImageIO.h>
#import "LoginController.h"
#import <CoreBluetooth/CoreBluetooth.h>
#import "TXSqliteOperate.h"

#define UUIDSTR_TEST_SERVICE @"FFE0"
static NSString *const kDataInCharaUUID = @"FF01";//kDataOutCharaUUID
static NSString *const kDataOutCharaUUID = @"FF01";

@interface DiscoveryController ()<PopViewDelegate,CBCentralManagerDelegate,CBPeripheralDelegate>
{
    NSUserDefaults *defaults;
  
    UIView *shadeView;  //遮罩层
    PopView *popview;   //提示框
    
    UIImageView *con_imgv;  //
    UIImageView *ble_imgv;  //蓝牙图片
    TXSqliteOperate *txsqlite;
    
}
//label
@property (weak, nonatomic) IBOutlet UILabel *phoneNumber;
@property (weak, nonatomic) IBOutlet UILabel *mujiNumber;
@property (weak, nonatomic) IBOutlet UILabel *connectNumber;
//
@property (weak, nonatomic) IBOutlet UIButton *phoneButton;
@property (weak, nonatomic) IBOutlet UIButton *mujiButton;
@property (weak, nonatomic) IBOutlet UIButton *connectButton;

//静态图片
@property (weak, nonatomic) IBOutlet UIView *BLEView;
@property (weak, nonatomic) IBOutlet UIView *connectView;

//gif图
@property (weak, nonatomic) IBOutlet UIView *BLEgifView;
@property (weak, nonatomic) IBOutlet UIView *connectGifView;

//button
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
- (IBAction)loginButtonClick:(UIButton *)sender;
@property (weak, nonatomic) IBOutlet UIButton *bindButton;
- (IBAction)bindButtonClick:(UIButton *)sender;
@property (weak, nonatomic) IBOutlet UIButton *configureButton;
- (IBAction)configureButtonClick:(UIButton *)sender;
//版本
@property (weak, nonatomic) IBOutlet UIButton *isAppVersion;
@property (weak, nonatomic) IBOutlet UIButton *isFirmwareVersion;


//连接外设
@property (strong,nonatomic) CBCentralManager *manager;
@property (strong,nonatomic) NSMutableArray *peripheralArray;
@property (strong,nonatomic) CBPeripheral *peripheral;
@property (strong,nonatomic) CBCharacteristic *readCharacteristic;
@property (strong,nonatomic) CBCharacteristic *writeCharacteristic;
@end

@implementation DiscoveryController

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //键盘活动  键盘出现时
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWasShow:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(disvViewDidShow:) name:KRefreshDisvView object:nil];
    
    //通知显示tabBar
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:kShowCusotomTabBar object:self]];
    
    [self initButtons];
    
    [self isOrNotUpdateVersion];
}

-(void)isOrNotUpdateVersion
{
    //APP版本,检测本地版本，与最新版本比较
    //dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        //获取服务器版本号
        //NSURL *url = [NSURL URLWithString:@"http://car0.autoimg.cn/upload/spec/9579/u_20120110174805627264.jpg"];
        
        NSString *str = [[NSString alloc] initWithFormat:@"1.2"];
        
        //获取当前程序版本号
        NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
        NSString *str2 = [infoDictionary objectForKey:@"CFBundleVersion"];
        
        // 回到主线程，显示提示框
        //dispatch_async(dispatch_get_main_queue(), ^{
            
            if ([str2 floatValue] != [str floatValue]) {
                
                UIAlertView *atView = [[UIAlertView alloc] initWithTitle:@"温馨提示" message:@"检测到有新版本，是否更新？" delegate:self cancelButtonTitle:@"不OK" otherButtonTitles:@"OK", nil];
                [atView show];
                
                // 显示更新
                self.isFirmwareVersion.hidden = NO;
            }else {
                self.isFirmwareVersion.hidden = YES;
            }
            
            
            
        //});
    //});

}
- (void)keyboardWasShow:(NSNotification*)aNotification{
    
    NSDictionary* info = [aNotification userInfo];
    /*
     NSNumber *duration = [info objectForKey:UIKeyboardAnimationDurationUserInfoKey];
     VCLog(@"duration:%@",duration);
     CGRect beginRect = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue];
     */
    
    CGRect endRect = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    //VCLog(@"·······%f",endRect.size.height);
    [UIView beginAnimations:@"" context:nil];
    popview.frame =  CGRectMake((DEVICE_WIDTH-PopViewWidth)/2, DEVICE_HEIGHT-PopViewHeight-endRect.size.height-10, PopViewWidth, PopViewHeight);
    [UIView setAnimationDuration:.25];
    [UIView commitAnimations];
    
}
-(void)disvViewDidShow:(NSNotification *)notifi
{
    [self initButtons];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    defaults = [NSUserDefaults standardUserDefaults];
    txsqlite = [[TXSqliteOperate alloc] init];
    
    con_imgv = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 42, 23)];
    ble_imgv = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 42, 23)];
    
    //(self.configureButton.frame.origin.x-self.loginButton.frame.origin.x+45)/2
    [self.bindButton setFrame:CGRectMake(50, self.loginButton.frame.origin.y, 45, 23)];
    
    
    
    self.phoneNumber.hidden = YES;
    self.mujiNumber.hidden = YES;
    self.connectNumber.hidden = YES;
    
    [self.isAppVersion setTitle:@"v1.0" forState:UIControlStateNormal];
    self.isAppVersion.enabled = YES;
    
    self.isFirmwareVersion.hidden = YES;
    
    self.loginButton.layer.cornerRadius = 13;
    self.configureButton.layer.cornerRadius = 13;
    self.bindButton.layer.cornerRadius = 13;
    
    
    UILabel *footv =[[UILabel alloc] initWithFrame:CGRectMake(15, 0, DEVICE_HEIGHT, 1)];
    footv.backgroundColor = [UIColor grayColor];
    footv.alpha = .3;
    self.tableView.tableFooterView = footv;
    
    //数组保存找到的设备
    self.peripheralArray = [[NSMutableArray alloc] init];
}

#pragma mark - Table view

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    if (section == 0) {
        return 1;
    }
    return 2;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            
            
        }
        if (indexPath.row == 1) {
            //设备固件版本
            if (self.isFirmwareVersion.hidden == NO) {
                VCLog(@"更新");
            }else{
                VCLog(@"已经是最新了");
            }
        }
    }
    
    VCLog(@"x");
}
#pragma mark -- 初始化btn
-(void)initButtons{
    
    BOOL loginState = [[defaults valueForKey:LOGIN_STATE] intValue];
    BOOL bindState = [[defaults valueForKey:BIND_STATE] intValue];
    BOOL configState = [[defaults valueForKey:CONFIG_STATE] intValue];
    
    if (loginState) {//已登录
        self.phoneNumber.hidden = NO;
        [self.loginButton setTitle:@"  退出  " forState:UIControlStateNormal];
        [self.loginButton setBackgroundColor:RGBACOLOR(252, 57, 59, 1)];
        self.phoneNumber.text = [defaults valueForKey:CurrentUser];
    }else{
        self.phoneNumber.hidden = YES;
        [self.loginButton setTitle:@"  登录  " forState:UIControlStateNormal];
        [self.loginButton setBackgroundColor:RGBACOLOR(25, 180, 8, 1)];
    }
    
    if (configState) {//已配置
        [self.configureButton setTitle:@"  修改  " forState:UIControlStateNormal];
        [self.configureButton setBackgroundColor:RGBACOLOR(252, 57, 59, 1)];
        self.mujiNumber.hidden = NO;
        self.mujiNumber.text = [defaults valueForKey:muji_bind_number];
        self.connectNumber.hidden = NO;
        //
        
        self.connectView.hidden = YES;
        self.connectGifView.hidden = NO;
        NSString *home;
        NSString *operation;
        if ([[defaults valueForKey:muji_bind_number] length] <=0) {
            home=@"";
            operation = @"";
        }else{
            home = [txsqlite searchAreaWithHisNumber:[[defaults valueForKey:muji_bind_number] substringToIndex:7]];
            operation = [[defaults valueForKey:muji_bind_number] isMobileNumberWhoOperation];
        }
        
        
        self.connectNumber.text = [NSString stringWithFormat:@"%@ %@",home,operation];//拇机
        
        //显示gif图片
        [self initAnimatedWithFileName:@"phone_connect" andType:@"gif" view:self.connectGifView];
    }else{
        //显示静态图片

        self.connectView.hidden = NO;
        self.connectGifView.hidden = YES;
        con_imgv.image = [UIImage imageNamed:@"flow_phone"];
        [self.connectView addSubview:con_imgv];
        [self.configureButton setTitle:@"  配置  " forState:UIControlStateNormal];
        [self.configureButton setBackgroundColor:RGBACOLOR(25, 180, 8, 1)];
        self.mujiNumber.hidden = YES;
        self.connectNumber.hidden = NO;
        self.connectNumber.text = @" ";
        
    }
    
    if (bindState) {//已绑定
        [self.bindButton setTitle:@"  解绑  " forState:UIControlStateNormal];
        [self.bindButton setBackgroundColor:RGBACOLOR(252, 57, 59, 1)];//ble_connect
        self.BLEView.hidden = YES;
        self.BLEgifView.hidden = NO;
        
        //显示gif图片
        [self initAnimatedWithFileName:@"ble_connect" andType:@"gif" view:self.BLEgifView];
        
    }else{
        //显示静态图片
        self.BLEView.hidden = NO;
        self.BLEgifView.hidden = YES;
        
        ble_imgv.image = [UIImage imageNamed:@"flow_ble"];
        [self.BLEView addSubview:ble_imgv];
        [self.bindButton setTitle:@"  绑定  " forState:UIControlStateNormal];
        [self.bindButton setBackgroundColor:RGBACOLOR(25, 180, 8, 1)];
        
    }
    
}
#pragma mark -- 加载gif图片
-(void)initAnimatedWithFileName :(NSString *)fileName andType:(NSString *)type view:(UIView *)vview
{
    //解码图片
    NSString *imagePath =[[NSBundle mainBundle] pathForResource:fileName ofType:type];
    CGImageSourceRef  cImageSource = CGImageSourceCreateWithURL((__bridge CFURLRef)[NSURL fileURLWithPath:imagePath], NULL);
    //读取动画的每一帧
    size_t imageCount = CGImageSourceGetCount(cImageSource);
    NSMutableArray *images = [[NSMutableArray alloc] initWithCapacity:imageCount];
    NSMutableArray *times = [[NSMutableArray alloc] initWithCapacity:imageCount];
    NSMutableArray *keyTimes = [[NSMutableArray alloc] initWithCapacity:imageCount];
    
    //显示时间
    float totalTime = 0;
    CGSize size;
    for (size_t i = 0; i < imageCount; i++) {
        CGImageRef cgimage= CGImageSourceCreateImageAtIndex(cImageSource, i, NULL);
        [images addObject:(__bridge id)cgimage];
        CGImageRelease(cgimage);
        
        NSDictionary *properties = (__bridge NSDictionary *)CGImageSourceCopyPropertiesAtIndex(cImageSource, i, NULL);
        NSDictionary *gifProperties = [properties valueForKey:(__bridge NSString *)kCGImagePropertyGIFDictionary];
        NSString *gifDelayTime = [gifProperties valueForKey:(__bridge NSString* )kCGImagePropertyGIFDelayTime];
        [times addObject:gifDelayTime];
        totalTime += [gifDelayTime floatValue];
        
        size.width = [[properties valueForKey:(NSString*)kCGImagePropertyPixelWidth] floatValue];
        size.height = [[properties valueForKey:(NSString*)kCGImagePropertyPixelHeight] floatValue];
    }
    
    float currentTime = 0;
    for (size_t i = 0; i < times.count; i++) {
        float keyTime = currentTime / totalTime;
        [keyTimes addObject:[NSNumber numberWithFloat:keyTime]];
        currentTime += [[times objectAtIndex:i] floatValue];
    }
    
    //执行CAKeyFrameAnimation动画
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"contents"];
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear]];
    [animation setValues:images];
    [animation setKeyTimes:keyTimes];
    animation.duration = totalTime;
    animation.repeatCount = HUGE_VALF;
    
    [vview.layer addAnimation:animation forKey:@"gifAnimation"];

}

#pragma mark -- show popView
-(void)addShadeAndAlertViewWithNumber:(NSString *)mujiNumber
{
    //透明层
    shadeView =[[UIView alloc] initWithFrame:self.view.window.bounds];
    shadeView.backgroundColor = [UIColor grayColor];//self.view.window.bounds
    shadeView.alpha = .4;
    [self.view.window addSubview:shadeView];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(shadeViewTap:)];
    tap.numberOfTapsRequired = 1;
    [shadeView addGestureRecognizer:tap];
    
    
    //pop
    popview = [[PopView alloc] initWithFrame:CGRectMake((DEVICE_WIDTH-PopViewWidth)/2, DEVICE_HEIGHT-PopViewHeight-220, PopViewWidth, PopViewHeight)];
    popview.delegate = self;
    
    if (mujiNumber.length>0) {
        [popview initWithTitle:@"修改拇机号码信息:" label:@"拇机号码" cancelButtonTitle:@"OK" otherButtonTitles:@"不OK"];
        popview.secondField.text = mujiNumber;
    }else{
        [popview initWithTitle:@"呼叫转移需要配置拇机号码信息:" label:@"拇机号码" cancelButtonTitle:@"OK" otherButtonTitles:@"不OK"];
    }
    
    [self.view.window addSubview:popview];
}

-(void)shadeViewTap:(UIGestureRecognizer *)recongnizer
{
    VCLog(@"-------tap");
    
    [shadeView removeFromSuperview];
    [popview removeFromSuperview];
}

#pragma mark-- popView delegate
-(void)resaultsButtonClick:(UIButton *)button  textField:(UITextField *)sfield;
{
    //获取输入的text
    NSString *number = [sfield.text trimOfString];
    //取消
    if (button.tag == 1) {
        
        [shadeView removeFromSuperview];
        [popview removeFromSuperview];
        
    }
    //sure按钮
    if (button.tag == 0) {
        if ( number.length<=0 || ![number isValidateMobile:number]) {
            //创建提醒对话框
            UIAlertView *malertView = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"Please_enter_the_correct_info", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"Sure", nil) otherButtonTitles:nil, nil];
            [malertView show];
            //malertView.delegate = self;
            //[malertView textFieldAtIndex:0];//获取输入框，在UIAlertViewStyle -> input模式
        }else
        {
            //本地保存数据
            [defaults setValue:number forKey:muji_bind_number];
            
            //上传到服务器
            /*
            ^(BOOL suc,NSError *error){
             
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
            [defaults setValue:@"1" forKey:CONFIG_STATE];
            //
            [self.configureButton setTitle:@"  修改  " forState:UIControlStateNormal];
            [self.configureButton setBackgroundColor:RGBACOLOR(252, 57, 59, 1)];
            
            VCLog(@"save-->number:%@",number);
            [shadeView removeFromSuperview];
            [popview removeFromSuperview];
            
        }
    }
    
    [self initButtons];
}


#pragma mark -- 配置 & 修改
- (IBAction)configureButtonClick:(UIButton *)sender {
    BOOL loginState = [[defaults valueForKey:LOGIN_STATE] intValue];
    
    if (loginState) {
        VCLog(@"pz");
        BOOL conState = [[defaults valueForKey:CONFIG_STATE] intValue];
        if (conState) {
            //已配置，修改
            [self addShadeAndAlertViewWithNumber:[defaults valueForKey:muji_bind_number]];
        }else{
            //配置
            [self addShadeAndAlertViewWithNumber:nil];
        }
        
    }else{
        //提示登录
        UIAlertView *configAlert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"想【配置】拇机号码？请先【登录】" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [configAlert show];
    }

    
}

#pragma mark -- 登录 & 退出
- (IBAction)loginButtonClick:(UIButton *)sender {
    
    BOOL loginstate = [[defaults valueForKey:LOGIN_STATE] intValue];
    if (loginstate) {
        [self loginOut];
        [defaults setValue:@"0" forKey:LOGIN_STATE];
        [defaults setValue:@"0" forKey:CONFIG_STATE];
        [self initButtons];
    }else
    {
        VCLog(@"11");
        //添加calling页面
        
        UIStoryboard *board = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        LoginController *loginview = [board instantiateViewControllerWithIdentifier:@"loginVCIdentity"];
        [self.navigationController pushViewController:loginview animated:YES];
         
    }
    
}

-(void)loginOut
{
    //[AVUser logOut];
}




#pragma mark -- 绑定 & 解绑
- (IBAction)bindButtonClick:(UIButton *)sender {
    
    BOOL bstate = [[defaults valueForKey:BIND_STATE] intValue];
    if (bstate) {
        [defaults setObject:@"0" forKey:BIND_STATE];
        
    }else{//没绑定
        //
        [self createBLECentralManager];
        [defaults setObject:@"1" forKey:BIND_STATE];
        

        
    }
    [self initButtons];
    
    
}


#pragma mark --创建central并扫描外设
//1.创建CBCentralManager
-(void)createBLECentralManager
{
    self.manager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    [self scanForPeripherals];
}

//2.本机蓝牙状态
- (void)centralManagerDidUpdateState:(CBCentralManager *)central;
{
    NSString *state = nil;
    
    switch ([central state])
    {
        case CBCentralManagerStateUnsupported:
            state = @"The platform/hardware doesn't support Bluetooth Low Energy.";
            break;
        case CBCentralManagerStateUnauthorized:
            state = @"The app is not authorized to use Bluetooth Low Energy.";
            break;
        case CBCentralManagerStatePoweredOff:
            state = @"Bluetooth is currently powered off.";
            break;
        case CBCentralManagerStatePoweredOn:
            state = @"work";//可用
            break;
        case CBCentralManagerStateUnknown:
        default:
            ;
    }
    
    VCLog(@"Central manager state: %@", state);
    
}


//3.扫描外设
-(void)scanForPeripherals
{
    [self.manager scanForPeripheralsWithServices:nil options:nil]; //Services 为nil表示扫描所有外设
}

//4.发现蓝牙设备，返回设备参数
-(void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    //若数组里没有，则添加
    if(![self.peripheralArray containsObject:peripheral.name])
        [self.peripheralArray addObject:peripheral.name];
    
    VCLog(@"peripheralArray:%@", self.peripheralArray);
    
    VCLog(@"设备名：%@ 广告数据：%@ 信号强度：%@ ",peripheral.name,advertisementData,RSSI);
    
    [self connectPeripheral];
}

// 5.1连接设备
-(void)connectPeripheral
{
    //假设连接第一个
    [self.manager connectPeripheral:[self.peripheralArray firstObject]  options:nil];
}
// 5.2连接成功
-(void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    VCLog(@"connect suc :%@",peripheral);
    //[self.connectTimer invalidate];//停止计时
    
    peripheral.delegate = self;
    [central stopScan];//停止扫描
    [peripheral discoverServices:nil];// nil表示返回所有服务
    //
    [self.peripheral discoverServices:@[[CBUUID UUIDWithString:UUIDSTR_TEST_SERVICE]]];
    [defaults setObject:@"1" forKey:BIND_STATE];
    [self initButtons];
}

//发现外设-服务，
-(void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    if (error) {
        VCLog(@"didDiscoverServices error:%@",error);
    }else{
        VCLog(@"已发现外设服务:%@",peripheral.services);
        
        for (CBService *service in peripheral.services) {
            NSLog(@"发现UUID=%@的服务;并开始检测这个服务的特征码...",service.UUID);
            
            if ([service.UUID isEqual:[CBUUID UUIDWithString:UUIDSTR_TEST_SERVICE]]) {
                
                [peripheral discoverCharacteristics:nil forService:service];
            } 
        }
        
        
    }

}

//如果一个特征被检测到
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error {
    
    if (error) {
        
        VCLog(@"%s,%@",__PRETTY_FUNCTION__,error);
        
    } else {
        if ([service.UUID isEqual:[CBUUID UUIDWithString:UUIDSTR_TEST_SERVICE]]) {
            
            VCLog(@"-------service charactristics is %@\n=========================",service.characteristics);
            
            for (CBCharacteristic *characteristic in service.characteristics) {
                
                VCLog(@"发现特征的服务:%@ (%@)",service.UUID.data,service.UUID);
                
                if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:kDataInCharaUUID]]) {
                    //主机端通过该 Characteristic 给从机端(BLE 透传模块)发送数据
                    
                    _writeCharacteristic = characteristic;
                    
                    [self.peripheral setNotifyValue:YES
                                  forCharacteristic:_writeCharacteristic];//设定写特征
                    
                    //服务给设备发送数据 
                    //[self sendDataInCharaUUID];
                    
                }else if([characteristic.UUID isEqual:[CBUUID UUIDWithString:kDataOutCharaUUID]]){ 
                    
                    
                }//else if([characteristic.UUID isEqual:[CBUUID UUIDWithString:kBaudRateCharaUUID]]){
                    
                //}
            } 
        } 
    } 
}

//若特征值更新，此方法收到通知
-(void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    VCLog(@"characteristic:%@",characteristic);
}

//主机发送数据给从机者
- (void)sendDataInCharaUUID {
    
    NSString* sendDataInString = @"~200141410000FDB3";
    unsigned char dataTailString = 0x0D;
    NSData* data = [NSData dataWithBytes:&dataTailString length:1.0];
    NSString* string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSString * tatalString = [sendDataInString stringByAppendingString:string];
    NSData* sendDataIn = [tatalString dataUsingEncoding:NSUTF8StringEncoding];
    
    NSLog(@"sendData is %@ characteristic is %@",sendDataIn,_writeCharacteristic);
    
    [_peripheral writeValue:sendDataIn forCharacteristic:_writeCharacteristic type:CBCharacteristicWriteWithoutResponse];
}

//断开连接
-(void)disConnect
{
    if (self.peripheral != nil) {
        VCLog(@"is disConnect");
        [self.manager cancelPeripheralConnection:self.peripheral];
    }
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
