//
//  BlueTableViewController.m
//  MOWOX
//
//  Created by Mac on 2017/10/30.
//  Copyright © 2017年 yusz. All rights reserved.
//

#import "BlueTableViewController.h"
#import <SVProgressHUD/SVProgressHUD.h>
#import "YAlertViewController.h"
#import "AppDelegate.h"
#import "MBProgressHUD.h"
#import "BluetoothDataManage.h"


#define ScreenHeight  [[UIScreen mainScreen] bounds].size.height

#define channelOnPeropheralView @"peripheralView"


@interface BlueTableViewController ()

///@brife 帧数据控制单例
@property (strong,nonatomic) BluetoothDataManage *bluetoothDataManage;
@property (strong, nonatomic) AppDelegate *appDelegate;

@property (nonatomic, strong) NSMutableArray * peripherals;
@property (nonatomic, strong) NSMutableArray * localName;
@property (nonatomic, strong) BabyBluetooth * baby;
@property (nonatomic, strong) NSMutableArray * connectedPeripherals;
@property (nonatomic, strong) UILabel *localDeviceName;

@end

@implementation BlueTableViewController
/**
 初始化
 */
- (void)viewDidLoad {
    [super viewDidLoad];
    self.peripherals = [[NSMutableArray alloc] init];
    self.localName = [[NSMutableArray alloc] init];
    self.connectedPeripherals = [[NSMutableArray alloc] init];
    self.baby = [BabyBluetooth shareBabyBluetooth];
    [self babyDelegate];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(disconnectBluetooth) name:@"disconnectBluetooth1" object:nil];
    _appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    self.bluetoothDataManage = [BluetoothDataManage shareInstance];

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    NSLog(@"%@", self.baby.findConnectedPeripherals);
    [self startScanBlue];
    [self.connectedPeripherals removeAllObjects];
    [self.connectedPeripherals addObjectsFromArray:[self.baby findConnectedPeripherals]];
    [self.peripherals removeAllObjects];
    [self.tableView reloadData];
}

-(void)viewDidAppear:(BOOL)animated{
    NSLog(@"viewDidAppear");
    //停止之前的连接
    [self.tableView reloadData];
}

-(void)viewWillDisappear:(BOOL)animated{
    NSLog(@"viewWillDisappear");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma mark - 蓝牙配置和操作

-(void)babyDelegate{
    
    __weak typeof(self) weakSelf = self;
    //设备状态改变的block
    [self.baby setBlockOnCentralManagerDidUpdateState:^(CBCentralManager *central) {
        if (central.state == CBManagerStatePoweredOn) {
            // [SVProgressHUD showInfoWithStatus:@"设备打开成功，开始扫描设备"];
        }
    }];
    
    //设置扫描到设备的委托
    //centeral 手机 peripheral外设
    [self.baby setBlockOnDiscoverToPeripherals:^(CBCentralManager *central, CBPeripheral *peripheral, NSDictionary *advertisementData, NSNumber *RSSI) {
        //NSLog(@"搜索到了设备:%@",peripheral.name);
        NSString *localName = [advertisementData objectForKey:CBAdvertisementDataLocalNameKey];
        NSLog(@"搜索到了设备%@",localName);
        NSString *currentMac = [[NSString alloc] init];
        if (localName.length >12) {
            //截取mac地址
            currentMac = [localName substringFromIndex:localName.length-12];
        }
        
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setObject:localName forKey:@"localName"];
        [userDefaults setObject:currentMac forKey:@"currentMac"];
        [userDefaults synchronize];
        
        [weakSelf insertTableView:peripheral advertisementData:advertisementData];
        NSString *autoName = [[NSUserDefaults standardUserDefaults] stringForKey:@"autoConnect"];
        if (autoName)
        {
            if ([autoName isEqualToString:peripheral.name])
            {
                [weakSelf.baby cancelScan];
                [weakSelf.baby cancelAllPeripheralsConnection];
                //    UIButton * senderBtn = sender;
                //    CBPeripheral *currPeripheral = self.peripherals[senderBtn.tag];
                //[SVProgressHUD showInfoWithStatus:@"开始连接设备"];
                
                weakSelf.baby.having(peripheral).and.channel(channelOnPeropheralView).then.connectToPeripherals().discoverServices().discoverCharacteristics().readValueForCharacteristic().discoverDescriptorsForCharacteristic().readValueForDescriptors().begin();
            }
        }
    }];
    //
    //设置设备连接成功的委托,同一个baby对象，使用不同的channel切换委托回调
    [self.baby setBlockOnConnectedAtChannel:channelOnPeropheralView block:^(CBCentralManager *central, CBPeripheral *peripheral) {
        [SVProgressHUD showSuccessWithStatus:LocalString(@"Device Connection Successful")];
        /*MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:weakSelf.navigationController.view  animated:YES];
        
        // Set the text mode to show only text.
        hud.mode = MBProgressHUDModeText;
        hud.square = YES;
        
        hud.label.text = NSLocalizedString(@"consucc", nil);
        // Move to bottm center.
        hud.offset = CGPointMake(0.f, MBProgressMaxOffset);
        
        [hud hideAnimated:YES afterDelay:2.f];*/
        [NSObject showHudTipStr2:NSLocalizedString(@"consucc", nil)];
        
        
        weakSelf.appDelegate.currentPeripheral = peripheral;
        
        [weakSelf.connectedPeripherals removeAllObjects];
        [weakSelf.connectedPeripherals addObjectsFromArray:[weakSelf.baby findConnectedPeripherals]];
        [weakSelf.peripherals removeAllObjects];
        [weakSelf.tableView reloadData];
        
    }];

    //设置设备连接失败的委托
    [self.baby setBlockOnFailToConnectAtChannel:channelOnPeropheralView block:^(CBCentralManager *central, CBPeripheral *peripheral, NSError *error) {
        NSLog(@"设备：%@--连接失败",peripheral.name);
        [SVProgressHUD showInfoWithStatus:[NSString stringWithFormat:@"Device：%@ Connection failed",peripheral.name]];
        
        /*MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:weakSelf.navigationController.view  animated:YES];
        
        // Set the text mode to show only text.
        hud.mode = MBProgressHUDModeText;
        hud.square = YES;
        
        hud.label.text = NSLocalizedString(@"confail", nil);
        // Move to bottm center.
        hud.offset = CGPointMake(0.f, MBProgressMaxOffset);
        
        [hud hideAnimated:YES afterDelay:2.f];
        */
        
        [NSObject showHudTipStr2:NSLocalizedString(@"confail", nil)];
        //[[NSNotificationCenter defaultCenter] postNotificationName:@"refreshItem" object:nil userInfo:nil];
        
    }];
    
    [self.baby setBlockOnDisconnect:^(CBCentralManager *central, CBPeripheral *peripheral, NSError *error) {
        [NSObject showHudTipStr2:NSLocalizedString(@"disconnect", nil)];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"disconnectBluetooth" object:nil];
        
        weakSelf.appDelegate.currentPeripheral = nil;
        
        [weakSelf.connectedPeripherals removeAllObjects];
        [weakSelf.peripherals removeAllObjects];
        [weakSelf.tableView reloadData];
        [weakSelf startScanBlue];
    }];
    //设置设备断开连接的委托
    [self.baby setBlockOnDisconnectAtChannel:channelOnPeropheralView block:^(CBCentralManager *central, CBPeripheral *peripheral, NSError *error) {
        NSLog(@"设备：%@断开连接",peripheral.name);
        //[SVProgressHUD showInfoWithStatus:[NSString stringWithFormat:@"设备断开连接"]];
        
        /*MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:weakSelf.navigationController.view  animated:YES];
        hud.mode = MBProgressHUDModeText;
        hud.square = YES;
        hud.label.text = NSLocalizedString(@"disconnect", nil);
        hud.offset = CGPointMake(0.f, MBProgressMaxOffset);
        [hud hideAnimated:YES afterDelay:2.f];*/
        
        [NSObject showHudTipStr2:NSLocalizedString(@"disconnect", nil)];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"disconnectBluetooth" object:nil];
        
        weakSelf.appDelegate.currentPeripheral = nil;
        
        [weakSelf.connectedPeripherals removeAllObjects];
        [weakSelf.peripherals removeAllObjects];
        [weakSelf.tableView reloadData];
        [weakSelf startScanBlue];
        //[[NSNotificationCenter defaultCenter] postNotificationName:@"refreshItem" object:nil userInfo:nil];
    }];
    
    //设置发现设备的过滤器
    [self.baby setFilterOnDiscoverPeripherals:^BOOL(NSString *peripheralName, NSDictionary *advertisementData, NSNumber *RSSI) {
        
        //最常用的场景是查找某一个前缀开头的设备
        
        if (peripheralName == NULL) {
            return NO;
        }
        if ([peripheralName hasPrefix:@"Robot"]) {
            return YES;
        }else{
            return NO;
        }
        
    }];
    
    [self.baby setBlockOnCancelAllPeripheralsConnectionBlock:^(CBCentralManager *centralManager) {
        NSLog(@"setBlockOnCancelAllPeripheralsConnectionBlock");
    }];
    
    [self.baby setBlockOnCancelScanBlock:^(CBCentralManager *centralManager) {
        NSLog(@"setBlockOnCancelScanBlock");
    }];
    
    //设置发现设service的Characteristics的委托
    //读取外设的特征
    [self.baby setBlockOnDiscoverCharacteristicsAtChannel:channelOnPeropheralView block:^(CBPeripheral *peripheral, CBService *service, NSError *error) {
        NSLog(@"===service name:%@",service);
        NSLog(@"uuid: %@", service.UUID.UUIDString);
        if ([service.UUID.UUIDString isEqualToString:@"49535343-FE7D-4AE5-8FA9-9FAFD205E455"])
        {
            
            NSArray *allCharacters = service.characteristics;
            for (CBCharacteristic * tempChara in allCharacters)
            {
                NSLog(@"%@", tempChara.UUID.UUIDString);
                if ([tempChara.UUID.UUIDString isEqualToString:@"49535343-1E4D-4BD9-BA61-23C647249616"])
                {

                    AppDelegate *appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
                    appDelegate.currentCharacteristic = tempChara;
                    //订阅信息
                    [appDelegate.currentPeripheral setNotifyValue:YES forCharacteristic:appDelegate.currentCharacteristic];
                    //接受消息
                    [self.baby notify:peripheral
                           characteristic:tempChara
                                    block:^(CBPeripheral *peripheral, CBCharacteristic *characteristics, NSError *error) {
                                        //NSLog(@"notify block");
                                        NSLog(@"new value %@",characteristics.value);
                                        //接受消息
                                        NSLog(@"%@", weakSelf);
                                        [self receiveBlue:characteristics.value];
                                    }];
                    //[weakSelf dismissViewControllerAnimated:YES completion:nil];
                    [weakSelf.navigationController popViewControllerAnimated:YES];
                    
                }
                else if ([tempChara.UUID.UUIDString isEqualToString:@"49535343-8841-43F4-A8D4-ECBE34729BB3"] || [tempChara.UUID.UUIDString isEqualToString:@"49535343-4C8A-39B3-2F49-511CFF073B7E"]) {
                    NSLog(@"其他特征值");
                }
            }
        }
    }];
    //设置读取characteristics的委托 
    //重置读数据block
    [self.baby setBlockOnReadValueForCharacteristicAtChannel:channelOnPeropheralView block:^(CBPeripheral *peripheral, CBCharacteristic *characteristics, NSError *error) {
        NSLog(@"characteristic name:%@ value is:%@",characteristics.UUID,characteristics.value);
    }];
    
    //示例:
    //扫描选项->CBCentralManagerScanOptionAllowDuplicatesKey:忽略同一个Peripheral端的多个发现事件被聚合成一个发现事件
    NSDictionary *scanForPeripheralsWithOptions = @{CBCentralManagerScanOptionAllowDuplicatesKey:@YES};
    //连接设备->
    [self.baby setBabyOptionsWithScanForPeripheralsWithOptions:scanForPeripheralsWithOptions connectPeripheralWithOptions:nil scanForPeripheralsWithServices:nil discoverWithServices:nil discoverWithCharacteristics:nil];
    NSDictionary *connectOptions = @{CBConnectPeripheralOptionNotifyOnConnectionKey:@YES,
                                     CBConnectPeripheralOptionNotifyOnDisconnectionKey:@YES,
                                     CBConnectPeripheralOptionNotifyOnNotificationKey:@YES};
    
    [self.baby setBabyOptionsAtChannel:channelOnPeropheralView scanForPeripheralsWithOptions:scanForPeripheralsWithOptions connectPeripheralWithOptions:connectOptions scanForPeripheralsWithServices:nil discoverWithServices:nil discoverWithCharacteristics:nil];


}


//插入读取的值
-(void)receiveBlue: (NSData *)data{
    //把读到的数据复制一份
    NSMutableArray *dataArray = [NSMutableArray new];
    NSData *recvBuffer = [NSData dataWithData:data];
    NSUInteger recvLen = [recvBuffer length];
    UInt8 *recv = (UInt8 *)[recvBuffer bytes];
    //把接收到的数据存放在recvData数组中
    NSUInteger j = 0;
    while (j < recvLen) {
        [dataArray addObject:[NSNumber numberWithUnsignedChar:recv[j]]];
        j++;
    }
    [self.bluetoothDataManage handleData:dataArray];
    NSLog(@"接收到的数据%@",dataArray);
}

//插入table数据
-(void)insertTableView:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData{
   
    NSString *localName = [advertisementData objectForKey:CBAdvertisementDataLocalNameKey];
    NSLog(@"搜索到了设备%@",localName);
    
    if(![self.peripherals containsObject:peripheral] && ![[self.baby findConnectedPeripherals] containsObject:peripheral] &&peripheral.name != NULL ) {
        NSMutableArray *indexPaths = [[NSMutableArray alloc] init];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.peripherals.count inSection:1];
        [indexPaths addObject:indexPath];
        
        [self.peripherals addObject:peripheral];
        [self.localName addObject:localName];
        [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0)
    {
        return 1;
    }
    else
    {
        return self.peripherals.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *localDeviceName = [userDefaults objectForKey:@"localName"];
    NSString *resetlocalName = [userDefaults objectForKey:@"resetlocalName"];
    NSString *currentMac = [userDefaults objectForKey:@"currentMac"];
    NSString *deviceMac = [userDefaults objectForKey:@"deviceMac"];
    NSLog(@"修改的名称%@",resetlocalName);
    if (indexPath.section == 0)
    {
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
#if MOWOXROBOT
        cell.backgroundColor = [UIColor darkGrayColor];
#endif
        if (self.connectedPeripherals.count > 0)
        {
            //CBPeripheral *peripheral = [self.connectedPeripherals objectAtIndex:indexPath.row];
            //cell.backgroundColor=[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0];
            UILabel *localName = (UILabel *)[cell viewWithTag:1000];
            UIButton * connectBtn = (UIButton *)[cell viewWithTag:1001];
            connectBtn.tag = indexPath.row;
            [connectBtn setImage:[UIImage imageNamed:@"tableCheck"] forState:UIControlStateNormal];
            
            if ([currentMac isEqualToString:deviceMac])
            {
                
                localName.text = resetlocalName;
            }
            else
            {
                localName.text = [NSString stringWithFormat:@"%@",localDeviceName];
            }
            [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
        }else{
            
                //cell.backgroundColor=[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0];
                UILabel *localName = (UILabel *)[cell viewWithTag:1000];
                UIButton * connectBtn = (UIButton *)[cell viewWithTag:1001];
                connectBtn.tag = indexPath.row;
                [connectBtn setImage:[UIImage imageNamed:@"touming"] forState:UIControlStateNormal];
                localName.text = NSLocalizedString(@"nodevice", nil);
            
                }
        //找到cell并修改detaisTex
        return cell;
        
    }
    else
    {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
        
        
        //CBPeripheral *peripheral = [self.peripherals objectAtIndex:indexPath.row];
        //cell.backgroundColor=[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0];
#if MOWOXROBOT
        cell.backgroundColor = [UIColor darkGrayColor];
#endif
        _localDeviceName = (UILabel *)[cell viewWithTag:1000];
        UIButton * connectBtn = (UIButton *)[cell viewWithTag:1001];
        [connectBtn setTintColor:[UIColor redColor]];
        connectBtn.tag = indexPath.row;
        //[connectBtn setImage:[UIImage imageNamed:@"blueLed"] forState:UIControlStateNormal];
        
        //[connectBtn.layer setCornerRadius:5];
        //connectBtn.layer.masksToBounds = YES;
        //[connectBtn.layer setBorderColor:[UIColor blackColor].CGColor];
        //[connectBtn.layer setBorderWidth:2.0];
        //peripheral的显示名称,优先用kCBAdvDataLocalName的定义，若没有再使用peripheral name
        //找到cell并修改detaisTex
        
        if ([currentMac isEqualToString:deviceMac])
        {
            _localDeviceName.text = resetlocalName;

        }
        else
        {
            _localDeviceName.text = [NSString stringWithFormat:@"%@",localDeviceName];
        }
        
        UILongPressGestureRecognizer *longPressGesture =[[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(deviceCellLongPress:)];

        longPressGesture.minimumPressDuration=1.f;//设置长按 时间
        [self.tableView addGestureRecognizer:longPressGesture];
        
        return cell;
        
    }
    
}

- (void)deviceCellLongPress:(UILongPressGestureRecognizer *)longRecognizer{
    if (longRecognizer.state==UIGestureRecognizerStateBegan) {
        //成为第一响应者，需重写该方法
        [self becomeFirstResponder];
        
        //获取此时长按的Cell位置
        CGPoint location = [longRecognizer locationInView:self.tableView];
        NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:location];
        NSString *localName = self.localName[indexPath.row];
        //截取mac地址
        NSString *deviceMac = [localName substringFromIndex:localName.length-12];
        
        YTFAlertController *alert = [[YTFAlertController alloc] init];
        alert.lBlock = ^{
        };
        alert.rBlock = ^(NSString * _Nullable text) {
            self.localDeviceName.text = text;
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            [userDefaults setObject:text forKey:@"resetlocalName"];
            [userDefaults setObject:deviceMac forKey:@"deviceMac"];
            [userDefaults synchronize];
            
        };
        alert.modalPresentationStyle = UIModalPresentationOverCurrentContext;
        [self presentViewController:alert animated:NO completion:^{
            alert.titleLabel.text = LocalString(@"更改设备名称");
            alert.textField.text = self.localDeviceName.text;
            [alert.leftBtn setTitle:LocalString(@"取消") forState:UIControlStateNormal];
            [alert.rightBtn setTitle:LocalString(@"确认") forState:UIControlStateNormal];
        }];
        
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 1) {
        return 50;
    }else{
        return 30;
    }
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section == 1) {
        UIView *headerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, 50)];
#if RobotMower | RobotPark
        headerView.backgroundColor = [UIColor darkGrayColor];
#elif MOWOXROBOT
        headerView.backgroundColor = [UIColor lightGrayColor];
        headerView.alpha = 0.6;
#endif
        
        UILabel *firstLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 2, ScreenWidth - 20, 23)];
        [firstLabel setFont:[UIFont systemFontOfSize:18.0]];
        firstLabel.text = LocalString(@"Available devices");
        UILabel *secondLable = [[UILabel alloc] initWithFrame:CGRectMake(15, 25, ScreenWidth - 20, 23)];
        secondLable.text = LocalString(@"(please choose RobotMower_DYM)");
        [secondLable setFont:[UIFont systemFontOfSize:16.0]];
        [headerView addSubview:firstLabel];
        [headerView addSubview:secondLable];
        return headerView;
    }else{
        UIView *headerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, 30)];
#if RobotMower | RobotPark
        headerView.backgroundColor = [UIColor darkGrayColor];
#elif MOWOXROBOT
        headerView.backgroundColor = [UIColor lightGrayColor];
        headerView.alpha = 0.6;
#endif
        UILabel *firstLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 3.5, ScreenWidth - 20, 23)];
        [firstLabel setFont:[UIFont systemFontOfSize:18.0]];
        firstLabel.text = LocalString(@"Connected device");
        [headerView addSubview:firstLabel];
        return headerView;

    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0)
    {
        return nil;
        //return NSLocalizedString(@"connected device", nil) ;
        
    }
    else
    {
        return nil;
        //return NSLocalizedString(@"Available devices\n(please choose DYM2206)", nil);
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    //停止扫描
     //[self.baby cancelScan];
    // OCBPeripheral *peripheral = [self.peripherals objectAtIndex:indexPath.row];
    if(indexPath.section == 0 && self.connectedPeripherals.count > 0)
    {
        /*CBPeripheral *peripheral = [self.connectedPeripherals objectAtIndex:indexPath.row];
        [self performSegueWithIdentifier:@"rename" sender:peripheral.name];*/
        [_baby cancelPeripheralConnection:[self.connectedPeripherals objectAtIndex:indexPath.row]];
        [self.connectedPeripherals removeAllObjects];
        [self.tableView reloadData];
        
    }
    if(indexPath.section == 1)
    {
        //断开蓝牙 清除pincode 密码
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults removeObjectForKey:@"password"];
        [userDefaults removeObjectForKey:@"pincode"];
        [userDefaults synchronize];
        
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
        CBPeripheral *peripheral = [self.peripherals objectAtIndex:indexPath.row];
        
        [self connectBtn: peripheral];
        
    }
}

- (void)startScanBlue
{
    [self.peripherals removeAllObjects];
    [self.tableView reloadData];
    //[self.baby cancelAllPeripheralsConnection];
    //设置委托后直接可以使用，无需等待CBCentralManagerStatePoweredOn状态。
    self.baby.scanForPeripherals().begin();
}

- (IBAction)refresh:(id)sender
{
    [self startScanBlue];
}

- (IBAction)blueclose:(id)sender
{
    NSLog(@"screenHeight: %f", ScreenHeight);
    /*if (ScreenHeight < 568)
    {
        [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"release", nil)];
    }
    else
    {
        NSLog(@"close\n\n\n");
        //[self dismissViewControllerAnimated:YES completion:nil];
        [self.navigationController popViewControllerAnimated:YES];
    }*/
    NSLog(@"close\n\n\n");
    //[self dismissViewControllerAnimated:YES completion:nil];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)connectBtn:(CBPeripheral*)pp {
    [self.baby cancelScan];
    [self.baby cancelAllPeripheralsConnection];
    //    UIButton * senderBtn = sender;
    //    CBPeripheral *currPeripheral = self.peripherals[senderBtn.tag];
    //[SVProgressHUD showInfoWithStatus:@"开始连接设备"];
    
    self.baby.having(pp).and.channel(channelOnPeropheralView).then.connectToPeripherals().discoverServices().discoverCharacteristics().readValueForCharacteristic().discoverDescriptorsForCharacteristic().readValueForDescriptors().begin();
    //self.baby.having(pp).connectToPeripherals().begin();
    }

- (void)disconnectBluetooth{
    if (_appDelegate.currentPeripheral) {
        
        [_baby cancelPeripheralConnection:_appDelegate.currentPeripheral];
        [self.connectedPeripherals removeAllObjects];
        [self.tableView reloadData];
    }
    //断开蓝牙 清除pincode 密码
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults removeObjectForKey:@"password"];
    [userDefaults removeObjectForKey:@"pincode"];
    [userDefaults synchronize];
}


@end
