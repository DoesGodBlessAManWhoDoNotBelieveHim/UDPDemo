//
//  ViewController.m
//  SocketServer
//
//  Created by wrt on 15/7/23.
//  Copyright (c) 2015年 SINGLE. All rights reserved.
//

#import "ServerViewController.h"



@implementation ServerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [UDPServerTool shareInstance].delegate = self;
    
    
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear{
    [super viewWillAppear];
    [self updateView];
}

- (IBAction)startBind:(id)sender {
    
    [[UDPServerTool shareInstance]startStop:_portTextField.stringValue.integerValue];
    
    _portTextField.enabled = ![[UDPServerTool shareInstance] isRunning];
    
}
- (void)updateView{
     _curtainsOpen = [[[NSUserDefaults standardUserDefaults]objectForKey:key_CurtainsOpen] integerValue]==1;
    NSString *brightnessOfLightInHall = [[NSUserDefaults standardUserDefaults]objectForKey:key_Brightness_Hall];
    if (![brightnessOfLightInHall isEqualToString:@"0"]) {
        brightnessOfLightInHall = [brightnessOfLightInHall stringByAppendingString:@"0"];
    }
    NSString *brightnessOfLightInDinningRoom = [[NSUserDefaults standardUserDefaults]objectForKey:key_Brightness_DinningRoom];
    if (![brightnessOfLightInDinningRoom isEqualToString:@"0"]) {
        brightnessOfLightInDinningRoom = [brightnessOfLightInDinningRoom stringByAppendingString:@"0"];
    }
    
    _hallBringtness.stringValue =brightnessOfLightInHall;
    _dinningRoomBringtness.stringValue = brightnessOfLightInDinningRoom;
    
    [_HallImageView setImage:[NSImage imageNamed:brightnessOfLightInHall]];
    [_diningRoomImageView setImage:[NSImage imageNamed:brightnessOfLightInDinningRoom]];
    
    [_curtainsImageView setImage:[NSImage imageNamed:_curtainsOpen?@"0-100":@"0-0"]];
    
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}

#pragma mark =======TCPServer Delegate=========
- (void)didReceivedCurtainsOpenOrder:(BOOL)openOrder withBuilding:(NSString *)bulding floor:(NSString *)floor room:(NSString *)room number:(NSString *)number{
    if (openOrder) {
        NSLog(@"开启窗帘");
        [_curtainsImageView setImage:[NSImage imageNamed:@"0-100.png"]];
        [[NSUserDefaults standardUserDefaults]setObject:@(1) forKey:key_CurtainsOpen];
    }
    else{
        NSLog(@"关闭窗帘");
        [[NSUserDefaults standardUserDefaults]setObject:@(0) forKey:key_CurtainsOpen];
        [_curtainsImageView setImage:[NSImage imageNamed:@"0-0.png"]];
        
    }
    [[NSUserDefaults standardUserDefaults]synchronize];
    //发送成功回馈
    [[UDPServerTool shareInstance] sendResultOfCurtainsOpen:openOrder Success:YES WithBuilding:bulding floor:floor room:room number:number];
}

- (void)didReceivedCurtainsStatusSearchOrder{
    NSLog(@"查询窗帘");
    _curtainsOpen = [[[NSUserDefaults standardUserDefaults]objectForKey:key_CurtainsOpen] integerValue]==1;
    //发送状态回馈
    [[UDPServerTool shareInstance] sendResultOfCurtainsSearch:@[[NSNumber numberWithBool:_curtainsOpen]]];
}
//
- (void)didReceivedLightsCtrolOrderWithBrightness:(NSString *)brightness building:(NSString *)bulding floor:(NSString *)floor room:(NSString *)room number:(NSString *)number{
    NSLog(@"控制灯光");
    if ([number integerValue]==1) {
        _hallBringtness.stringValue = [NSString stringWithFormat:@"%li",brightness.integerValue*10];
        [_HallImageView setImage:[NSImage imageNamed:[NSString stringWithFormat:@"%@.png",_hallBringtness.stringValue]]];
        [[NSUserDefaults standardUserDefaults]setObject:brightness forKey:key_Brightness_Hall];
        
    }
    else{
        _dinningRoomBringtness.stringValue = [NSString stringWithFormat:@"%li",brightness.integerValue*10];
        [_diningRoomImageView setImage:[NSImage imageNamed:[NSString stringWithFormat:@"%@.png",_dinningRoomBringtness.stringValue]]];
         [[NSUserDefaults standardUserDefaults]setObject:brightness forKey:key_Brightness_DinningRoom];
    }
    [[NSUserDefaults standardUserDefaults]synchronize];
         
         //发送成功回馈
    if (brightness.integerValue==10) {
        brightness = @"0A";
    }
    [[UDPServerTool shareInstance]sendResultOfLightsCtrolSuccess:YES WithBrightness:brightness building:bulding floor:floor room:room number:number];
    
}
- (void)didReceivedLightsStatusSearchOrder{
    NSLog(@"查询扥光");
    
    _brightnessOfLightInHall = [[[NSUserDefaults standardUserDefaults]objectForKey:key_Brightness_Hall] integerValue];
    _brightnessOfLightInDinningRoom = [[[NSUserDefaults standardUserDefaults]objectForKey:key_Brightness_DinningRoom] integerValue];
    //发送灯光信息回馈
    [[UDPServerTool shareInstance]sendResultOfLightsSearch:@[@(_brightnessOfLightInHall),@(_brightnessOfLightInDinningRoom)]];
}
//
- (void)didReceivedStoryEnabelOrderWithPattern:(NSString *)pattern building:(NSString *)bulding floor:(NSString *)floor room:(NSString *)room{
    NSLog(@"开启模式");
    //在家，全开，外出，全关
    if (pattern.integerValue==1) {//在家
         NSString *str = @"100";
        _hallBringtness.stringValue = str;
        _HallImageView.image = [NSImage imageNamed:str];
        [[NSUserDefaults standardUserDefaults]setObject:@"10" forKey:key_Brightness_Hall];
        
        _dinningRoomBringtness.stringValue = str;
        _diningRoomImageView.image = [NSImage imageNamed:str];
        [[NSUserDefaults standardUserDefaults]setObject:@"10" forKey:key_Brightness_DinningRoom];
        
        NSString *iamgeName = [NSString stringWithFormat:@"0-100"];
        _curtainsImageView.image = [NSImage imageNamed:iamgeName];
        [[NSUserDefaults standardUserDefaults]setObject:@"1" forKey:key_CurtainsOpen];
        [[NSUserDefaults standardUserDefaults]setObject:@"1" forKey:key_Pattern];
    }
    else if (pattern.integerValue==2){//外出
        NSString *str = @"0";
        _hallBringtness.stringValue = str;
        _HallImageView.image = [NSImage imageNamed:str];
        [[NSUserDefaults standardUserDefaults]setObject:str forKey:key_Brightness_Hall];
        
        _dinningRoomBringtness.stringValue = str;
        _diningRoomImageView.image = [NSImage imageNamed:str];
        [[NSUserDefaults standardUserDefaults]setObject:str forKey:key_Brightness_DinningRoom];
        
        NSString *iamgeName = [NSString stringWithFormat:@"0-0"];
        _curtainsImageView.image = [NSImage imageNamed:iamgeName];
        [[NSUserDefaults standardUserDefaults]setObject:@"0" forKey:key_CurtainsOpen];
        [[NSUserDefaults standardUserDefaults]setObject:@"2" forKey:key_Pattern];
    }

    [[NSUserDefaults standardUserDefaults]synchronize];
    
    //反馈信息
    [[UDPServerTool shareInstance]sendResultOfStoryEnabelSuccess:YES WithPattern:pattern building:bulding floor:floor room:room];
}
- (void)didReceivedStoriesSearchOrder{
    NSLog(@"模式查询");
    _pattern = [[[NSUserDefaults standardUserDefaults]objectForKey:key_Pattern] integerValue];
    //
    [[UDPServerTool shareInstance]sendResultOfStorySearch:[[NSUserDefaults standardUserDefaults]objectForKey:key_Pattern]];
}


@end
