//
//  UDPTool.h
//  SocketClient
//
//  Created by ZhangJing on 15/7/26.
//  Copyright (c) 2015年 SINGLE. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GCDAsyncUdpSocket.h"

#import "HexHelper.h"

@protocol UDPToolDelegate <NSObject>

@optional
// 成功打开窗帘回调
- (void)didOpenCurtains:(BOOL)success WithBuilding:(NSString *)bulding floor:(NSString *)floor room:(NSString *)room number:(NSString *)number;
// 成功关闭窗帘回调
- (void)didCloseCurtains:(BOOL)success WithBuilding:(NSString *)bulding floor:(NSString *)floor room:(NSString *)room number:(NSString *)number;
// 成功返回窗帘状态回调
- (void)didReceivedCuratainsStates:(NSArray *)states;

// 成功控制灯回调
- (void)didCtrolLightsSuccess:(BOOL)success WithBrightness:(NSString *)brightness building:(NSString *)bulding floor:(NSString *)floor room:(NSString *)room number:(NSString *)number;
// 成功返回灯状态
- (void)didReceivedLightsStates:(NSArray *)states;
// 成功开启各种情景
- (void)didEnabelStorySuccess:(BOOL)success WithPattern:(NSString *)pattern building:(NSString *)bulding floor:(NSString *)floor room:(NSString *)room;
// 成功查询到当前情景模式
- (void)didReceivedStoriesPattern:(NSString *)pattern;
@end


@interface UDPTool : NSObject<GCDAsyncUdpSocketDelegate>

@property (strong,nonatomic) GCDAsyncUdpSocket  *client;

@property (strong,nonatomic) NSMutableArray     *delegates;

@property (copy, nonatomic)  NSString           *host;
@property (assign,nonatomic) NSInteger          port;

@property (assign,nonatomic) BOOL               active;

+ (instancetype)shareInstance;

- (void)startBindHost:(NSString *)host port:(NSInteger)port;

- (void)addDelegate:(id)sender;

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
- (void)CurtainsOpen:(BOOL)open withBuilding:(NSString *)bulding floor:(NSString *)floor room:(NSString *)room number:(NSString *)number;
/*
 查询：0xA5  0x5A  0x5A  0xA5  0x01  0x15
 回复：0xA5  0x5A  0x5A  0xA5  0xXX  0x15 栋号 层号 房号 编号 状态 [栋号 层号 房号 编号 状态 …]
 释义：状态，0x00：关闭，0x0A：打开，0x01~0x09：打开幅度1~9。如果有多个窗帘，则重复：栋号 层号 房号 编号 状态
 */
- (void)searchCurtains;

#pragma mark - 灯光控制
/*
 控制：0xA5 0x5A 0x5A 0xA5 0x06 0x21 亮度 栋号 层号 房号 编号
 回复：0xA5 0x5A 0x5A 0xA5 0x07 0x21 亮度 栋号 层号 房号 编号 结果
 释义：亮度：00：关闭，0A：打开：0x01~0x09：亮度：0~9。
 */
- (void)controlLightingWithBrightness:(NSString *)brightness building:(NSString *)bulding floor:(NSString *)floor room:(NSString *)room number:(NSString *)number;
/*
 查询：0xA5 0x5A 0x5A 0xA5 0x01 0x16
 回复：0xA5 0x5A 0x5A 0xA5 0xXX 0x16亮度 栋号 层号 房号 编号 [亮度 栋号 层号 房号 编号 …]
 */
- (void)searchLightings;


#pragma mark - 情景控制
/*
 启用：0xA5  0x5A  0x5A  0xA5  0x05  0x23 模式号  栋号 层号 房号
 回复：0xA5  0x5A  0x5A  0xA5  0x06  0x23 模式号  栋号 层号 房号 结果
 释义：模式号取值从1开始，1：在家，2：离家，3：休闲
 */
- (void)enableStoryWithPattern:(NSString *)pattern building:(NSString *)bulding floor:(NSString *)floor room:(NSString *)room;
/*
 查询：0xA5  0x5A  0x5A  0xA5  0x01  0x17
 回复：0xA5  0x5A  0x5A  0xA5  0x02  0x17 模式号
 释义：模式号，如果是0，表示当前没有启用任何模式。
 */
- (void)searchStories;

@end
