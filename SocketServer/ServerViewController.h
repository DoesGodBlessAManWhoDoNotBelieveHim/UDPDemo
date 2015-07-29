//
//  ViewController.h
//  SocketServer
//
//  Created by wrt on 15/7/23.
//  Copyright (c) 2015年 SINGLE. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "UDPServerTool.h"
#import "CustomView.h"


#define key_CurtainsOpen            @"key_CurtainsOpen"
#define key_Brightness_Hall         @"key_Brightness_Hall"
#define key_Brightness_DinningRoom  @"key_Brightness_DinningRoom"
#define key_Pattern                 @"key_Pattern"

@interface ServerViewController : NSViewController<UDPServerToolDelegate>

@property (strong) IBOutlet NSImageView *curtainsImageView;

@property (strong) IBOutlet NSImageView *HallImageView;
@property (strong) IBOutlet NSImageView *diningRoomImageView;
@property (strong) IBOutlet NSTextField *hallBringtness;
@property (strong) IBOutlet NSTextField *dinningRoomBringtness;

@property (strong) IBOutlet NSTextField *portTextField;
- (IBAction)startBind:(id)sender;

@property (assign) BOOL curtainsOpen;
@property (assign) NSInteger brightnessOfLightInHall;
@property (assign) NSInteger brightnessOfLightInDinningRoom;
@property (assign) NSInteger pattern;
@property (strong) IBOutlet CustomView *bindingView;
- (IBAction)settings:(NSButton *)sender;

@end

