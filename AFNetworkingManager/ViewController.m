//
//  ViewController.m
//  AFNetworkingManager
//
//  Created by family on 15/2/27.
//  Copyright (c) 2015年 mgl. All rights reserved.
//

#import "ViewController.h"
#import "AFSharedClient.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [[AFSharedClient sharedManager] addPOST:@"http://115.28.208.210:8080/ishow/getmenu?userid=15050191718" paragrams:nil success:^(NSDictionary *responseObject) {
        NSLog([responseObject description],nil);
    } failure:^(NSError *error) {
        NSLog([error description],nil);
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
