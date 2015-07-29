//
//  UDPServerTool.h
//  SocketClient
//
//  Created by ZhangJing on 15/7/26.
//  Copyright (c) 2015年 SINGLE. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GCDAsyncUdpSocket.h"

#import "HexHelper.h"

#import "PrefixHeader.pch"

@protocol UDPServerToolDelegate <NSObject>

@optional
// 收到了窗帘开启或关闭的命令
- (void)didReceivedCurtainsOpenOrder:(BOOL)openOrder withBuilding:(NSString *)bulding floor:(NSString *)floor room:(NSString *)room number:(NSString *)number;
// 收到客户端发来查询当前所有窗帘状态的命令
- (void)didReceivedCurtainsStatusSearchOrder;

// 收到客户端控制灯亮度命令
- (void)didReceivedLightsCtrolOrderWithBrightness:(NSString *)brightness building:(NSString *)bulding floor:(NSString *)floor room:(NSString *)room number:(NSString *)number;
// 收到客户端查询所有灯状态命令
- (void)didReceivedLightsStatusSearchOrder;

// 收到开启情景模式命令
- (void)didReceivedStoryEnabelOrderWithPattern:(NSString *)pattern building:(NSString *)bulding floor:(NSString *)floor room:(NSString *)room;
// 查询当前情景模式
- (void)didReceivedStoriesSearchOrder;

@end

@interface UDPServerTool : NSObject<GCDAsyncUdpSocketDelegate>

@property (strong,nonatomic) GCDAsyncUdpSocket *serverSocket;

//@property (strong,nonatomic) GCDAsyncUdpSocket *clientSocket;
@property (strong,nonatomic) NSData *address;// 这个用以持有客户端的地址，待服务端返回数据时用

@property (nonatomic,assign) id<UDPServerToolDelegate> delegate;

@property (nonatomic,assign) BOOL isRunning;// 服务端是否绑定以待收发数据

+ (instancetype)shareInstance;

// 绑定，开始接受或者停止接受消息
- (void)startStop:(NSInteger)port withError:(NSError **)err;
// 根据 地址 发送data
- (void)sendUDPData:(NSData *)data;

// 此方法在服务端成功控制窗帘后调用，返回控制结果
- (void)sendResultOfCurtainsOpen:(BOOL)open Success:(BOOL)success WithBuilding:(NSString *)bulding floor:(NSString *)floor room:(NSString *)room number:(NSString *)number;
// 服务端反馈客户端查询窗帘结果
- (void)sendResultOfCurtainsSearch:(NSArray *)array;

- (void)sendResultOfLightsCtrolSuccess:(BOOL)success WithBrightness:(NSString *)brightness building:(NSString *)bulding floor:(NSString *)floor room:(NSString *)room number:(NSString *)number;
- (void)sendResultOfLightsSearch:(NSArray *)array;

- (void)sendResultOfStoryEnabelSuccess:(BOOL)success WithPattern:(NSString *)pattern building:(NSString *)bulding floor:(NSString *)floor room:(NSString *)room;
- (void)sendResultOfStorySearch:(NSString *)pattern;

@end
