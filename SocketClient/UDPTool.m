//
//  UDPTool.m
//  SocketClient
//
//  Created by ZhangJing on 15/7/26.
//  Copyright (c) 2015年 SINGLE. All rights reserved.
//

#import "UDPTool.h"

@implementation UDPTool

static UDPTool *_instance;

+ (instancetype)shareInstance{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!_instance) {
            _instance = [[UDPTool alloc]init];
            _instance.client = [[GCDAsyncUdpSocket alloc] initWithDelegate:_instance delegateQueue:dispatch_get_main_queue()];
            NSError *error;
            if (![_instance.client bindToPort:0 error:&error]) {
                NSLog(@"客户端不能绑定到端口:%i,原因是:%@",0,error);
                //return _client;
            }
            if(![_instance.client beginReceiving:nil]) {
                NSLog(@"客户端不能接受信息，原因是:%@",error);
            }
            NSLog(@"准备OK！");
            _instance.active = NO;
        }
    });
    return _instance;
}

- (NSMutableArray *)delegates{
    if (!_delegates) {
        _delegates = [NSMutableArray array];
    }
    return _delegates;
}

- (void)addDelegate:(id)sender{
    [self.delegates addObject:sender];
}

- (void)startBindHost:(NSString *)host port:(NSInteger)port{
    NSLog(@"bind to %@,%li",host,port);
    _active = !_active;
    _host = host;
    _port = port;
}

#pragma mark - 窗帘控制
/*
 开窗：0xA5  0x5A  0x5A  0xA5  0x05  0x11 栋号 层号 房号 编号
 回复：0xA5  0x5A  0x5A  0xA5  0x06  0x11 栋号 层号 房号 编号 结果
 释义：栋号、层号、房号，编号，全部默认从01开始，编号代表第几个窗帘。
 　　　结果：0：控制失败，1：控制成功。下同。
 */
/*
 关窗：0xA5  0x5A  0x5A  0xA5  0x05  0x12 栋号 层号 房号 编号
 回复：0xA5  0x5A  0x5A  0xA5  0x06  0x12 栋号 层号 房号 编号 结果
 */
- (void)CurtainsOpen:(BOOL)open withBuilding:(NSString *)bulding floor:(NSString *)floor room:(NSString *)room number:(NSString *)number{
    NSData *writeData = [self _curtainsDataToWriteWithBuilding:bulding floor:floor room:room number:number forOpen:open];
    
    [self sendData:writeData WithTag:0];
}
/*
 查询：0xA5  0x5A  0x5A  0xA5  0x01  0x15
 回复：0xA5  0x5A  0x5A  0xA5  0xXX  0x15 栋号 层号 房号 编号 状态 [栋号 层号 房号 编号 状态 …]
 释义：状态，0x00：关闭，0x0A：打开，0x01~0x09：打开幅度1~9。如果有多个窗帘，则重复：栋号 层号 房号 编号 状态
 */
- (void)searchCurtains{
    Byte bytes[] = {kHeader1,kHeader2,kHeader2,kHeader1,0x01,0x15};
    NSData *writeData = [NSData dataWithBytes:bytes length:sizeof(bytes)];
    [self sendData:writeData WithTag:0];
}

#pragma mark - 灯光控制
/*
 控制：0xA5 0x5A 0x5A 0xA5 0x06 0x21 亮度 栋号 层号 房号 编号
 回复：0xA5 0x5A 0x5A 0xA5 0x07 0x21 亮度 栋号 层号 房号 编号 结果
 释义：亮度：00：关闭，0A：打开：0x01~0x09：亮度：0~9。
 */
- (void)controlLightingWithBrightness:(NSString *)brightness building:(NSString *)bulding floor:(NSString *)floor room:(NSString *)room number:(NSString *)number{
    NSData *writeData = [self _lightsDataToWriteWithBrightness:brightness building:bulding floor:floor room:room number:number];
    [self sendData:writeData WithTag:0];
}
/*
 查询：0xA5 0x5A 0x5A 0xA5 0x01 0x16
 回复：0xA5 0x5A 0x5A 0xA5 0xXX 0x16亮度 栋号 层号 房号 编号 [亮度 栋号 层号 房号 编号 …]
 */
- (void)searchLightings{
    Byte bytes[] = {kHeader1,kHeader2,kHeader2,kHeader1,0x01,0x16};
    NSData *writeData = [NSData dataWithBytes:bytes length:sizeof(bytes)];
    [self sendData:writeData WithTag:0];
}


#pragma mark - 情景控制
/*
 启用：0xA5  0x5A  0x5A  0xA5  0x05  0x23 模式号  栋号 层号 房号
 回复：0xA5  0x5A  0x5A  0xA5  0x06  0x23 模式号  栋号 层号 房号 结果
 释义：模式号取值从1开始，1：在家，2：离家，3：休闲
 */
- (void)enableStoryWithPattern:(NSString *)pattern building:(NSString *)bulding floor:(NSString *)floor room:(NSString *)room{
    
    NSData *writeData = [self _storyDataToWriteWithPattern:pattern building:bulding floor:floor room:room];
    
    [self sendData:writeData WithTag:0];
}
/*
 查询：0xA5  0x5A  0x5A  0xA5  0x01  0x17
 回复：0xA5  0x5A  0x5A  0xA5  0x02  0x17 模式号
 释义：模式号，如果是0，表示当前没有启用任何模式。
 */
- (void)searchStories{
    Byte bytes[] = {kHeader1,kHeader2,kHeader2,kHeader1,0x01,0x17};
    NSData *writeData = [NSData dataWithBytes:bytes length:sizeof(bytes)];
    [self sendData:writeData WithTag:0];
}

#pragma mark =======私有方法=========

- (void)sendData:(NSData *)data WithTag:(NSInteger)tag{
    if (_active) {
        if (!_host || [_host isEqualToString:@""]) {
            _host = @"127.0.0.1";
        }
        [self.client sendData:data toHost:_host port:_port withTimeout:-1 tag:0];
    }
    
}

- (NSData *)_curtainsDataToWriteWithBuilding:(NSString *)bulding floor:(NSString *)floor room:(NSString *)room number:(NSString *)number forOpen:(BOOL)forOpen{
    NSData *buldingData = [HexHelper hexToByteToNSData:bulding];
    Byte *buldingBytes = (Byte *)[buldingData bytes];
    
    NSData *floorData = [HexHelper hexToByteToNSData:floor];
    Byte *floorBytes = (Byte *)[floorData bytes];
    
    NSData *roomData = [HexHelper hexToByteToNSData:room];
    Byte *roomBytes = (Byte *)[roomData bytes];
    
    NSData *numberData = [HexHelper hexToByteToNSData:number];
    Byte *numberBytes = (Byte *)[numberData bytes];
    
    Byte bytes[] = {kHeader1,kHeader2,kHeader2,kHeader1,0x05,forOpen?0x11:0x12,buldingBytes[0],floorBytes[0],roomBytes[0],numberBytes[0]};
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
    
    Byte bytes[] = {kHeader1,kHeader2,kHeader2,kHeader1,0x06,0x21,brightnessBytes[0],buldingBytes[0],floorBytes[0],roomBytes[0],numberBytes[0]};
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
    
    Byte bytes[] = {kHeader1,kHeader2,kHeader2,kHeader1,0x05,0x23,patternBytes[0],buldingBytes[0],floorBytes[0],roomBytes[0]};
    NSData *data = [NSData dataWithBytes:bytes length:sizeof(bytes)];
    return data;
}
#pragma mark - Delegate
- (void)udpSocket:(GCDAsyncUdpSocket *)sock didSendDataWithTag:(long)tag{
    NSLog(@"Client-->成功发送数据");
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didReceiveData:(NSData *)data fromAddress:(NSData *)address withFilterContext:(id)filterContext{
    NSLog(@"Client-->收到数据");
    Byte *bytes = (Byte *)[data bytes];
    
    if (bytes[5]==0x11 || bytes[5]==0x12) {//或者这里用 bytes[5]做判断
        BOOL success = bytes[10]==0x01;// 这里0x00代表失败 -- 0x01代表成功
        NSString *bulding = [NSString stringWithFormat:@"%i",bytes[6]];
        NSString *floor = [NSString stringWithFormat:@"%i",bytes[7]];
        NSString *room = [NSString stringWithFormat:@"%i",bytes[8]];
        NSString *number = [NSString stringWithFormat:@"%i",bytes[9]];
        if (bytes[5]==0x11) {
            for (id delegate in self.delegates) {
                if ([delegate respondsToSelector:@selector(didOpenCurtains:WithBuilding:floor:room:number:)]) {
                    [delegate didOpenCurtains:success WithBuilding:bulding floor:floor room:room number:number];
                }
            }
        }
        else{
            for (id delegate in self.delegates) {
                if ([delegate respondsToSelector:@selector(didCloseCurtains:WithBuilding:floor:room:number:)]) {
                    [delegate didCloseCurtains:success WithBuilding:bulding floor:floor room:room number:number];
                }
            }
        }
        
    }
    else if(bytes[5]==0x15){
        NSMutableArray *status = [NSMutableArray array];
        int count = bytes[4];
        for (int i = 0; i < count/5; i++) {
            
            NSString *bulding = [NSString stringWithFormat:@"%i",bytes[6+5*i]];
            NSString *floor = [NSString stringWithFormat:@"%i",bytes[7+5*i]];
            NSString *room = [NSString stringWithFormat:@"%i",bytes[8+5*i]];
            NSString *number = [NSString stringWithFormat:@"%i",bytes[9+5*i]];
            NSString *states = [NSString stringWithFormat:@"%i",bytes[10+5*i]];
            NSArray *infos = @[bulding,floor,room,number,states];
            [status addObject:infos];
            
        }
        for (id delegate in self.delegates) {
            if ([delegate respondsToSelector:@selector(didReceivedCuratainsStates:)]) {
                [delegate didReceivedCuratainsStates:status];
            }
        }
    }
    else if (bytes[5]==0x21){
        
        BOOL success = bytes[11]==0x01;// 这里0x00代表失败 -- 0x01代表成功
        NSString *brightness = [NSString stringWithFormat:@"%i",bytes[6]];
        NSString *bulding = [NSString stringWithFormat:@"%i",bytes[7]];
        NSString *floor = [NSString stringWithFormat:@"%i",bytes[8]];
        NSString *room = [NSString stringWithFormat:@"%i",bytes[9]];
        NSString *number = [NSString stringWithFormat:@"%i",bytes[10]];
        for (id delegate in self.delegates) {
            if ([delegate respondsToSelector:@selector(didCtrolLightsSuccess:WithBrightness:building:floor:room:number:)]) {
                [delegate didCtrolLightsSuccess:success WithBrightness:brightness building:bulding floor:floor room:room number:number];
            }
        }
    }
    else if (bytes[5]==0x16){
        NSMutableArray *status = [NSMutableArray array];
        for (int i = 0; i < bytes[4]/5; i++) {
            NSString *brightness = [NSString stringWithFormat:@"%i",bytes[6+5*i]];
            NSString *bulding = [NSString stringWithFormat:@"%i",bytes[7+5*i]];
            NSString *floor = [NSString stringWithFormat:@"%i",bytes[7+8*i]];
            NSString *room = [NSString stringWithFormat:@"%i",bytes[9+5*i]];
            NSString *number = [NSString stringWithFormat:@"%i",bytes[10+5*i]];
            NSArray *infos = @[brightness,bulding,floor,room,number];
            [status addObject:infos];
            
        }
        
        for (id delegate in self.delegates) {
            if ([delegate respondsToSelector:@selector(didReceivedLightsStates:)]) {
                [delegate didReceivedLightsStates:status];
            }
        }
    }
    else if (bytes[5]==0x23){
        BOOL success = bytes[10]==0x01;// 这里0x00代表失败 -- 0x01代表成功
        NSString *pattern = [NSString stringWithFormat:@"%i",bytes[6]];
        NSString *bulding = [NSString stringWithFormat:@"%i",bytes[7]];
        NSString *floor = [NSString stringWithFormat:@"%i",bytes[8]];
        NSString *room = [NSString stringWithFormat:@"%i",bytes[9]];
        for (id delegate in self.delegates) {
            if ([delegate respondsToSelector:@selector(didEnabelStorySuccess:WithPattern:building:floor:room:)]) {
                [delegate didEnabelStorySuccess:success WithPattern:pattern building:bulding floor:floor room:room];
            }
        }
    }
    else if (bytes[5]==0x17){
        NSString *pattern = [NSString stringWithFormat:@"%i",bytes[6]];
        
        for (id delegate in self.delegates) {
            if ([delegate respondsToSelector:@selector(didReceivedStoriesPattern:)]) {
                [delegate didReceivedStoriesPattern:pattern];
            }
        }
        
    }
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didNotSendDataWithTag:(long)tag dueToError:(NSError *)error{
    NSLog(@"Client-->数据发送失败");
}
@end












