//
//  BluetoothDataManage.m
//  MOWOX
//
//  Created by Mac on 2017/10/31.
//  Copyright © 2017年 yusz. All rights reserved.
//

#import "BluetoothDataManage.h"
#import "AppDelegate.h"

///@brife 一条帧最大字节
#define QD_BLE_SEND_MAX_LEN 20

///@brife 可判断的数据帧类型数量
#define LEN 13
///@brife 2的24次方
static const long int data24 = 16777216;
///@brife 2的16次方
static const long int data16 = 65536;
///@brife 秒数转换为天
static const long int dayTime = 86400;
///@brife 秒数转换为小时
static const int hourTime = 3600;
///@brife 秒数转换为分钟
static const int minuteTime = 60;

static BluetoothDataManage *sgetonInstanceData = nil;

static int latestVersion_4 =  402;//更新页面 同时修改！！
static int latestVersion = 273;

@interface BluetoothDataManage ()
@property (nonatomic, assign) int updateFlag;

@property (strong, nonatomic)  AppDelegate *appDelegate;
@end

@implementation BluetoothDataManage
- (NSString *)updateFileName{
    #pragma mark - 2021.10.18 改
    if ([@"DY002" isEqual:self.updateString]) {
        _updateFileName = @"DY00274";
    } else if ([@"DY052" isEqual:self.updateString]) {
        _updateFileName = @"DY05274";
    } else if ([@"DY012" isEqual:self.updateString]) {
        _updateFileName = @"DY01274";
    } else if ([@"DY112" isEqual:self.updateString]) {
        _updateFileName = @"DY11274";
    } else if ([@"DY022" isEqual:self.updateString]) {
        _updateFileName = @"DY02274";
    } else if ([@"DY122" isEqual:self.updateString]) {
        _updateFileName = @"DY12274";
    } else if ([@"DY142" isEqual:self.updateString]) {
        _updateFileName = @"DY14274";
    } else if ([@"DY162" isEqual:self.updateString]) {
        _updateFileName = @"DY16274";
    } else if ([@"GY002" isEqual:self.updateString]) {
        _updateFileName = @"GY00274";
    } else if ([@"GY052" isEqual:self.updateString]) {
        _updateFileName = @"GY05274";
    } else if ([@"GY012" isEqual:self.updateString]) {
        _updateFileName = @"GY01274";
    } else if ([@"GY112" isEqual:self.updateString]) {
        _updateFileName = @"GY11274";
    } else if ([@"GY022" isEqual:self.updateString]) {
        _updateFileName = @"GY02274";
    } else if ([@"GY122" isEqual:self.updateString]) {
        _updateFileName = @"GY12274";
    } else if ([@"GY142" isEqual:self.updateString]) {
        _updateFileName = @"GY14274";
    } else if ([@"GY162" isEqual:self.updateString]) {
        _updateFileName = @"GY16274";
    } else if ([@"DM104" isEqual:self.updateString]) {
        _updateFileName = @"DM10403";
    } else if ([@"DM304" isEqual:self.updateString]) {
        _updateFileName = @"DM30403";
    } else if ([@"DA104" isEqual:self.updateString]) {
        _updateFileName = @"DA10402";
    } else if ([@"DA114" isEqual:self.updateString]) {
        _updateFileName = @"DA11402";
    } else if ([@"DA134" isEqual:self.updateString]) {
        _updateFileName = @"DA13402";
    }
    NSLog(@"更新文件包名.....%@",_updateFileName);
    return _updateFileName;
}
- (NSMutableString *)versionString {
    _versionString  = [[NSMutableString alloc] init];
    if ([self.versionChar1 isEqualToNumber:@0] && [self.versionChar2 isEqualToNumber:@0]) {
        if(self.version2 == 2) {
            [_versionString appendFormat:@"%c", 'D'];
            [_versionString appendFormat:@"%c", 'Y'];
        } else if (self.version2 == 3 || self.version2 == 4) {
            [_versionString appendFormat:@"%c", 'D'];
            [_versionString appendFormat:@"%c", 'M'];
        }
    } else {
        [_versionString appendFormat:@"%c", [self.versionChar1 charValue]];
        [_versionString appendFormat:@"%c", [self.versionChar2 charValue]];
    }
    
    [_versionString appendFormat:@"%d", self.sectionvalve];
    [_versionString appendFormat:@"%d", self.version1];
    [_versionString appendFormat:@"%d", self.version2];
    [_versionString appendFormat:@"%d", self.version3];
    [_versionString appendFormat:@"%d", self.version4];
    return _versionString;
}
- (NSMutableString *)updateString {
    _updateString  = [[NSMutableString alloc] init];
    if ([self.versionChar1 isEqualToNumber:@0] && [self.versionChar2 isEqualToNumber:@0]) {
        if(self.version2 == 2) {
            [_updateString appendFormat:@"%c", 'D'];
            [_updateString appendFormat:@"%c", 'Y'];
        } else if (self.version2 == 3 || self.version2 == 4) {
            [_updateString appendFormat:@"%c", 'D'];
            [_updateString appendFormat:@"%c", 'M'];
        }
    } else {
        [_updateString appendFormat:@"%c", [self.versionChar1 charValue]];
        [_updateString appendFormat:@"%c", [self.versionChar2 charValue]];
    }
    
    
    [_updateString appendFormat:@"%d", self.sectionvalve];
    [_updateString appendFormat:@"%d", self.version1];
    [_updateString appendFormat:@"%d", self.version2];
    return _updateString;
}
- (bool)isUpdateBtnHidden {
    if ([@"DY002" isEqual:self.updateString]) {
        return self.updateNum >= 74;
    } else if ([@"DY052" isEqual:self.updateString]) {
        return self.updateNum >= 74;
    } else if ([@"DY012" isEqual:self.updateString]) {
        return self.updateNum >= 74;
    } else if ([@"DY112" isEqual:self.updateString]) {
        return self.updateNum >= 74;
    } else if ([@"DY022" isEqual:self.updateString]) {
        return self.updateNum >= 74;
    } else if ([@"DY122" isEqual:self.updateString]) {
        return self.updateNum >= 74;
    } else if ([@"DY142" isEqual:self.updateString]) {
        return YES;
    } else if ([@"DY162" isEqual:self.updateString]) {
        return self.updateNum >= 74;
    } else if ([@"GY002" isEqual:self.updateString]) {
        return self.updateNum >= 74;
    } else if ([@"GY052" isEqual:self.updateString]) {
        return self.updateNum >= 74;
    } else if ([@"GY012" isEqual:self.updateString]) {
        return self.updateNum >= 74;
    } else if ([@"GY112" isEqual:self.updateString]) {
        return self.updateNum >= 74;
    } else if ([@"GY022" isEqual:self.updateString]) {
        return self.updateNum >= 74;
    } else if ([@"GY122" isEqual:self.updateString]) {
        return self.updateNum >= 74;
    } else if ([@"GY142" isEqual:self.updateString]) {
        return YES;
    } else if ([@"GY162" isEqual:self.updateString]) {
        return self.updateNum >= 74;
    } else if ([@"DM104" isEqual:self.updateString]) {
        return YES;
    } else if ([@"DM304" isEqual:self.updateString]) {
        return YES;
    } else if ([@"DA104" isEqual:self.updateString]) {
        return self.updateNum >= 3;
    } else if ([@"DA114" isEqual:self.updateString]) {
        return self.updateNum >= 2;
    } else if ([@"DA134" isEqual:self.updateString]) {
        return self.updateNum >= 2;
    }
    return NO;
}
#pragma mark - 2021.10.18 改
- (NSString *)updateFirmwareImageName {
    
    if ([@"DY002" isEqual:self.updateString] || [@"DY052" isEqual:self.updateString] ||
        [@"DM104" isEqual:self.updateString] || [@"DM304" isEqual:self.updateString] ||
        [@"DA104" isEqual:self.updateString] || [@"DA134" isEqual:self.updateString] ||
        [@"GY002" isEqual:self.updateString] || [@"GY052" isEqual:self.updateString]) {
        return @"update_10_18_1";
    } else if ([@"DA114" isEqual:self.updateString]) {
        return @"update_10_18_3";
    } else if ([@"DY012" isEqual:self.updateString] || [@"DY112" isEqual:self.updateString] ||
               [@"DY122" isEqual:self.updateString] || [@"DY142" isEqual:self.updateString] ||
               [@"DY162" isEqual:self.updateString]  || [@"GY012" isEqual:self.updateString] ||
               [@"GY112" isEqual:self.updateString] || [@"GY022" isEqual:self.updateString] ||
               [@"GY122" isEqual:self.updateString] || [@"GY142" isEqual:self.updateString] ||
               [@"GY162" isEqual:self.updateString]) {
        return @"update_10_18_2";
    }
    return @"update_10_18_1";
}
#pragma mark - 2021.10.18 改
- (bool)updateHelixset {
    if ([@"DM104" isEqual:self.updateString] || [@"DM304" isEqual:self.updateString]) {
        return true;
    } else {
        return false;
    }
    
}
- (bool)updateultrasound {
    if ([@"DM104" isEqual:self.updateString] || [@"DM304" isEqual:self.updateString]) {
        return false;
    } else {
        return true;
    }
}
#pragma mark - 雨水hidden
- (bool)updateWaitRain {
    if ([@"DM104" isEqual:self.updateString] || [@"DM304" isEqual:self.updateString]) {
        return YES;
    } else {
        return NO;
    }
}
+ (instancetype)shareInstance{
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        sgetonInstanceData = [[super allocWithZone:NULL] init];
    });
    return sgetonInstanceData;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone
{
    return [BluetoothDataManage shareInstance];
}

- (id)init
{
    self = [super init];
    if (self) {
        _bluetoothData = [[NSMutableArray alloc] init];
        _dataContent = [[NSMutableArray alloc] init];
        _receiveData = [[NSMutableArray alloc] init];
        _versionString = [[NSMutableString alloc] init];
        _updateString = [[NSMutableString alloc] init];
        _updateSucceseFlag = 1;
        _updateReceiveFlag = 0;
    }
    return self;
}

- (void)setDataType:(UInt8)dataType{
    _dataType = [NSNumber numberWithUnsignedInteger:dataType];
}

- (void)setDataContent:(NSArray *)dataContent{
    if (_dataContent && ![dataContent containsObject:[NSNull null]]) {
        [_dataContent removeAllObjects];
        [_dataContent addObjectsFromArray:dataContent];
    }
}

#pragma mark - 帧数据组成
- (void)formData
{
    if (_dataContent && _dataType && _bluetoothData) {
        [_bluetoothData removeAllObjects];
        NSMutableArray *startByte = [[NSMutableArray alloc] init];
        NSMutableArray *timeStamp = [[NSMutableArray alloc] init];
        NSMutableArray *endByte = [[NSMutableArray alloc] init];
        
        [startByte addObject:[NSNumber numberWithUnsignedInteger:0x44]];
        [startByte addObject:[NSNumber numberWithUnsignedInteger:0x59]];
        [startByte addObject:[NSNumber numberWithUnsignedInteger:0x4d]];
        
        [timeStamp addObject:[NSNumber numberWithUnsignedInteger:0x00]];
        [timeStamp addObject:[NSNumber numberWithUnsignedInteger:0x00]];
        [timeStamp addObject:[NSNumber numberWithUnsignedInteger:0x00]];
        [timeStamp addObject:[NSNumber numberWithUnsignedInteger:0x00]];
        [timeStamp addObject:[NSNumber numberWithUnsignedInteger:0x00]];
        [timeStamp addObject:[NSNumber numberWithUnsignedInteger:0x00]];
        
        NSNumber *otherRemark = [NSNumber numberWithUnsignedInteger:0x00];
        
        [endByte addObject:[NSNumber numberWithUnsignedInteger:0x16]];
        [endByte addObject:[NSNumber numberWithUnsignedInteger:0x06]];
        [endByte addObject:[NSNumber numberWithUnsignedInteger:0x01]];
        [endByte addObject:[NSNumber numberWithUnsignedInteger:0xFF]];
        [endByte addObject:[NSNumber numberWithUnsignedInteger:0x0a]];
        
        [_bluetoothData addObjectsFromArray:startByte];
        [_bluetoothData addObject:_dataType];
        [_bluetoothData addObjectsFromArray:_dataContent];
        [_bluetoothData addObjectsFromArray:timeStamp];
        [_bluetoothData addObject:otherRemark];
        [_bluetoothData addObjectsFromArray:endByte];
        
        
    }
}
//工作时间的长度较长 去掉时间戳
- (void)worktimeFormData
{
    if (_dataContent && _dataType && _bluetoothData) {
        [_bluetoothData removeAllObjects];
        NSMutableArray *startByte = [[NSMutableArray alloc] init];
        NSMutableArray *endByte = [[NSMutableArray alloc] init];
        
        [startByte addObject:[NSNumber numberWithUnsignedInteger:0x44]];
        [startByte addObject:[NSNumber numberWithUnsignedInteger:0x59]];
        [startByte addObject:[NSNumber numberWithUnsignedInteger:0x4d]];
        
        NSNumber *otherRemark = [NSNumber numberWithUnsignedInteger:0x00];
        
        [endByte addObject:[NSNumber numberWithUnsignedInteger:0x16]];
        [endByte addObject:[NSNumber numberWithUnsignedInteger:0x06]];
        [endByte addObject:[NSNumber numberWithUnsignedInteger:0x01]];
        [endByte addObject:[NSNumber numberWithUnsignedInteger:0xFF]];
        [endByte addObject:[NSNumber numberWithUnsignedInteger:0x0a]];
        
        [_bluetoothData addObjectsFromArray:startByte];
        [_bluetoothData addObject:_dataType];
        [_bluetoothData addObjectsFromArray:_dataContent];
        [_bluetoothData addObject:otherRemark];
        [_bluetoothData addObjectsFromArray:endByte];
        
        
    }
}
//工作时间 单独处理
- (void)sendWorktimeBluetoothFrame
{
    [self worktimeFormData];
    dispatch_queue_t queue = dispatch_get_main_queue();
    dispatch_async(queue, ^{
        AppDelegate *appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
        if (appDelegate.status == 0) {
            [[NetWork shareNetWork] mowerSendWithData:self.bluetoothData];
        }else{
            if (self.bluetoothData) {
                NSUInteger len = self.bluetoothData.count;
                UInt8 sendBuffer[len];
                for (int i = 0; i < len; i++) {
                    sendBuffer[i] = [[self.bluetoothData objectAtIndex:i] unsignedCharValue];
                }
                NSData *sendData = [NSData dataWithBytes:sendBuffer length:len];
                NSLog(@"发送一条蓝牙帧： %@",sendData);
                AppDelegate *appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
                
                for (int i = 0; i < [sendData length]; i += QD_BLE_SEND_MAX_LEN) {
                    
                    // 预加 最大包长度，如果依然小于总数据长度，可以取最大包数据大小
                    if ((i + QD_BLE_SEND_MAX_LEN) < [sendData length]) {
                        NSString *rangeStr = [NSString stringWithFormat:@"%i,%i", i, QD_BLE_SEND_MAX_LEN];
                        NSData *subData = [sendData subdataWithRange:NSRangeFromString(rangeStr)];
                        if (appDelegate.currentCharacteristic && appDelegate.currentPeripheral)
                        {
                            [appDelegate.currentPeripheral writeValue:subData forCharacteristic:appDelegate.currentCharacteristic type:CBCharacteristicWriteWithResponse];
                        }
                        //根据接收模块的处理能力做相应延时
                        usleep(50 * 1000);
                    }
                    else {
                        NSString *rangeStr = [NSString stringWithFormat:@"%i,%i", i, (int)([sendData length] - i)];
                        NSData *subData = [sendData subdataWithRange:NSRangeFromString(rangeStr)];
                        if (appDelegate.currentCharacteristic && appDelegate.currentPeripheral)
                        {
                            [appDelegate.currentPeripheral writeValue:subData forCharacteristic:appDelegate.currentCharacteristic type:CBCharacteristicWriteWithResponse];
                        }
                        usleep(50 * 1000);
                    }
                }
                
            }
        }
    });
    
}

/**
 发送信息
 */
- (void)sendBluetoothFrame
{
    [self formData];
    dispatch_queue_t queue = dispatch_get_main_queue();
    dispatch_async(queue, ^{
        AppDelegate *appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
        if (appDelegate.status == 0) {
            [[NetWork shareNetWork] mowerSendWithData:self.bluetoothData];
        }else{
            if (self.bluetoothData) {
                NSUInteger len = self.bluetoothData.count;
                UInt8 sendBuffer[len];
                for (int i = 0; i < len; i++) {
                    sendBuffer[i] = [[self.bluetoothData objectAtIndex:i] unsignedCharValue];
                }
                NSData *sendData = [NSData dataWithBytes:sendBuffer length:len];
                NSLog(@"发送一条蓝牙帧： %@",sendData);
                AppDelegate *appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
                
                for (int i = 0; i < [sendData length]; i += QD_BLE_SEND_MAX_LEN) {
                    
                    // 预加 最大包长度，如果依然小于总数据长度，可以取最大包数据大小
                    if ((i + QD_BLE_SEND_MAX_LEN) < [sendData length]) {
                        NSString *rangeStr = [NSString stringWithFormat:@"%i,%i", i, QD_BLE_SEND_MAX_LEN];
                        NSData *subData = [sendData subdataWithRange:NSRangeFromString(rangeStr)];
                        if (appDelegate.currentCharacteristic && appDelegate.currentPeripheral)
                        {
                            //发送数据
                            [appDelegate.currentPeripheral writeValue:subData forCharacteristic:appDelegate.currentCharacteristic type:CBCharacteristicWriteWithResponse];
                        }
                        //根据接收模块的处理能力做相应延时
                        usleep(50 * 1000);
                    }
                    else {
                        NSString *rangeStr = [NSString stringWithFormat:@"%i,%i", i, (int)([sendData length] - i)];
                        NSData *subData = [sendData subdataWithRange:NSRangeFromString(rangeStr)];
                        if (appDelegate.currentCharacteristic && appDelegate.currentPeripheral)
                        {
                            [appDelegate.currentPeripheral writeValue:subData forCharacteristic:appDelegate.currentCharacteristic type:CBCharacteristicWriteWithResponse];
                        }
                        usleep(50 * 1000);
                    }
                }
                
            }
        }
    });
    
}
/**
 发送固件更新部位
 */
- (void)formMotorData:(UInt8)controlCode{
    
    AppDelegate *appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    
    UInt8 sendBuffer[4];
    sendBuffer[0] = [[NSNumber numberWithUnsignedInteger:0x54] unsignedCharValue];
    sendBuffer[1] = [[NSNumber numberWithUnsignedInteger:0x44] unsignedCharValue];
    sendBuffer[2] = controlCode;
    sendBuffer[3] = [[NSNumber numberWithUnsignedInteger:0x05] unsignedCharValue];
    NSData *crc8Buffer = [NSData dataWithBytes:sendBuffer length:4];
    uint8_t crc8 = [self crc8:crc8Buffer];
    NSLog(@"校验位%d",crc8);
    
    UInt8 sendData[5];
    sendData[0] = [[NSNumber numberWithUnsignedInteger:0x54] unsignedCharValue];
    sendData[1] = [[NSNumber numberWithUnsignedInteger:0x44] unsignedCharValue];
    sendData[2] = controlCode;
    sendData[3] = [[NSNumber numberWithUnsignedInteger:0x05] unsignedCharValue];
    sendData[4] = [[NSNumber numberWithUnsignedInteger:crc8] unsignedCharValue];
    
    NSData *sendDataBuffer = [NSData dataWithBytes:sendData length:5];
    NSLog(@"发送一条电机设置更新蓝牙帧:%@",sendDataBuffer);
    if (appDelegate.currentCharacteristic && appDelegate.currentPeripheral)
    {
        [appDelegate.currentPeripheral writeValue:sendDataBuffer forCharacteristic:appDelegate.currentCharacteristic type:CBCharacteristicWriteWithResponse];
    }
    usleep(10 * 1000);
}


#pragma mark - 处理接收数据
- (void)handleData:(NSArray *)data
{
    #pragma mark - 固件更新
    if (![self frameIsRight:data]) {
        //烧固件时判断校验成功or失败
        UInt8 front1 = 0;
        UInt8 front2 = 0;
        UInt8 front3 = 0;
        UInt8 front4 = 0;
        UInt8 front5 = 0;
        UInt8 front6 = 0;
        
        if(data != nil && data.count >= 2) {
            front1 = [data[0] unsignedCharValue];
            front2 = [data[1] unsignedCharValue];
            if (front1 == 255 && front2 == 255){ //更新完成
                [[NSNotificationCenter defaultCenter] postNotificationName:@"updateSuccese" object:nil userInfo:nil];
                    
                [[NSNotificationCenter defaultCenter] postNotificationName:@"progressNumber" object:nil userInfo:nil];
                self.updateFlag = 0;
            }
        }
        
        if (data != nil && data.count == 6) {
            self.updateReceiveFlag = 1;
            if (_updateSucceseFlag == 0) {
                //最后更新 失败
                [NSObject showHudTipStr:LocalString(@"FAILED!")];
                _updateSucceseFlag = 1;
                
                return;
            }
            front1 = [data[0] unsignedCharValue];
            front2 = [data[1] unsignedCharValue];
            front3 = [data[2] unsignedCharValue];
            front4 = [data[3] unsignedCharValue];
            front5 = [data[4] unsignedCharValue];
            front6 = [data[5] unsignedCharValue];
            if (front1 == 69 && front2 == 79 && front3 == 82 && front4 == 82 && front5 == 79 && front6 == 82){ //eorror
                NSMutableDictionary *dataDic = [[NSMutableDictionary alloc] init];
                NSString *result = @"error";
                [dataDic setObject:result forKey:@"result"];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"shaogujian" object:nil userInfo:dataDic];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"shaogujianOld" object:nil userInfo:dataDic];
            }
        } else if (data != nil && data.count == 2){
            self.updateReceiveFlag = 1;
            front1 = [data[0] unsignedCharValue];
            front2 = [data[1] unsignedCharValue];
            if (front1 == 79 && front2 == 75 && self.updateFlag == 1) { // 4f 4b ok
                if (!self.updateFirmware_j) {
                    self.updateFirmware_j = 0;
                }
                if (!self.progress_num) {
                    self.progress_num = 0;
                }
                //固件更新 电机版本
                self.updateFirmware_j += firmwareData([BluetoothDataManage shareInstance].version1);
                
                switch (_updateSucceseFlag) {
                    case 0:
                    {
                        NSLog(@"停止");
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"GETupdateSucceseEnd" object:nil userInfo:nil];
                        return;
                    }
                        break;
                    case 1:
                        self.updateFirmware_packageNum = self.updateFirmware_packageNum - 1;
                        NSLog(@"self.updateFirmware_packageNum - %d", self.updateFirmware_packageNum);
                        break;
                    case 2:
                        self.updateFirmware_packageNum_Motor--;
                        break;
                    case 3:
                        self.updateFirmware_packageNum_Left--;
                        
                        break;
                    case 4:
                    {
                        self.updateFirmware_packageNum_Right--;
                        //[[NSNotificationCenter defaultCenter] postNotificationName:@"shaogujian" object:nil userInfo:nil];
                    }
                        break;
                        
                    default:
                        break;
                }
                
                NSMutableDictionary *dataDic = [[NSMutableDictionary alloc] init];
                NSString *result = @"success";
                [dataDic setObject:result forKey:@"result"];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"progressNumber" object:nil userInfo:nil];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"shaogujian" object:nil userInfo:dataDic];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"shaogujianOld" object:nil userInfo:dataDic];
                self.progress_num++;
            }
            if (front1 == 255 && front2 == 255){ //更新完成
                [[NSNotificationCenter defaultCenter] postNotificationName:@"updateSuccese" object:nil userInfo:nil];
                
                [[NSNotificationCenter defaultCenter] postNotificationName:@"progressNumber" object:nil userInfo:nil];
                self.updateFlag = 0;
                
            }
        }else if (data != nil && data.count == 3){ //更新结束
            self.updateReceiveFlag = 1;
            front1 = [data[0] unsignedCharValue];
            front2 = [data[1] unsignedCharValue];
            front3 = [data[2] unsignedCharValue];
            if (front1 == 1 && front2 == 255 && front3 == 255){ //主程序完成
                self.updateSucceseFlag = 2; // 电机包--
                self.updateFirmware_j = 0;
    
                [[NSNotificationCenter defaultCenter] postNotificationName:@"updateSuccese_main" object:nil userInfo:nil];
                
            }
            if (front1 == 2 && front2 == 255 && front3 == 255){ //割草机电机完成
                self.updateSucceseFlag = 3; //左电机包--
                self.updateFirmware_j = 0;
                [[NSNotificationCenter defaultCenter] postNotificationName:@"updateSuccese_motor" object:nil userInfo:nil];
    
            }
            if (front1 == 3 && front2 == 255 && front3 == 255){ //左电机完成
                self.updateSucceseFlag = 4; //右电机包--
                self.updateFirmware_j = 0;
                [[NSNotificationCenter defaultCenter] postNotificationName:@"updateSuccese_left" object:nil userInfo:nil];
                
            }
            if (front1 == 4 && front2 == 255 && front3 == 255){ //右电机完成
                self.updateSucceseFlag = 0; //完成 查询更新
                self.updateFirmware_j = 0;
                [[NSNotificationCenter defaultCenter] postNotificationName:@"updateSuccese_right" object:nil userInfo:nil];
                
            }
            if (front1 == 5 && front2 == 255 && front3 == 255){ //全部完成
                
                [[NSNotificationCenter defaultCenter] postNotificationName:@"updateSucceseEnd" object:nil userInfo:nil];
                
            }
        }
        return;
    }
    
    /**
     *对割草机的所有功能响应
     */
    if (_receiveData) {
        [_receiveData removeAllObjects];
        [_receiveData addObjectsFromArray:data];
        self.frameType = [self checkOutType:data];//判断数据类型
        if (self.frameType == otherFrame) {
            
            NSLog(@"接收到未知的数据帧");
            
        }else if (self.frameType == readBattery){
            NSLog(@"接收到readBattery");
            NSMutableDictionary *dataDic = [[NSMutableDictionary alloc] init];
            NSNumber *batterData = _receiveData[4];
            NSNumber *CPUTemperature = _receiveData[5];
            NSNumber *batterTemperature = _receiveData[6];
            NSNumber *mowerState = _receiveData[7];
            NSNumber *version1 = _receiveData[8];
            NSNumber *version2 = _receiveData[9];
            NSNumber *version3 = _receiveData[10];
            #pragma mark - 2021.10.18 改
            NSNumber *version4 = _receiveData[11];
            NSNumber *robotState = _receiveData[12];
            self.versionChar1 = _receiveData[13];
            self.versionChar2 = _receiveData[14];
            _versionString  = [[NSMutableString alloc] init];
            _updateString  = [[NSMutableString alloc] init];
            if ([self.versionChar1 isEqualToNumber:@0] && [self.versionChar2 isEqualToNumber:@0]) {
                _deviceType = @1;
                if([version2 isEqualToNumber:@2]) {
                    [_versionString appendFormat:@"%c", 'D'];
                    [_versionString appendFormat:@"%c", 'Y'];
                    [self.updateString appendFormat:@"%c", 'D'];
                    [self.updateString appendFormat:@"%c", 'Y'];
                } else if ([version2 isEqualToNumber:@3] || [version2 isEqualToNumber:@4]) {
                    [_versionString appendFormat:@"%c", 'D'];
                    [_versionString appendFormat:@"%c", 'M'];
                    [_updateString appendFormat:@"%c", 'D'];
                    [_updateString appendFormat:@"%c", 'M'];
                }
            } else {
                _deviceType = @2;
                [_versionString appendFormat:@"%c", [self.versionChar1 charValue]];
                [_versionString appendFormat:@"%c", [self.versionChar2 charValue]];
                [_updateString appendFormat:@"%c", [self.versionChar1 charValue]];
                [_updateString appendFormat:@"%c", [self.versionChar2 charValue]];
            }
            
    
            self.version1 = [version1 intValue];
            self.version2 = [version2 intValue];
            self.version3 = [version3 intValue];
            self.version4 = [version4 intValue];
            self.updateNum = self.version3 * 10 + self.version4;
            [_versionString appendFormat:@"%d", self.sectionvalve];
            [_versionString appendFormat:@"%d", self.version1];
            [_versionString appendFormat:@"%d", self.version2];
            [_versionString appendFormat:@"%d", self.version3];
            [_versionString appendFormat:@"%d", self.version4];
            _versionupdate = self.version2 * 100 + self.version3 * 10 + self.version4;
            
            [dataDic setObject:batterData forKey:@"batterData"];
            [dataDic setObject:CPUTemperature forKey:@"CPUTemperature"];
            [dataDic setObject:batterTemperature forKey:@"batterTemperature"];
            [dataDic setObject:mowerState forKey:@"mowerState"];
            [dataDic setObject:robotState forKey:@"robotState"];
            
            [self isUpdateBtnHidden];
            [self updateFirmwareImageName];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"getMowerData" object:nil userInfo:dataDic];
            
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [defaults setObject:_deviceType forKey:@"deviceType"];
            [defaults synchronize];
            
            
            [_updateString appendFormat:@"%d", self.sectionvalve];
            [_updateString appendFormat:@"%d", self.version1];
            [_updateString appendFormat:@"%d", self.version2];
            [defaults setObject:self.updateString forKey:@"updateString"];
            [defaults synchronize];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"getDeviceType" object:nil userInfo:nil];
        }else if (self.frameType == getAlerts){
            NSLog(@"接收到getAlerts");
            NSMutableDictionary *dataDic = [[NSMutableDictionary alloc] init];
            NSNumber *year1 = _receiveData[4];
            NSNumber *year2 = _receiveData[5];
            NSNumber *month = _receiveData[6];
            NSNumber *day = _receiveData[7];
            NSNumber *hour = _receiveData[8];
            NSNumber *minute = _receiveData[9];
            NSNumber *second = _receiveData[10];
            NSString *wrongContent = _receiveData[11];
            NSNumber *robotState = _receiveData[12];
            NSString *dateLabel = [[NSString alloc] initWithFormat:@"%d-%02d-%02d %02d:%02d:%02d",[year1 intValue]*256 + [year2 intValue],[month intValue],[day intValue],[hour intValue],[minute intValue],[second intValue]];
            [dataDic setObject:dateLabel forKey:@"dateLabel"];
            [dataDic setObject:wrongContent forKey:@"wrongContent"];
            [dataDic setObject:robotState forKey:@"robotState"];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"recieveAlertsContent" object:nil userInfo:dataDic];
        }else if (self.frameType == getMowerTime){
            NSLog(@"接收到getMowerTime");
//            NSMutableDictionary *dataDic = [[NSMutableDictionary alloc] init];
//            NSNumber *year1 = _receiveData[4];
//            NSNumber *year2 = _receiveData[5];
//            NSNumber *month = _receiveData[6];
//            NSNumber *day = _receiveData[7];
//            NSNumber *hour = _receiveData[8];
//            NSNumber *minute = _receiveData[9];
//            [dataDic setObject:year1 forKey:@"year1"];
//            [dataDic setObject:year2 forKey:@"year2"];
//            [dataDic setObject:month forKey:@"month"];
//            [dataDic setObject:day forKey:@"day"];
//            [dataDic setObject:hour forKey:@"hour"];
//            [dataDic setObject:minute forKey:@"minute"];
//            [[NSNotificationCenter defaultCenter] postNotificationName:@"recieveMowerTime" object:nil userInfo:dataDic];
        }else if (self.frameType == getMowerLanguage){
            NSLog(@"接收到getMowerLanguage");
            NSMutableDictionary *dataDic = [[NSMutableDictionary alloc] init];
            NSNumber *Language = _receiveData[4];
            [dataDic setObject:Language forKey:@"Language"];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"recieveMowerLanguage" object:nil userInfo:dataDic];
        }else if (self.frameType == getWorkingTime1){
            NSLog(@"接收到getWorkingTime1");
            
            NSMutableDictionary *dataDic = [[NSMutableDictionary alloc] init];
            if (self.versionupdate < 268) {
                //老版本
                NSNumber *monStart = _receiveData[4];
                NSNumber *monWork = _receiveData[5];
                NSNumber *tueStart = _receiveData[6];
                NSNumber *tueWork = _receiveData[7];
                NSNumber *wedStart = _receiveData[8];
                NSNumber *wedWork = _receiveData[9];
                NSNumber *thuStart = _receiveData[10];
                NSNumber *thuWork = _receiveData[11];
                [dataDic setObject:monStart forKey:@"monStart"];
                [dataDic setObject:monWork forKey:@"monWork"];
                [dataDic setObject:tueStart forKey:@"tueStart"];
                [dataDic setObject:tueWork forKey:@"tueWork"];
                [dataDic setObject:wedStart forKey:@"wedStart"];
                [dataDic setObject:wedWork forKey:@"wedWork"];
                [dataDic setObject:thuStart forKey:@"thuStart"];
                [dataDic setObject:thuWork forKey:@"thuWork"];
            }else{
                
                NSNumber *monHour = _receiveData[4];
                NSNumber *tueHour = _receiveData[5];
                NSNumber *wedHour = _receiveData[6];
                NSNumber *thuHour = _receiveData[7];
                NSNumber *friHour = _receiveData[8];
                NSNumber *satHour = _receiveData[9];
                NSNumber *sunHour = _receiveData[10];
                NSNumber *monMinute = _receiveData[11];
                NSNumber *tueMinute = _receiveData[12];
                NSNumber *wedMinute = _receiveData[13];
                NSNumber *thuMinute = _receiveData[14];
                NSNumber *friMinute = _receiveData[15];
                NSNumber *satMinute = _receiveData[16];
                NSNumber *sunMinute = _receiveData[17];
                [dataDic setObject:monHour forKey:@"monHour"];
                [dataDic setObject:tueHour forKey:@"tueHour"];
                [dataDic setObject:wedHour forKey:@"wedHour"];
                [dataDic setObject:thuHour forKey:@"thuHour"];
                [dataDic setObject:friHour forKey:@"friHour"];
                [dataDic setObject:satHour forKey:@"satHour"];
                [dataDic setObject:sunHour forKey:@"sunHour"];
                [dataDic setObject:monMinute forKey:@"monMinute"];
                [dataDic setObject:tueMinute forKey:@"tueMinute"];
                [dataDic setObject:wedMinute forKey:@"wedMinute"];
                [dataDic setObject:thuMinute forKey:@"thuMinute"];
                [dataDic setObject:friMinute forKey:@"friMinute"];
                [dataDic setObject:satMinute forKey:@"satMinute"];
                [dataDic setObject:sunMinute forKey:@"sunMinute"];
                
            }
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"recieveWorkingTime1" object:nil userInfo:dataDic];
            
        }else if (self.frameType == getWorkingTime2){
            NSLog(@"接收到getWorkingTime2");
            NSMutableDictionary *dataDic = [[NSMutableDictionary alloc] init];
            if (self.versionupdate < 268) {
                NSNumber *friStart = _receiveData[4];
                NSNumber *friWork = _receiveData[5];
                NSNumber *satStart = _receiveData[6];
                NSNumber *satWork = _receiveData[7];
                NSNumber *sunStart = _receiveData[8];
                NSNumber *sunWork = _receiveData[9];
                [dataDic setObject:friStart forKey:@"friStart"];
                [dataDic setObject:friWork forKey:@"friWork"];
                [dataDic setObject:satStart forKey:@"satStart"];
                [dataDic setObject:satWork forKey:@"satWork"];
                [dataDic setObject:sunStart forKey:@"sunStart"];
                [dataDic setObject:sunWork forKey:@"sunWork"];
            }else{
                
                NSNumber *monWorkHour = _receiveData[4];
                NSNumber *tueWorkHour = _receiveData[5];
                NSNumber *wedWorkHour = _receiveData[6];
                NSNumber *thuWorkHour = _receiveData[7];
                NSNumber *friWorkHour = _receiveData[8];
                NSNumber *satWorkHour = _receiveData[9];
                NSNumber *sunWorkHour = _receiveData[10];
                NSNumber *monWorkMinute = _receiveData[11];
                NSNumber *tueWorkMinute = _receiveData[12];
                NSNumber *wedWorkMinute = _receiveData[13];
                NSNumber *thuWorkMinute = _receiveData[14];
                NSNumber *friWorkMinute = _receiveData[15];
                NSNumber *satWorkMinute = _receiveData[16];
                NSNumber *sunWorkMinute = _receiveData[17];
                [dataDic setObject:monWorkHour forKey:@"monWorkHour"];
                [dataDic setObject:tueWorkHour forKey:@"tueWorkHour"];
                [dataDic setObject:wedWorkHour forKey:@"wedWorkHour"];
                [dataDic setObject:thuWorkHour forKey:@"thuWorkHour"];
                [dataDic setObject:friWorkHour forKey:@"friWorkHour"];
                [dataDic setObject:satWorkHour forKey:@"satWorkHour"];
                [dataDic setObject:sunWorkHour forKey:@"sunWorkHour"];
                
                [dataDic setObject:monWorkMinute forKey:@"monWorkMinute"];
                [dataDic setObject:tueWorkMinute forKey:@"tueWorkMinute"];
                [dataDic setObject:wedWorkMinute forKey:@"wedWorkMinute"];
                [dataDic setObject:thuWorkMinute forKey:@"thuWorkMinute"];
                [dataDic setObject:friWorkMinute forKey:@"friWorkMinute"];
                [dataDic setObject:satWorkMinute forKey:@"satWorkMinute"];
                [dataDic setObject:sunWorkMinute forKey:@"sunWorkMinute"];
                
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:@"recieveWorkingTime2" object:nil userInfo:dataDic];
        }else if (self.frameType == getMowerSetting){
            NSLog(@"接收到getMowerSetting");
            NSMutableDictionary *dataDic = [[NSMutableDictionary alloc] init];
            NSNumber *rain = _receiveData[4];
            NSNumber *boundary = _receiveData[5];
            NSNumber *helix = _receiveData[7];
            NSNumber *hour = _receiveData[8];
            NSNumber *min = _receiveData[9];
            [dataDic setObject:rain forKey:@"rain"];
            [dataDic setObject:boundary forKey:@"boundary"];
            [dataDic setObject:helix forKey:@"helix"];
            [dataDic setObject:hour forKey:@"hour"];
            [dataDic setObject:min forKey:@"min"];
            if ([BluetoothDataManage shareInstance].version1 == 4) {
                NSNumber *ultrasound = _receiveData[6];
                [dataDic setObject:ultrasound forKey:@"ultrasound"];
                
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:@"recieveMowerSetting" object:nil userInfo:dataDic];
        }else if (self.frameType == updateFirmware){
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"recieveUpdateFirmware" object:nil userInfo:nil];
            self.updateFlag = 1;
              
            
        }else if (self.frameType == getPinCode){
            NSNumber *thousand = _receiveData[4];
            NSNumber *hungred = _receiveData[5];
            NSNumber *ten = _receiveData[6];
            NSNumber *one = _receiveData[7];
            _pincode = [thousand intValue] * 1000 +[hungred intValue] * 100 + [ten intValue] * 10 + [one intValue];
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [defaults setInteger:_pincode forKey:@"pincode"];
            [defaults synchronize];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"updatePinCode" object:nil userInfo:nil];
            
            _sectionvalve = [_receiveData[8] intValue];
        }else if (self.frameType == setPincodeResponse){
            if ([_receiveData[0] intValue] == 1) {
                [NSObject showHudTipStr:LocalString(@"Set pincode wrong")];
            }else{
                NSNumber *thousand = _receiveData[4];
                NSNumber *hungred = _receiveData[5];
                NSNumber *ten = _receiveData[6];
                NSNumber *one = _receiveData[7];
                _pincode = [thousand intValue] * 1000 +[hungred intValue] * 100 + [ten intValue] * 10 + [one intValue];
                NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                [defaults setInteger:_pincode forKey:@"pincode"];
                [defaults synchronize];
            }
        }else if (self.frameType == getAeraMessage){
            NSLog(@"接收到getAeraMessage");
            NSMutableDictionary *dataDic = [[NSMutableDictionary alloc] init];
            NSNumber *Apresent = _receiveData[4];
            NSNumber *AdistanceHungred = _receiveData[5];
            NSNumber *AdistanceTen = _receiveData[6];
            NSNumber *AdistanceOne = _receiveData[7];
            NSNumber *Bpresent = _receiveData[8];
            NSNumber *BdistanceHungred = _receiveData[9];
            NSNumber *BdistanceTen = _receiveData[10];
            NSNumber *BdistanceOne = _receiveData[11];
            [dataDic setObject:Apresent forKey:@"Apresent"];
            [dataDic setObject:AdistanceHungred forKey:@"AdistanceHungred"];
            [dataDic setObject:AdistanceTen forKey:@"AdistanceTen"];
            [dataDic setObject:AdistanceOne forKey:@"AdistanceOne"];
            [dataDic setObject:Bpresent forKey:@"Bpresent"];
            [dataDic setObject:BdistanceHungred forKey:@"BdistanceHungred"];
            [dataDic setObject:BdistanceTen forKey:@"BdistanceTen"];
            [dataDic setObject:BdistanceOne forKey:@"BdistanceOne"];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"recieveAeraMessage" object:nil userInfo:dataDic];
        }else if (self.frameType == getRobotTimeContent){
            NSLog(@"接收到getRobotTimeContent");
            NSMutableDictionary *dataDic = [[NSMutableDictionary alloc] init];
            NSNumber *motorWorkTime1 = _receiveData[4];
            NSNumber *motorWorkTime2 = _receiveData[5];
            NSNumber *motorWorkTime3 = _receiveData[6];
            NSNumber *motorWorkTime4 = _receiveData[7];
            NSNumber *motorRunningTime1 = _receiveData[8];
            NSNumber *motorRunningTime2 = _receiveData[9];
            NSNumber *motorRunningTime3 = _receiveData[10];
            NSNumber *motorRunningTime4 = _receiveData[11];
            NSNumber *onTime1 = _receiveData[12];
            NSNumber *onTime2 = _receiveData[13];
            NSNumber *onTime3 = _receiveData[14];
            NSNumber *onTime4 = _receiveData[15];
            //处理数据
            long int motorWorkTime =0,motorRunningTime =0,onTime =0;
            
            motorWorkTime = [motorWorkTime1 intValue]*data24 + [motorWorkTime2 intValue]*data16 +[motorWorkTime3 intValue]*256 +[motorWorkTime4 intValue];
            motorRunningTime = [motorRunningTime1 intValue]*data24 + [motorRunningTime2 intValue]*data16 +[motorRunningTime3 intValue]*256 +[motorRunningTime4 intValue];
            onTime = [onTime1 intValue]*data24 + [onTime2 intValue]*data16 +[onTime3 intValue]*256 +[onTime4 intValue];
            
            NSString *motorWorkTimeStr = [[NSString alloc] initWithFormat:@"%02ld%@ %02ld%@ %02ld%@ %02ld%@",motorWorkTime/dayTime,@"d",motorWorkTime % dayTime/ hourTime,@"h",motorWorkTime % dayTime % hourTime/minuteTime,@"m",motorWorkTime%dayTime%hourTime%minuteTime,@"s"];
            NSString *motorRunningTimeStr = [[NSString alloc] initWithFormat:@"%02ld%@ %02ld%@ %02ld%@ %02ld%@",motorRunningTime/dayTime,@"d",motorRunningTime % dayTime/ hourTime,@"h",motorRunningTime % dayTime % hourTime/minuteTime,@"m",motorRunningTime%dayTime%hourTime%minuteTime,@"s"];
            NSString *onTimeStr = [[NSString alloc] initWithFormat:@"%02ld%@ %02ld%@ %02ld%@ %02ld%@",onTime/dayTime,@"d",onTime % dayTime/ hourTime,@"h",onTime % dayTime % hourTime/minuteTime,@"m",onTime % dayTime % hourTime % minuteTime,@"s"];
            
            [dataDic setObject:motorWorkTimeStr forKey:@"motorWorkTime"];
            [dataDic setObject:motorRunningTimeStr forKey:@"motorRunningTime"];
            [dataDic setObject:onTimeStr forKey:@"onTime"];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"recieveRobotTimeContent" object:nil userInfo:dataDic];
        }else if (self.frameType == getBladeUserTime){
            NSLog(@"接收到getBladeUserTime");
            NSMutableDictionary *dataDic = [[NSMutableDictionary alloc] init];
            NSNumber *bladeUserTime1 = _receiveData[4];
            NSNumber *bladeUserTime2 = _receiveData[5];
            NSNumber *bladeUserTime3 = _receiveData[6];
            NSNumber *bladeUserTime4 = _receiveData[7];
            //处理数据
            long int bladeUserTime =0;
            
            bladeUserTime = [bladeUserTime1 intValue]*data24 + [bladeUserTime2 intValue]*data16 +[bladeUserTime3 intValue]*256 +[bladeUserTime4 intValue];
            
            NSString *bladeUserTimeStr = [[NSString alloc] initWithFormat:@"%02ld%@ %02ld%@ %02ld%@ %02ld%@",bladeUserTime/dayTime,@"d",bladeUserTime % dayTime/ hourTime,@"h",bladeUserTime % dayTime % hourTime/minuteTime,@"m",bladeUserTime%dayTime%hourTime%minuteTime,@"s"];
            
            [dataDic setObject:bladeUserTimeStr forKey:@"bladeUserTimeStr"];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"recieveBladeUserTime" object:nil userInfo:dataDic];
        }
    }
}

- (BOOL)frameIsRight:(NSArray *)data
{
    if (data != nil && ![data isKindOfClass:[NSNull class]] && data.count >= 3) {
        UInt8 front1 = [data[0] unsignedCharValue];
        UInt8 front2 = [data[1] unsignedCharValue];
        UInt8 front3 = [data[2] unsignedCharValue];
        UInt8 front4 = [data[3] unsignedCharValue];
        if (front1 != 0x44 || front2 != 0x59 || front3 != 0x4d) {
            return NO;
        }
        if (front1 == 0x44 && front2 == 0x44 && front3 == 0x59 && front4 == 0x4d) {
            return YES;
        }
    }else{
        return NO;
    }
    
    return YES;
}
/**
 判断收到信息的数据类型
 */
- (FrameType)checkOutType:(NSArray *)data
{
    unsigned char dataType;
    
    unsigned char type[LEN]= {
        0x80,0x82,0x83,0x84,0x85,0x8e,0x89,0x8a,0x8c,0x86,0x8d,0x8f,0x7f
    };
    UInt8 font2 = [data[1] unsignedCharValue];
    if (font2 == 0x44) {
        dataType = [data[4] unsignedIntegerValue];
    } else {
        dataType = [data[3] unsignedIntegerValue];
    }
    NSLog(@"%d", dataType);
    
    FrameType returnVal = otherFrame;
    
    for (int i = 0; i < LEN; i++) {
        if (dataType == type[i]) {
            switch (i) {
                case 0:
                    returnVal = readBattery;
                    break;
                    
                case 1:
                    returnVal = getMowerTime;
                    break;
                    
                case 2:
                    returnVal = getMowerLanguage;
                    break;
                    
                case 3:
                    returnVal = getWorkingTime1;
                    break;
                    
                case 4:
                    returnVal = getWorkingTime2;
                    break;
                    
                case 5:
                    returnVal = getAlerts;
                    break;
                    
                case 6:
                    returnVal = getMowerSetting;
                    break;
                    
                case 7:
                    returnVal = updateFirmware;
                    break;
                case 8:
                    returnVal = getPinCode;
                    break;
                case 9:
                    returnVal = setPincodeResponse;
                    break;
                    
                case 10:
                    returnVal = getAeraMessage;
                    break;
                case 11:
                    returnVal = getRobotTimeContent;
                    break;
                case 12:
                    returnVal = getBladeUserTime;
                    break;
                default:
                    returnVal = otherFrame;
                    break;
            }
        }
    }
    return returnVal;
}

/**
 **crc8检验
 **/
- (uint8_t)crc8:(NSData *)data
{
    uint8_t crc=0;
    crc = 0;
    
    uint8_t byteArray[[data length]];
    [data getBytes:&byteArray];
    
    for (int i = 0; i < [data length]; i++) {
        Byte byte = byteArray[i];
        crc ^= byte;
        for(int j = 0;j < 8;j++)
        {
            if(crc & 0x01)
            {
                crc = (crc >> 1) ^ 0x8C;
            }else crc >>= 1;
        }
    }
    return crc;
}


@end
