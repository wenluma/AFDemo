//
//  ViewController.m
//  AFNetworkingManager
//
//  Created by family on 15/2/27.
//  Copyright (c) 2015年 mgl. All rights reserved.
//

#import "ViewController.h"
#import "AFSharedClient.h"
#import "FileSystemManager.h"


@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [[FileSystemManager sharedManager] initSystem];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
