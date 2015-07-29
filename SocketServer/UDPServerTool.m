//
//  UDPServerTool.m
//  SocketClient
//
//  Created by ZhangJing on 15/7/26.
//  Copyright (c) 2015年 SINGLE. All rights reserved.
//

#import "UDPServerTool.h"

@implementation UDPServerTool

static UDPServerTool *_instance;

+ (instancetype)shareInstance{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!_instance) {
            _instance = [[UDPServerTool alloc]init];
            _instance.serverSocket = [[GCDAsyncUdpSocket alloc]initWithDelegate:_instance delegateQueue:dispatch_get_main_queue()];
        }
    });
    return _instance;
}

//- (GCDAsyncUdpSocket *)serverSocket{
//    if (_serverSocket) {
//        _serverSocket = [[GCDAsyncUdpSocket alloc]initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
//    }
//    return _serverSocket;
//}


- (void)startStop:(NSInteger)port withError:(NSError *__autoreleasing *)error{
    if (_isRunning) {
        [self.serverSocket close];
        _isRunning = false;
        NSLog(@"关闭socket");
    }
    else{
        if (![self.serverSocket bindToPort:port error:error]) {
            NSLog(@"服务器不能正常绑定到端口：%li 原因是：%@",(long)port,*error);
            return;
        }
        
        if (![self.serverSocket beginReceiving:error]) {
            [self.serverSocket close];
            NSLog(@"服务器现不能接受消息,原因是:%@",*error);
            return;
        }
        NSLog(@"准备好了");
        _isRunning = YES;
        
    }
}

- (void)sendUDPData:(NSData *)data{
    [self.serverSocket sendData:data toAddress:_address withTimeout:-1 tag:0];
}

- (void)sendResultOfCurtainsOpen:(BOOL)open Success:(BOOL)success WithBuilding:(NSString *)bulding floor:(NSString *)floor room:(NSString *)room number:(NSString *)number{
    
    NSData *resultDataToWrite = [self _curtainsDataToWriteWithBuilding:bulding floor:floor room:room number:number forOpen:open];
    
    [self sendUDPData:resultDataToWrite];
}
- (void)sendResultOfCurtainsSearch:(NSArray *)array{
    NSString *curtainsHexStr = [HexHelper toHex:[array[0] intValue]];
    NSData *curtainsData = [HexHelper hexToByteToNSData:curtainsHexStr];
    Byte *curtainsBytes= (Byte *)[curtainsData bytes];
    Byte bytes[] ={kHeader1,kHeader2,kHeader2,kHeader1,0x06,0x15,0x01,0x01,0x01,0x01,curtainsBytes[0]};
    NSData *data = [NSData dataWithBytes:bytes length:sizeof(bytes)];
    [self sendUDPData:data];
}

- (void)sendResultOfLightsCtrolSuccess:(BOOL)success WithBrightness:(NSString *)brightness building:(NSString *)bulding floor:(NSString *)floor room:(NSString *)room number:(NSString *)number{
    NSData *resultDataToWrite = [self _lightsDataToWriteWithBrightness:brightness building:bulding floor:floor room:room number:number];
    [self sendUDPData:resultDataToWrite];
}
- (void)sendResultOfLightsSearch:(NSArray *)array{
    NSString *hallHexStr = [HexHelper toHex:[array[0] intValue]];
    NSData *hallData = [HexHelper hexToByteToNSData:hallHexStr];
    Byte *hallBytes= (Byte *)[hallData bytes];
    
    NSString *DinningHexStr = [HexHelper toHex:[array[1] intValue]];
    NSData *DinningData = [HexHelper hexToByteToNSData:DinningHexStr];
    Byte *DinningBytes= (Byte *)[DinningData bytes];
    
    Byte bytes[] ={kHeader1,kHeader2,kHeader2,kHeader1,0x0B,0x16,hallBytes[0],0x01,0x01,0x01,0x01,DinningBytes[0],0x01,0x01,0x01,0x02};
    NSData *data = [NSData dataWithBytes:bytes length:sizeof(bytes)];
    [self sendUDPData:data];
    
}

- (void)sendResultOfStoryEnabelSuccess:(BOOL)success WithPattern:(NSString *)pattern building:(NSString *)bulding floor:(NSString *)floor room:(NSString *)room{
    NSData *resultDataToWrite =[self _storyDataToWriteWithPattern:pattern building:bulding floor:floor room:room];
    [self sendUDPData:resultDataToWrite];
}
- (void)sendResultOfStorySearch:(NSString *)pattern{
    Byte bytes[]= {kHeader1,kHeader2,kHeader2,kHeader1,0x02,0x17,pattern.integerValue==1?0x01:0x02};
    NSData *data = [NSData dataWithBytes:bytes length:sizeof(bytes)];
    [self sendUDPData:data];
}

#pragma mark - 私有方法
- (NSData *)_curtainsDataToWriteWithBuilding:(NSString *)bulding floor:(NSString *)floor room:(NSString *)room number:(NSString *)number forOpen:(BOOL)forOpen{
    
    NSData *buldingData = [HexHelper hexToByteToNSData:bulding];
    Byte *buldingBytes = (Byte *)[buldingData bytes];
    
    NSData *floorData = [HexHelper hexToByteToNSData:floor];
    Byte *floorBytes = (Byte *)[floorData bytes];
    
    NSData *roomData = [HexHelper hexToByteToNSData:room];
    Byte *roomBytes = (Byte *)[roomData bytes];
    
    NSData *numberData = [HexHelper hexToByteToNSData:number];
    Byte *numberBytes = (Byte *)[numberData bytes];
    
    Byte bytes[] = {kHeader1,kHeader2,kHeader2,kHeader1,0x05,forOpen?0x11:0x12,buldingBytes[0],floorBytes[0],roomBytes[0],numberBytes[0],0x01};
    NSData *data = [NSData dataWithBytes:bytes length:sizeof(bytes)];
    return data;
}

- (NSData *)_lightsDataToWriteWithBrightness:(NSString *)brightness building:(NSString *)bulding floor:(NSString *)floor room:(NSString *)room number:(NSString *)number{
    NSData *brightnessData = [HexHelper hexToByteToNSData:brightness];
    Byte *brightnessBytes = (Byte *)[brightnessData bytes];
    
    NSData *buldingData = [HexHelper hexToByteToNSData:bulding];
    Byte *buldingBytes = (Byte *)[buldingData bytes];
    
    NSData *floorData = [HexHelper hexToByteToNSData:floor];
    Byte *floorBytes = (Byte *)[floorData bytes];
    
    NSData *roomData = [HexHelper hexToByteToNSData:room];
    Byte *roomBytes = (Byte *)[roomData bytes];
    
    NSData *numberData = [HexHelper hexToByteToNSData:number];
    Byte *numberBytes = (Byte *)[numberData bytes];
    
    Byte bytes[] = {kHeader1,kHeader2,kHeader2,kHeader1,0x06,0x21,brightnessBytes[0],buldingBytes[0],floorBytes[0],roomBytes[0],numberBytes[0],0x01};
    NSData *data = [NSData dataWithBytes:bytes length:sizeof(bytes)];
    return data;
}

- (NSData *)_storyDataToWriteWithPattern:(NSString *)pattern building:(NSString *)bulding floor:(NSString *)floor room:(NSString *)room{
    
    NSData *patternData = [HexHelper hexToByteToNSData:pattern];
    Byte *patternBytes = (Byte *)[patternData bytes];
    
    NSData *buldingData = [HexHelper hexToByteToNSData:bulding];
    Byte *buldingBytes = (Byte *)[buldingData bytes];
    
    NSData *floorData = [HexHelper hexToByteToNSData:floor];
    Byte *floorBytes = (Byte *)[floorData bytes];
    
    NSData *roomData = [HexHelper hexToByteToNSData:room];
    Byte *roomBytes = (Byte *)[roomData bytes];
    
    Byte bytes[] = {kHeader1,kHeader2,kHeader2,kHeader1,0x05,0x23,patternBytes[0],buldingBytes[0],floorBytes[0],roomBytes[0],0x01};
    NSData *data = [NSData dataWithBytes:bytes length:sizeof(bytes)];
    return data;
}

#pragma mark - GCDAsyncUdpDelegate

// 发送失败
- (void)udpSocket:(GCDAsyncUdpSocket *)sock didNotSendDataWithTag:(long)tag dueToError:(NSError *)error{
    NSLog(@"Server-->发送数据失败：%@:\n",error);
}
// 发送成功
- (void)udpSocket:(GCDAsyncUdpSocket *)sock didSendDataWithTag:(long)tag{
    NSLog(@"Server-->成功发送数据:\n");
}
// 收到消息
- (void)udpSocket:(GCDAsyncUdpSocket *)sock didReceiveData:(NSData *)data fromAddress:(NSData *)address withFilterContext:(id)filterContext{
    NSLog(@"Server-->收到数据,from:%@\n",address);
    if (!_address) {
        _address = address;
    }
    Byte *bytes = (Byte *)[data bytes];
    if (bytes[5] == 0x11 || bytes[5]==0x12) {
        NSString *bulding = [NSString stringWithFormat:@"%i",bytes[6]];
        NSString *floor = [NSString stringWithFormat:@"%i",bytes[7]];
        NSString *room = [NSString stringWithFormat:@"%i",bytes[8]];
        NSString *number = [NSString stringWithFormat:@"%i",bytes[9]];
        if (bytes[5] == 0x11) {
            [self.delegate didReceivedCurtainsOpenOrder:YES withBuilding:bulding floor:floor room:room number:number];
        }
        else{
            [self.delegate didReceivedCurtainsOpenOrder:NO withBuilding:bulding floor:floor room:room number:number];
        }
        
    }
    else if(bytes[5]==0x15){
        [self.delegate didReceivedCurtainsStatusSearchOrder];
    }
    else if (bytes[5]==0x21){
        NSString *brightness = [NSString stringWithFormat:@"%i",bytes[6]];
        NSString *bulding = [NSString stringWithFormat:@"%i",bytes[7]];
        NSString *floor = [NSString stringWithFormat:@"%i",bytes[8]];
        NSString *room = [NSString stringWithFormat:@"%i",bytes[9]];
        NSString *number = [NSString stringWithFormat:@"%i",bytes[10]];
        [self.delegate didReceivedLightsCtrolOrderWithBrightness:brightness building:bulding floor:floor room:room number:number];
    }
    else if (bytes[5]==0x16){
        [self.delegate didReceivedLightsStatusSearchOrder];
    }
    else if (bytes[5]==0x23){
        NSString *pattern = [NSString stringWithFormat:@"%i",bytes[6]];
        NSString *bulding = [NSString stringWithFormat:@"%i",bytes[7]];
        NSString *floor = [NSString stringWithFormat:@"%i",bytes[8]];
        NSString *room = [NSString stringWithFormat:@"%i",bytes[9]];
        [self.delegate didReceivedStoryEnabelOrderWithPattern:pattern building:bulding floor:floor room:room];
    }
    else if (bytes[5]==0x17){
        [self.delegate didReceivedStoriesSearchOrder];
    }

}
// 关闭
- (void)udpSocketDidClose:(GCDAsyncUdpSocket *)sock withError:(NSError *)error{
    
}

@end














