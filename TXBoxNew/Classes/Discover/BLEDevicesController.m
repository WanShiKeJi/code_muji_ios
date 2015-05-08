//
//  BLEDevicesController.m
//  TXBoxNew
//
//  Created by Naron on 15/4/28.
//  Copyright (c) 2015年 playtime. All rights reserved.
//

#import "BLEDevicesController.h"
#import "BLEDeviceCell.h"
#import <CoreBluetooth/CoreBluetooth.h>

#define UUID_MY @"68753A44-4D6F-1226-9C60-0050E4C00067"
#define UUIDSTR_TEST_SERVICE @"FFE0"
#define UUIDSTR_TEST_READC @"READ"
#define UUIDSTR_TEST_WRITEC @"WRITE"

@interface BLEDevicesController ()<CBCentralManagerDelegate,CBPeripheralDelegate>

@property (strong,nonatomic) CBCentralManager *manager;
@property (strong,nonatomic) NSMutableArray *peripheralArray;
@property (strong,nonatomic) CBPeripheral *peripheral;
@property (strong,nonatomic) CBCharacteristic *readCharacteristic;
@property (strong,nonatomic) CBCharacteristic *writeCharacteristic;

@property (strong,nonatomic) NSTimer *connectTimer;
@property (strong,nonatomic) UIActivityIndicatorView *activeView;
@property (assign,nonatomic) int times;
@property (strong,nonatomic) NSString *strings;
@end

@implementation BLEDevicesController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // BLE
    [self createBLECentralManager];
    
    self.activeView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    self.activeView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
    
    //开一个定时器监控扫描时间
    self.connectTimer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(connectTimeout:) userInfo:nil  repeats:YES];
    self.times = 30;
    
    
    //数组保存找到的设备
    self.peripheralArray = [[NSMutableArray alloc] init];
    //[self.peripheralArray addObject:@"1"];
    //[self.peripheralArray addObject:@"2"];
    
    self.strings = @"";
}

#pragma mark --创建central并扫描外设
//1.创建CBCentralManager
-(void)createBLECentralManager
{
    self.manager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
}

//2.发现外设成功时回调，说明self.manager创建成功
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
    //NSDictionary *dict = [[NSDictionary alloc] init];
    
    [self.manager scanForPeripheralsWithServices:nil options:nil];//Services为nil表示扫描所有外设
}
//4.发现蓝牙设备，返回设备参数
-(void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    //若数组里没有，则添加
    if(![self.peripheralArray containsObject:peripheral.name])
        [self.peripheralArray addObject:peripheral.name];
    
    VCLog(@"peripheralArray:%@", self.peripheralArray);
    
    VCLog(@"设备名：%@ 广告数据：%@ 信号强度：%@ 设备UUID：%@",peripheral.name,advertisementData,RSSI,peripheral.UUID);
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
    VCLog(@"连接成功 :%@",peripheral);
    //[self.connectTimer invalidate];//停止计时
    
    peripheral.delegate = self;
    [central stopScan];//停止扫描
    [peripheral discoverServices:nil];// nil表示返回所有服务
    //
    [self.peripheral discoverServices:@[[CBUUID UUIDWithString:UUIDSTR_TEST_SERVICE]]];
}

#pragma mark --扫描外设中的服务和特征(discover)
// 6.peripheral的返回
-(void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    if (error) {
        VCLog(@"Discovered services for %@ with error: %@", peripheral.name, [error localizedDescription]);
        return;
    }
    
    for (CBService *service in peripheral.services)
    {
        NSLog(@"Service found with UUID: %@", service.UUID);
        if ([service.UUID isEqual:[CBUUID UUIDWithString:UUIDSTR_TEST_SERVICE]])
        {
            [peripheral discoverCharacteristics:nil forService:service];//返回对应的characteristics
        }
    }
    
    
}
//找到FEE0服务的所有 特征
-(void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    if (error)
    {
        NSLog(@"Discovered characteristics for %@ with error: %@", service.UUID, [error localizedDescription]);
        return;
    }
    //这里获取了写特征
    for (CBCharacteristic * characteristic in service.characteristics)
    {
        VCLog(@"characteristic:%@",characteristic);
        if( [characteristic.UUID isEqual:[CBUUID UUIDWithString:UUIDSTR_TEST_WRITEC]])
        {
            self.peripheral = peripheral;
            self.readCharacteristic = characteristic;
            VCLog(@"write_casc:%@",self.writeCharacteristic);
        }
    }
    
    //这里获取了读特征
    for (CBCharacteristic * characteristic in service.characteristics)
    {
        
        if( [characteristic.UUID isEqual:[CBUUID UUIDWithString:UUIDSTR_TEST_READC]])
        {
            self.peripheral = peripheral;
            self.writeCharacteristic = characteristic;
            [self.peripheral setNotifyValue:YES forCharacteristic:self.readCharacteristic];
            VCLog(@"read_casc:%@",self.readCharacteristic);
        }
    }
    
}

#pragma mark -- 与外设数据交互
//写数据
-(void)writeChar:(NSString *)string
{
    NSData *data = [[NSData alloc] init];
    data =  [string dataUsingEncoding:CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000)];
    
    [self.peripheral writeValue:data forCharacteristic:self.writeCharacteristic type:CBCharacteristicWriteWithResponse];
}

//监听设备
-(void)startSubscribe
{
    [self.peripheral setNotifyValue:YES forCharacteristic:self.readCharacteristic];
}

//读特征方法回调
-(void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if (error) {
        NSLog(@"Error updating value for characteristic %@ error: %@", characteristic.UUID, [error localizedDescription]);
        return;
    }
    //有数据
    [self readChar:characteristic.value];
}

//有数据
-(void)readChar:(NSData *)data
{
    VCLog(@"data:%@",data);
}

//断开连接
-(void)disConnect
{
    if (self.peripheral != nil) {
        VCLog(@"is disConnect");
        [self.manager cancelPeripheralConnection:self.peripheral];
    }
}

#pragma mark - Table view data source

//return 分区
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 2;
}

//return 分区rows
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    if (section == 0) {
        return 1;
    }
    return self.peripheralArray.count;
}

//返回cell
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    BLEDeviceCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BLEDevice" forIndexPath:indexPath];
    cell.selectionStyle =UITableViewCellSelectionStyleNone;
    if (indexPath.section == 0) {
        cell.nameLabel.text = @"查找设备";
        cell.isConnection.text = self.strings;
        cell.isConnection.hidden = YES;
        cell.accessoryView = self.activeView;
    }else
    {
        cell.nameLabel.text = [self.peripheralArray objectAtIndex:indexPath.row];
        cell.isConnection.text = @"未连接";
    }
    
    return cell;
}

//选中某一行
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        //活动指示器
        [self.activeView startAnimating];
        //扫描外设
        [self scanForPeripherals];
        //打开定时器
        [self.connectTimer fire];
        //self.strings = @"正在查找";
        [tableView reloadData];
        
        VCLog(@"000");
        
    }else
    {
        //连接设备
        [self.manager connectPeripheral:[self.peripheralArray objectAtIndex:indexPath.row] options:nil];
        
        
    }
}

//返回表头
-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return @"";
    }
    return @"我的设备";
}

//定时器
-(void)connectTimeout:(NSTimer *)timer
{
    self.times--;
    if (self.times<=0) {
        [self.manager stopScan];//停止扫描
        [self.activeView stopAnimating];
        self.strings = @"";
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
