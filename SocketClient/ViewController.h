//
//  ViewController.h
//  SocketClient
//
//  Created by ZhangJing on 15/7/21.
//  Copyright (c) 2015年 SINGLE. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "TCPTool.h"
#import "UDPTool.h"

@interface ViewController : UIViewController</*TCPToolDelegate*/UDPToolDelegate>

@property (strong, nonatomic) IBOutlet UIImageView *curtanisIV;

@property (nonatomic,assign)  BOOL curtainsOpen;




- (IBAction)openCurtains:(UIButton *)sender;


@property (strong, nonatomic) IBOutlet UITextField *hostTextField;

@property (strong, nonatomic) IBOutlet UITextField *portTextField;

- (IBAction)bind;
@end

